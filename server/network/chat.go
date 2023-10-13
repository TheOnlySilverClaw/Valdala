package yamc

import (
	"encoding/binary"
	"fmt"
	"io"

	"github.com/fxamacker/cbor/v2"
	"github.com/quic-go/webtransport-go"
	"github.com/rs/zerolog/log"
)

type ClientConnection struct {
	name   string
	stream webtransport.Stream
}

type ChatMessage struct {
	Sender  string
	Message string
}

type ChatController struct {
	connections map[string]*ClientConnection

	connectChannel    chan *ClientConnection
	disconnectChannel chan *ClientConnection
	messageChannel    chan *ChatMessage
}

func NewChatController() ChatController {
	return ChatController{
		connections:       make(map[string]*ClientConnection),
		connectChannel:    make(chan *ClientConnection),
		disconnectChannel: make(chan *ClientConnection),
		messageChannel:    make(chan *ChatMessage),
	}
}

func (controller *ChatController) Connect(connection *ClientConnection) error {

	log.Debug().Msg("Received chat connection")
	controller.connectChannel <- connection

	return nil
}

func (controller *ChatController) Start() {

	for {
		fmt.Println("selecting ... ")
		select {

		case connection := <-controller.connectChannel:
			controller.connect(connection)
			break

		case connection := <-controller.disconnectChannel:
			controller.disconnect(connection)
			break

		case message := <-controller.messageChannel:
			controller.broadcast(message)
			break
		}
	}
}

func (controller *ChatController) connect(connection *ClientConnection) {

	log.Debug().Str("name", connection.name).Msg("Connect")
	controller.connections[connection.name] = connection
	go controller.receiveMessages(connection)
}

func (controller *ChatController) receiveMessages(connection *ClientConnection) {

	for {
		log.Debug().Msg("Waiting for message length")
		length, err := ReadLength(connection.stream)

		if err != nil {
			if err == io.EOF {
				log.Info().Msg("Client disconnected")
			} else {
				log.Err(err).Msg("Failed to read message length")
			}
			controller.disconnectChannel <- connection
			return
		}

		buffer := make([]byte, length)
		log.Debug().Uint16("expected", length).Msg("Waiting for message body")
		if readCount, err := io.ReadFull(connection.stream, buffer); err != nil {
			log.Err(err).Uint16("expected", length).Int("received", readCount).Msg("Failed to read message")
			return
		}

		message := string(buffer)
		log.Debug().Str("content", message).Msg("Message received")

		chatMessage := ChatMessage{Sender: connection.name, Message: message}
		controller.messageChannel <- &chatMessage
	}
}

func (controller *ChatController) disconnect(connection *ClientConnection) {

	log.Debug().Str("name", connection.name).Msg("Disconnect")
	delete(controller.connections, connection.name)
}

func (controller *ChatController) broadcast(message *ChatMessage) {

	data, err := cbor.Marshal(&message)
	if err != nil {
		log.Err(err).Msg("Failed to serialize message")
	}

	lengthBuffer := make([]byte, 2)
	binary.BigEndian.PutUint16(lengthBuffer, uint16(len(data)))

	for name, connection := range controller.connections {

		connection.stream.Write(lengthBuffer)

		writtenCount, err := connection.stream.Write(data)
		if err != nil {
			log.Err(err).Msg("Failed to write data")
		}
		log.Debug().Str("name", name).Int("count", writtenCount).Msg("Wrote data to client")
	}
}

func ReadLength(reader io.Reader) (uint16, error) {

	buffer := make([]byte, 2)

	count, err := reader.Read(buffer)
	if err != nil {
		return 0, err
	}

	if count != 2 {
		if _, err := reader.Read(buffer); err != nil {
			return 0, err
		}
	}

	length := binary.BigEndian.Uint16(buffer)
	return length, nil
}
