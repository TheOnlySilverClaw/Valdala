package yamc

import (
	"context"
	"crypto/tls"
	"net/http"

	"github.com/quic-go/quic-go/http3"
	"github.com/quic-go/webtransport-go"
	"github.com/rs/zerolog/log"
)

type ConnectWebtransportHandler struct {
	server         *webtransport.Server
	sessionChannel chan *webtransport.Session
}

func (handler *ConnectWebtransportHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {

	log.Debug().Str("address", request.RemoteAddr).Msg("Incoming request")

	session, err := handler.server.Upgrade(writer, request)
	if err != nil {
		log.Err(err).Msg("Failed to upgrade")
		return
	}

	handler.sessionChannel <- session

	log.Debug().Msg("Successfully created webtransport connection")
}

func StartWebtransportServer(chat *ChatController) error {

	certificate, err := tls.LoadX509KeyPair("certs/cert_dev.pem", "certs/key_dev.pem")
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

	sessionChannel := make(chan *webtransport.Session)
	connectHandler := ConnectWebtransportHandler{
		sessionChannel: sessionChannel,
		server:         &server,
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
		var session *webtransport.Session = <-sessionChannel

		stream, err := session.AcceptStream(context.Background())
		if err != nil {
			log.Err(err).Msg("Failed to accept stream")
		}

		chat.Connect(&ClientConnection{name: session.RemoteAddr().String(), stream: stream})
	}

	return nil
}

// func handleChat(session *webtransport.Session) error {

// 	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
// 	stream, err := session.AcceptStream(ctx)
// 	defer cancel()

// 	if err != nil {
// 		log.Err(err).Msg("Failed to open chat stream")
// 		return err
// 	}

// 	defer stream.Close()

// 	log.Debug().Msg("Established chat stream")

// 	for {
// 		log.Debug().Msg("Waiting for message")
// 		buffer := make([]byte, 1024)

// 		readCount, err := stream.Read(buffer)

// 		if err != nil {
// 			log.Err(err).Msg("Failed to read data")
// 			return err
// 		}

// 		message := string(buffer[2:readCount])
// 		log.Debug().Int("read-count", readCount).Str("data", message).Msg("Received data")

// 		serverMessage := ServerChatMessage{
// 			Sender:  session.RemoteAddr().String(),
// 			Message: message,
// 		}

// 		responseData, err := cbor.Marshal(&serverMessage)
// 		if err != nil {
// 			log.Err(err).Msg("Failed to marshal response message")
// 			return err
// 		}

// 		responseLength := len(responseData)

// 		lengthBytes := make([]byte, 2)
// 		binary.BigEndian.PutUint16(lengthBytes, uint16(responseLength))

// 		fmt.Printf("%v -> %v\n", responseLength, lengthBytes)

// 		responseData = append(lengthBytes, responseData...)

// 		log.Debug().Msg(fmt.Sprintf("data: %v", responseData))

// 		writeCount, err := stream.Write(responseData)
// 		if err != nil {
// 			log.Err(err).Msg("Failed to write response")
// 			return err
// 		}

// 		log.Debug().Int("write-count", writeCount).Msg("Wrote response message")

// 	}

// 	return nil
// }