package main

import (
	"context"
	"crypto/tls"
	"encoding/binary"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"github.com/quic-go/quic-go/http3"
	"github.com/quic-go/webtransport-go"
)

func main() {

	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	zerolog.SetGlobalLevel(zerolog.TraceLevel)

	log.Logger = log.Output(zerolog.ConsoleWriter{
		Out:        os.Stdout,
		TimeFormat: time.DateTime,
	})

	log.Info().Msg("YAMC server start")
	cwd, _ := os.Getwd()
	log.Info().Msg("Current directory: " + cwd)

	startWebtransportServer()
}

func startWebtransportServer() error {

	router := http.NewServeMux()

	certificate, err := tls.LoadX509KeyPair("certs/cert_dev.pem", "certs/key_dev.pem")
	if err != nil {
		log.Err(err).Msg("Failed to load TLS certificate")
		return err
	}

	tlsConfiguration := tls.Config{Certificates: []tls.Certificate{certificate}}

	server := webtransport.Server{
		H3: http3.Server{
			TLSConfig: &tlsConfiguration,
			Addr:      "127.0.0.1:8080",
			Handler:   router,
		},
		CheckOrigin: func(r *http.Request) bool { return true },
	}

	router.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hallo!"))
	})

	router.HandleFunc("/connect", func(w http.ResponseWriter, r *http.Request) {

		wtConnection, err := server.Upgrade(w, r)
		if err != nil {
			log.Err(err).Msg("Failed to upgrade")
		}

		wtStream, err := wtConnection.AcceptStream(context.Background())
		if err != nil {
			log.Err(err).Msg("Failed to open stream")
		}
		defer wtStream.Close()

		for {
			log.Debug().Msg("Waiting for message")
			buffer := make([]byte, 1024)

			readCount, err := wtStream.Read(buffer)

			if err != nil {
				log.Err(err).Msg("Failed to read data")
			}

			message := string(buffer[2:readCount])
			log.Debug().Int("read-count", readCount).Str("data", message).Msg("Received data")

			responseMessage := strings.ToUpper(message)
			responseLength := len(responseMessage)
			responseData := make([]byte, responseLength+2)

			binary.BigEndian.PutUint16(responseData, uint16(responseLength))
			copy(responseData[2:], []byte(responseMessage))

			log.Debug().Msg(fmt.Sprintf("data: %v", responseData))

			writeCount, err := wtStream.Write(responseData)
			if err != nil {
				log.Err(err).Msg("Failed to write response")
			}

			log.Debug().Int("write-count", writeCount).Msg("Wrote response message")

		}
	})

	if err := server.ListenAndServe(); err != nil {
		log.Err(err).Msg("Failed to start listening")
		return err
	}

	log.Info().Msg("Listening to connections")

	return nil
}
