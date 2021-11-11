#!/bin/bash

num_experiments=1
pox_csv_file=~/mininet-flow-generator/results_pox_controller.csv
def_csv_file=~/mininet-flow-generator/results_default_controller.csv
# export EXPDUR=36
# export EL_FLOWS=5
# export MI_FLOWS=45

sudo rm -rf /home/mininet/Desktop/mininet-log/test*
sudo rm -f $pox_csv_file &> /dev/null
sudo rm -f $def_csv_file &> /dev/null

sudo touch $pox_csv_file
sudo touch $def_csv_file

for (( n=0; n<$num_experiments; n++ ))
do
    cd ~/pox
    sudo ./pox.py forwarding.l2_learning host_tracker openflow.discovery openflow.of_01 --port=6633 &
    echo "********** POX CONTROLLER STARTED **********"

    cd ~/mininet-flow-generator
    filename=/media/sf_Shared/pox.pcap
    # export FLNM=$filename
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
        exec sudo tshark -i "any" -J "OpenFlow_v1" -a duration:36 -w /media/sf_Shared/pox.pcap &
        send "9\n"
        interact
        expect "GEN/CLI/QUIT: "
        send "QUIT\n"
        expect eof
    '

    sleep 2
    ls $filename
    echo "********** TSHARK FINISHED **********"

    sudo pkill -9 -f pox*
    echo "********** POX CONTROLLER KILLED **********"

    sudo echo "Run $n" >> $pox_csv_file
    sudo python stats.py $filename >> $pox_csv_file &
    echo "********** POX CONTROLLER RESULTS SAVED TO FILE **********"
    sudo rm $filename &> /dev/null

    filename=/media/sf_Shared/default.pcap
    # export FLNM=$filename
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
        exec sudo tshark -i "any" -J "OpenFlow_v1" -a duration:36 -w /media/sf_Shared/default.pcap &
        send "9\n"
        interact
        expect "GEN/CLI/QUIT: "
        send "QUIT\n"
        expect eof
    '
    sleep 2
    ls $filename
    echo "********** TSHARK FINISHED **********"

    sudo echo "Run $n" >> $def_csv_file
    sudo python stats.py $filename >> $def_csv_file &
    echo "********** DEFAULT CONTROLLER RESULTS SAVED TO FILE **********"
    sudo rm $filename &> /dev/null
    sudo mn --clean &> /dev/null

    echo "********** ITERATION $n COMPLETE **********"
done
