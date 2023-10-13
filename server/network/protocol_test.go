package yamc

import (
	"io"
	"testing"

	"github.com/fxamacker/cbor/v2"
)

type TestStream struct {
}

type TestMessage struct {
	Counter int
	Text    string
}

func TestReadMessages(test *testing.T) {

	reader, writer := io.Pipe()

	var success = make(chan bool, 1)
	var serverReady = make(chan bool, 1)

	go func() {

		test.Log("read messages")
		var stream = NewMessageStream[TestMessage](reader)
		var results = stream.OnRead()
		serverReady <- true

		first := <-results
		second := <-results

		test.Log(first)
		test.Log(second)

		if first.err == nil && first.message.Counter == 0 && first.message.Text == "1234" &&
			second.err == nil && second.message.Counter == 1 && second.message.Text == "Kürbis" {
			success <- true
		} else {
			success <- false
		}
	}()

	go func() {

		<-serverReady
		test.Log("write message")
		encoder := cbor.NewEncoder(writer)
		encoder.Encode(TestMessage{Counter: 0, Text: "1234"})
		encoder.Encode(TestMessage{Counter: 1, Text: "Kürbis"})
	}()

	result := <-success
	if result == false {
		test.Fail()
	}
}
