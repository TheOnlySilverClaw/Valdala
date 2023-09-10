package main

import (
	"context"
	"crypto/tls"
	"net"
	"os"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"github.com/quic-go/quic-go"
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

	startServer()
}

func startServer() error {

	udpConnection, err := net.ListenUDP("udp", &net.UDPAddr{IP: net.ParseIP("127.0.0.1"), Port: 8080})
	if err != nil {
		log.Err(err).Msg("UDP server could not start")
		return err
	}

	transport := quic.Transport{Conn: udpConnection}

	certificate, err := tls.LoadX509KeyPair("certs/cert_dev.pem", "certs/key_dev.pem")
	if err != nil {
		log.Err(err).Msg("Failed to load TLS certificate")
		return err
	}

	tlsConfiguration := tls.Config{Certificates: []tls.Certificate{certificate}}
	quicConfiguration := quic.Config{}

	listener, err := transport.Listen(&tlsConfiguration, &quicConfiguration)
	if err != nil {
		log.Err(err).Msg("Cannot listen to UDP connections")
		return err
	}

	connection, err := listener.Accept(context.Background())
	if err != nil {
		return err
	}

	log.Info().Msg(connection.RemoteAddr().String())

	return nil
}
