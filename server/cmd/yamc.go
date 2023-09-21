package main

import (
	/*
	"context"
	"crypto/tls"
	"encoding/binary"
	"fmt"
	"net/http"
	*/
	"os"
	"time"

	// "github.com/fxamacker/cbor/v2"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	// "github.com/quic-go/quic-go/http3"
	// "github.com/quic-go/webtransport-go"

	"yamc/server/internal"
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

	chatController := yamc.NewChatController()

	go chatController.Start()
	yamc.StartWebtransportServer(&chatController)
}

