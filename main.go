package main

import (
	"fmt"
	"golang.org/x/net/icmp"
	"golang.org/x/net/ipv4"
	"log"
)

func main() {
	// 监听 ipv4 ICMP 包（ping）
	con, err := icmp.ListenPacket("ip4:icmp", "0.0.0.0")
	if err != nil {
		log.Fatal(err)
	}
	defer con.Close()

	fmt.Println("Starting listener other ping request...")

	buf := make([]byte, 1500)

	for {
		n, peer, err := con.ReadFrom(buf)
		if err != nil {
			log.Println("Read fail: ", err)
		}

		// 解析 ICMP 消息
		msg, err := icmp.ParseMessage(1, buf[:n])
		if err != nil {
			log.Println("Parse fail: ", err)
			continue
		}

		if msg.Type == ipv4.ICMPTypeEcho {
			fmt.Println("Received ping request from: ", peer)
		}
	}
}
