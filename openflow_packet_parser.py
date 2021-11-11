#!/usr/bin/env python3
from scapy.contrib.openflow import _ofp_header

# Suppress warnings about missing IPv6 route and tcpdump bin
import logging

logging.getLogger("scapy.loading").setLevel(logging.ERROR)
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)

from scapy.all import *
import ipaddress
import sys


def computeNumAndSizeOfPacketsInFile(file):
    size = 0
    numPackets = 0

    for packet in file:
        size += len(packet)
        numPackets += 1

    print(
        "Analyzed {packetCount} packets, {size} bytes".format(
            packetCount=numPackets, size=size
        )
    )


def reportPackets(file):
    msg_type_to_count = {}
    for packet in file:
        msg = (packet.summary()).split(" ")
        i = len(msg)
        type = msg[i - 1]
        if "OFPT" in type:
            count = msg_type_to_count.get(type, 0)
            msg_type_to_count[type] = count + 1
    for msg_type, count in msg_type_to_count.items():
        print("{num} packets of type {type}".format(num=count, type=msg_type))


def main():
    pcapFile = ""

    if len(sys.argv) != 2:
        print("Please provide an input file\n")
    else:
        pcapFile = sys.argv[1]

    file = rdpcap(pcapFile)

    computeNumAndSizeOfPacketsInFile(file)
    reportPackets(file)


if __name__ == "__main__":
    main()
