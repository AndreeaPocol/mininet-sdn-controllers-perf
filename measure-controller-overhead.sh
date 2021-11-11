#!/bin/bash

# export EXPDUR=36
# export EL_FLOWS=5
# export MI_FLOWS=45

num_experiments=1

pox_csv_file=~/mininet-flow-generator/results_pox_controller.csv
def_csv_file=~/mininet-flow-generator/results_default_controller.csv
ovsc_csv_file=~/mininet-flow-generator/results_ovs_controller.csv
captureFileDefaultController=/media/sf_Shared/default.pcap
captureFilePoxController=/media/sf_Shared/pox.pcap
captureFileOvscController=/media/sf_Shared/ovsc.pcap

sudo rm -rf /home/mininet/Desktop/mininet-log/test*
sudo rm -f $pox_csv_file &> /dev/null
sudo rm -f $def_csv_file &> /dev/null
sudo rm -f $ovsc_csv_file &> /dev/null

sudo touch $pox_csv_file
sudo touch $def_csv_file
sudo touch $ovsc_csv_file

for (( n=0; n<$num_experiments; n++ ))
do
    sudo rm $captureFileDefaultController &> /dev/null
    sudo rm $captureFilePoxController &> /dev/null
    sudo rm $captureFileOvscController &> /dev/null

    cd ~/pox
    sudo ./pox.py forwarding.l2_learning host_tracker openflow.discovery openflow.of_01 --port=6633 &
    echo "********** POX CONTROLLER STARTED **********"

    cd ~/mininet-flow-generator
    # export FLNM=$captureFilePoxController
    sudo mn --clean &> /dev/null
    echo "********** CLEANUP COMPLETE **********"
    echo "********** STARTING TRAFFIC **********"
    sudo expect -c '
        spawn sudo python topo_launcher.py --controller=remote,ip=127.0.0.1 --topo=linear,5
        expect "GEN/CLI/QUIT: "
        send "GEN\n"
        expect "Experiment duration: "
        send "36\n"
        expect "No of elephant flows: "
        send "1\n"
        expect "No of mice flows: "
        exec sudo tshark -i "any" -f "tcp port 6633" -a duration:180 -w /media/sf_Shared/pox.pcap &
        send "45\n"
        interact
    '

    sleep 2
    echo "********** TSHARK FINISHED **********"

    sudo pkill -9 -f pox*
    echo "********** POX CONTROLLER KILLED **********"

    sudo echo "Run $n" >> $pox_csv_file
    sudo python stats.py $captureFilePoxController >> $pox_csv_file &
    echo "********** POX CONTROLLER RESULTS SAVED TO FILE **********"

############################## OVS ###############################

    cd ~/mininet-flow-generator
    # export FLNM=$captureFileOvscController
    sudo mn --clean &> /dev/null
    echo "********** CLEANUP COMPLETE **********"
    echo "********** STARTING TRAFFIC **********"
    sudo expect -c '
        spawn sudo python topo_launcher.py --controller=ovsc,ip=127.0.0.1 --topo=linear,5
        expect "POX/OVSC: "
        send "OVSC\n"
        expect "GEN/CLI/QUIT: "
        send "GEN\n"
        expect "Experiment duration: "
        send "180\n"
        expect "No of elephant flows: "
        send "5\n"
        expect "No of mice flows: "
        exec sudo tshark -i "any" -f "tcp port 6633" -a duration:180 -w /media/sf_Shared/ovsc.pcap &
        send "45\n"
        interact
    '

    sleep 2
    echo "********** TSHARK FINISHED **********"

    sudo echo "Run $n" >> $ovsc_csv_file
    sudo python stats.py $captureFileOvscController >> $ovsc_csv_file &
    echo "********** OVS CONTROLLER RESULTS SAVED TO FILE **********"

############################### DEFAULT ###############################

    # export FLNM=$captureFileDefaultController
    sudo mn --clean &> /dev/null
    echo "********** CLEANUP COMPLETE **********"
    echo "********** STARTING TRAFFIC **********"
    sudo expect -c '
        spawn sudo python topo_launcher.py --topo=linear,5
        expect "GEN/CLI/QUIT: "
        send "GEN\n"
        expect "Experiment duration: "
        send "36\n"
        expect "No of elephant flows: "
        send "1\n"
        expect "No of mice flows: "
        exec sudo tshark -i "any" -f "tcp port 6653" -a duration:180 -w /media/sf_Shared/default.pcap &
        send "45\n"
        interact
    '
    sleep 2
    echo "********** TSHARK FINISHED **********"

    sudo echo "Run $n" >> $def_csv_file
    sudo python stats.py $captureFileDefaultController >> $def_csv_file &
    echo "********** DEFAULT CONTROLLER RESULTS SAVED TO FILE **********"

    sudo mn --clean &> /dev/null

    echo "********** ITERATION $n COMPLETE **********"
done
