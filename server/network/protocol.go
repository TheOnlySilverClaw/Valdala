package yamc

import (
	"io"

	"github.com/fxamacker/cbor/v2"
	_ "github.com/quic-go/webtransport-go"
)

type MessageStream[M interface{}] struct {
	closer  io.Closer
	decoder *cbor.Decoder
}

type ReadResult[M interface{}] struct {
	message *M
	err     *error
}

func NewMessageStream[M interface{}](dataStream io.ReadCloser) *MessageStream[M] {

	return &MessageStream[M]{
		closer:  dataStream,
		decoder: cbor.NewDecoder(dataStream),
	}
}

func (stream *MessageStream[M]) OnRead() chan ReadResult[M] {

	results := make(chan ReadResult[M])
	go readMessages[M](stream.decoder, results)
	return results
}

func readMessages[M interface{}](decoder *cbor.Decoder, results chan ReadResult[M]) {

	for {
		var message M
		err := decoder.Decode(&message)
		if err == nil {
			results <- ReadResult[M]{message: &message, err: nil}
		} else {
			results <- ReadResult[M]{message: nil, err: &err}
		}
	}
}
