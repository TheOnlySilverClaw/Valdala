package yamc

import (
	"fmt"
	"io"

	"github.com/fxamacker/cbor/v2"
	"github.com/quic-go/webtransport-go"
	"github.com/rs/zerolog/log"
)

const (
	CHAT_MESSAGE uint = iota + 1
	WORLD_INFO_REQUEST
	CHUNK_REQUEST
)

type Connection struct {
	Name            string
	Address         string
	incomingStreams chan AcceptStreamResult
	Messages        chan Message
	errors          chan error
}

type AcceptStreamResult struct {
	MessageType uint
	Stream      webtransport.Stream
	Err         error
}

type Message struct {
	Type uint
	Data interface{}
}

type ClientChatMessage struct {
	Text string
}

type ServerChatMessage struct {
	Text   string
	Sender string
}

func Connect(attempt ConnectionAttempt) (*Connection, error) {

	session := attempt.session

	connection := Connection{
		Name:            attempt.username,
		Address:         session.RemoteAddr().String(),
		Messages:        make(chan Message, 1),
		incomingStreams: make(chan AcceptStreamResult, 1),
		errors:          make(chan error, 1),
	}

	go receiveStreams(session, connection.incomingStreams)

	return &connection, nil
}

func (connection *Connection) Listen() error {

	for {
		log.Debug().Msg("Waiting for connection event")

		select {

		case err := <-connection.errors:
			log.Debug().
				Str("address", connection.Address).
				Str("name", connection.Name).
				Msg("Connection closed")
			return err

		case result := <-connection.incomingStreams:

			if result.Err == nil {
				go receiveMessages(result.MessageType, result.Stream, connection.Messages, connection.errors)
			} else {
				connection.errors <- result.Err
			}
		}
	}
}

func mapClientMessageType(messageType uint) (interface{}, error) {

	switch messageType {
	case 1:
		return new(ClientChatMessage), nil
	default:
		return nil, fmt.Errorf("Invalid client message type: %v", messageType)
	}
}

func receiveMessages(messageType uint, stream io.Reader, messages chan Message, errors chan error) {

	decoder := cbor.NewDecoder(stream)

	for {

		log.Debug().Msg("Waiting for message")

		data, err := mapClientMessageType(messageType)
		if err != nil {
			errors <- err
			return
		}

		if err := decoder.Decode(data); err != nil {
			errors <- err
			return
		}

		log.Debug().Any("data", data).Msg("Received message")
		messages <- Message{Type: messageType, Data: data}

	}
}

// TODO check whether certain errors are recoverable
func receiveStreams(session *webtransport.Session, results chan AcceptStreamResult) {

	ctx := session.Context()

	for {

		stream, err := session.AcceptStream(ctx)
		log.Debug().Msg("Accepted stream")

		if err != nil {
			results <- AcceptStreamResult{Err: err}
			return
		}

		readBuffer := make([]byte, 1)
		if _, err := stream.Read(readBuffer); err != nil {
			results <- AcceptStreamResult{Err: err}
			return
		}

		messageType := uint(readBuffer[0])
		log.Trace().Uint("type", messageType).Msg("Received stream header")

		results <- AcceptStreamResult{
			MessageType: messageType,
			Stream:      stream,
		}
	}
}
