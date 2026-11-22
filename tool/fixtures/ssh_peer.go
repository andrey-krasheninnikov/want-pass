// A loopback SSH peer for macOS acceptance. It serves two fixed sessions.
package main

import (
	"bytes"
	"crypto/ed25519"
	"crypto/rand"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strings"
	"time"

	"golang.org/x/crypto/ssh"
)

func serveSession(channel ssh.Channel, requests <-chan *ssh.Request) error {
	for request := range requests {
		switch request.Type {
		case "pty-req", "env", "window-change":
			request.Reply(true, nil)
		case "shell":
			request.Reply(true, nil)
			if _, err := channel.Write([]byte("want-pass-loopback-ok\n")); err != nil {
				return err
			}
			_, err := channel.SendRequest("exit-status", false, ssh.Marshal(struct{ Status uint32 }{0}))
			return err
		default:
			request.Reply(false, nil)
		}
	}
	return errors.New("client closed before requesting the fixture session")
}

func serveConnection(listener *net.TCPListener, config *ssh.ServerConfig) error {
	if err := listener.SetDeadline(time.Now().Add(4 * time.Minute)); err != nil {
		return err
	}
	connection, err := listener.Accept()
	if err != nil {
		return err
	}
	defer connection.Close()
	if err := connection.SetDeadline(time.Now().Add(time.Minute)); err != nil {
		return err
	}
	server, channels, messages, err := ssh.NewServerConn(connection, config)
	if err != nil {
		return errors.New("loopback SSH handshake failed")
	}
	defer server.Close()
	fmt.Println("Fixture received an authenticated OpenSSH connection.")
	go ssh.DiscardRequests(messages)
	for offered := range channels {
		if offered.ChannelType() != "session" {
			offered.Reject(ssh.UnknownChannelType, "denied")
			continue
		}
		channel, requests, err := offered.Accept()
		if err != nil {
			return err
		}
		err = serveSession(channel, requests)
		channel.Close()
		if err != nil {
			return err
		}
		fmt.Println("Fixture returned its fixed session marker.")
		return nil
	}
	return errors.New("client closed before opening a session channel")
}

func run(root string) error {
	_, key, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return err
	}
	signer, err := ssh.NewSignerFromKey(key)
	if err != nil {
		return err
	}
	config := &ssh.ServerConfig{MaxAuthTries: 2}
	config.PublicKeyCallback = func(client ssh.ConnMetadata, offered ssh.PublicKey) (*ssh.Permissions, error) {
		allowed, err := os.ReadFile(filepath.Join(root, "authorized.pub"))
		offeredKey := bytes.TrimSpace(ssh.MarshalAuthorizedKey(offered))
		if err != nil || client.User() != "fixture" || !bytes.Equal(bytes.TrimSpace(allowed), offeredKey) {
			return nil, errors.New("denied")
		}
		return &ssh.Permissions{}, nil
	}
	config.AddHostKey(signer)
	listener, err := net.ListenTCP("tcp4", &net.TCPAddr{IP: net.IPv4(127, 0, 0, 1)})
	if err != nil {
		return err
	}
	defer listener.Close()
	descriptor, err := json.Marshal(map[string]any{
		"port":       listener.Addr().(*net.TCPAddr).Port,
		"public_key": strings.TrimSpace(string(ssh.MarshalAuthorizedKey(signer.PublicKey()))),
	})
	if err != nil {
		return err
	}
	partial := filepath.Join(root, "server.partial")
	if err := os.WriteFile(partial, descriptor, 0600); err != nil {
		return err
	}
	if err := os.Rename(partial, filepath.Join(root, "server.json")); err != nil {
		return err
	}
	for i := 0; i < 2; i++ {
		if err := serveConnection(listener, config); err != nil {
			return err
		}
	}
	return nil
}

func main() {
	if len(os.Args) != 2 {
		os.Exit(2)
	}
	if err := run(os.Args[1]); err != nil {
		fmt.Fprintln(os.Stderr, "The loopback SSH fixture did not finish.")
		os.Exit(1)
	}
}
