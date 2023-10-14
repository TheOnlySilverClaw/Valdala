package yamc

import (
	"crypto/tls"
	"net/http"

	"github.com/quic-go/quic-go/http3"
	"github.com/quic-go/webtransport-go"
	"github.com/rs/zerolog/log"
)

type ConnectWebtransportHandler struct {
	server             *webtransport.Server
	connectionAttempts chan ConnectionAttempt
}

type ConnectionAttempt struct {
	username string
	password string
	session  *webtransport.Session
	err      error
}

func (handler *ConnectWebtransportHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {

	username, password, ok := request.BasicAuth()
	if ok == false {
		writer.WriteHeader(http.StatusUnauthorized)
		return
	}

	log.Debug().Str("address", request.RemoteAddr).Msg("Incoming request")

	session, err := handler.server.Upgrade(writer, request)
	if err != nil {
		log.Err(err).Msg("Failed to upgrade")
		handler.connectionAttempts <- ConnectionAttempt{err: err}
		return
	}

	log.Debug().Msgf("connection with name %v and password %v", username, password)

	handler.connectionAttempts <- ConnectionAttempt{
		username: username,
		password: password,
		session: session,
	}

	log.Debug().Msg("Successfully created webtransport connection")
}

func StartWebtransportServer(certificateFolder string) error {

	certificate, err := tls.LoadX509KeyPair(certificateFolder + "/cert_dev.pem", certificateFolder + "/key_dev.pem")
	if err != nil {
		log.Err(err).Msg("Failed to load TLS certificate")
		return err
	}

	tlsConfiguration := tls.Config{Certificates: []tls.Certificate{certificate}}

	router := http.NewServeMux()

	server := webtransport.Server{
		H3: http3.Server{
			TLSConfig: &tlsConfiguration,
			Addr:      "127.0.0.1:8080",
			Handler:   router,
		},
		CheckOrigin: func(r *http.Request) bool { return true },
	}

	connectionAttempts := make(chan ConnectionAttempt)
	connectHandler := ConnectWebtransportHandler{
		connectionAttempts: connectionAttempts,
		server:             &server,
	}

	router.Handle("/connect", &connectHandler)

	go func() {

		if err := server.ListenAndServe(); err != nil {
			log.Err(err).Msg("Failed to start listening")
		}
	}()

	log.Info().Msg("Listening to connections")

	for {
		log.Debug().Msg("Waiting for connection")
		connectionAttempt := <-connectionAttempts

		connection, err := Connect(connectionAttempt)
		if err != nil {
			log.Err(err).Msg("Failed to created webtransport connection")
		}

		go connection.Listen()
		
	}

	return nil
}
