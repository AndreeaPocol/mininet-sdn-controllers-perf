# Overview:
`measure-controller-overhead.sh` compares the network overhead of various popular Software-Defined Networking (SDN) controllers. 
It analyzes the number and types of packets produced in the network as managed by the default, OVS and POX controllers.

The workload generator used is the Mininet Flow Generator <sup>[1](#mininet-flow-generator)</sup>.
This generates realistic flows which exercise the controllers. Packets are measured using `tshark` 
and examined using Python's `scapy` library. 

We apply the Multiple Interleaved Trials (MIT) methodology to obtain fair and repeatable comparisons in a virtualized environment. 
With MIT, a single round consists of running each alternative once in sequence.

# How to run:
```
./measure-controller-overhead.sh
```

# What is run:
```
for numExperiments do
  for all controller do
    - Cet up  the  controller, starting  it as  a  background
    process if necessary
    - Clean up any existing Mininet topologies
    - Run topo_launcher.py, passing in parameter values using expect at the same time, launch tshark to capture packets for the duration of the topo_launcher.py program
    - Kill the controller, if necessary
    - Run openflow_packet_parser.py on the captured packets
    - Results from all runs are stored in CSV file per
    controller
  end for
end for
```

Note: OpenFlow packets can then be parsed using `openflow_packet_parser.py`, which takes a capture file as the single command-line argument.

# Future work
This script can be extended by the addition of to include more controllers, topologies, workload generators, 
and trials, in order to improve confidence in, and applicability of, results.

<a name="mininet-flow-generator">1</a>: https://github.com/stainleebakhla/mininet-flow-generator/
