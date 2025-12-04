package main

import (
	"fmt"
	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"github.com/google/gopacket/pcap"
	"log"
)

func main() {
	// 获取所有网卡
	devices, err := pcap.FindAllDevs()
	if err != nil {
		log.Fatal(err)
	}

	if len(devices) == 0 {
		log.Fatal("没有发现任何网卡")
	}

	fmt.Println("获取到以下网卡设备")
	for _, dev := range devices {
		fmt.Printf("- %s\n", dev.Name)
	}

	device := autoSelectDevice(devices)
	listener(device)
}

// 自动选择网卡
// 参数 devices 网卡列表
func autoSelectDevice(devices []pcap.Interface) string {
	// 优先选择 en0
	for _, d := range devices {
		if d.Name == "en0" {
			return d.Name
		}
	}

	// eth0
	for _, d := range devices {
		if d.Name == "eth0" {
			return d.Name
		}
	}

	// ens3 / ens33
	for _, d := range devices {
		if d.Name == "ens3" || d.Name == "ens33" {
			return d.Name
		}
	}

	return devices[0].Name
}

// 监听
// 参数 device 网卡名称
func listener(device string) {
	fmt.Println("使用网卡监听：", device)
	handle, err := pcap.OpenLive(device, 1600, true, pcap.BlockForever)
	if err != nil {
		log.Fatal("无法使用网卡：", err)
	}
	defer handle.Close()

	// 监听 ICMP
	err = handle.SetBPFFilter("icmp")
	if err != nil {
		log.Fatal("无法设置监听过滤规则：", err)
	}

	fmt.Println("开始监听 ICMP （ping）请求...")
	capturePackets(handle)
}

// 抓包
// 参数 handle 抓包句柄
func capturePackets(handle *pcap.Handle) {
	packetSource := gopacket.NewPacketSource(handle, handle.LinkType())
	for packet := range packetSource.Packets() {

		// 解析 IPv4 层
		ipLayer := packet.Layer(layers.LayerTypeIPv4)
		if ipLayer == nil {
			continue
		}
		ipv4 := ipLayer.(*layers.IPv4)

		// 解析 ICMP 层
		icmpLayer := packet.Layer(layers.LayerTypeICMPv4)
		if icmpLayer == nil {
			continue
		}
		icmp := icmpLayer.(*layers.ICMPv4)

		// Type 8 = Echo Request （来自别人的ping）
		if icmp.TypeCode.Type() == 8 {
			continue
		}

		// 获取时间戳
		ts := packet.Metadata().Timestamp.Format("2006-01-02 15:04:05")

		green := "\033[1;32m"
		cyan := "\033[1;36m"
		reset := "\033[0m"
		fmt.Printf("\n%s[ICMP Echo Request]%s\n", green, reset)
		fmt.Printf("%s时间：%s%s\n", cyan, ts, reset)
		fmt.Printf("%s来源 IP：%s%s\n", cyan, ipv4.SrcIP, reset)
		fmt.Printf("%s目标 IP：%s%s\n", cyan, ipv4.DstIP, reset)
		fmt.Printf("%sTTL：%d%s\n", cyan, ipv4.TTL, reset)
		fmt.Printf("%sID：%d%s\n", cyan, ipv4.Id, reset)
		fmt.Printf("%s协议：ICMPv4%s\n", cyan, reset)
		fmt.Printf("%sICMP 类型：%d (Echo Request)%s\n", cyan, icmp.TypeCode.Type(), reset)
		fmt.Printf("%s序列号：%d%s\n", cyan, icmp.Seq, reset)
		fmt.Printf("%sPayload 长度：%d 字节%s\n", cyan, len(icmp.Payload), reset)
		fmt.Println("------------------------------------")
	}
}
