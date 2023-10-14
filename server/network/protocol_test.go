package yamc

import (
	"context"
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/fxamacker/cbor/v2"
	"github.com/quic-go/quic-go/http3"
	"github.com/quic-go/webtransport-go"
)

func TestConnection(test *testing.T) {

	var client webtransport.Dialer
	var roundTripper http3.RoundTripper
	var tlsConfig tls.Config

	tlsConfig.InsecureSkipVerify = true
	roundTripper.TLSClientConfig = &tlsConfig
	client.RoundTripper = &roundTripper

	header := make(http.Header, 2)

	header.Add("Authorization", "Basic "+base64.RawStdEncoding.EncodeToString([]byte("Jürgen:1234")))

	serverReady := make(chan bool, 1)
	errors := make(chan error, 1)

	go func() {

		test.Log("Starting webtransport server")

		go StartWebtransportServer("../certs")
		time.Sleep(300 * time.Millisecond)
		serverReady <- true
	}()

	go func() {

		<-serverReady

		test.Log("Dialing ...")

		response, session, err := client.Dial(
			context.Background(), "https://localhost:8080/connect", header)

		if err != nil {
			errors <- err
			return
		}

		if response.StatusCode != 200 {
			errors <- fmt.Errorf("Invalid response status: %v", response.StatusCode)
			return
		}

		stream, err := session.OpenStream()
		if err != nil {
			errors <- err
			return
		}

		messageType := make([]byte, 1)
		messageType[0] = byte(CHAT_MESSAGE)

		if _, err := stream.Write(messageType); err != nil {
			errors <- err
			return
		}

		encoder := cbor.NewEncoder(stream)
		if err := encoder.Encode(ClientChatMessage{Text: "Hello!"}); err != nil {
			errors <- err
			return
		}

		if err := encoder.Encode(ClientChatMessage{Text: "What's up?"}); err != nil {
			errors <- err
			return
		}

		// decoder := cbor.NewDecoder(stream)

		// var firstResponse ServerChatMessage
		// if err := decoder.Decode(&firstResponse); err != nil {
		// 	errors <- err
		// 	return
		// }

		// test.Log(firstResponse)

		time.Sleep(1 * time.Second)

		if err := stream.Close(); err != nil {
			errors <- err
			return
		}

		if err := client.Close(); err != nil {
			errors <- err
			return
		}

		errors <- nil
	}()

	err := <-errors
	if err != nil {
		test.Fatal(err)
	}

}
