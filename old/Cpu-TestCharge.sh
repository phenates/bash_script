# Cpu-Stress-Test

# Use sysbench paquet for load cpu
# Prints the current state of the CPU like temperature, voltage and speed.
# The temperature is reported in degrees Celsius (C) while
# the CPU speed is calculated in megahertz (MHz).


#!/bin/bash


# Functions
function convert_to_MHz {
    let value=$1/1000
    echo "$value"
}
 
function calculate_overvolts {
    # We can safely ignore the integer
    # part of the decimal argument
    # since it's not realistic to run the Pi
    # at voltages higher than 1.99 V
    let overvolts=${1#*.}-20
    echo "$overvolts"
}



# Main part
t1=$(date +'%s')
echo $t1
timeStart=$(date)
echo
echo "---- Start Stress Test: $timeStart ----"
echo

tempStart=$(vcgencmd measure_temp)
tempStart=${tempStart:5:4}
echo "Temperature:   $tempStart C"
 
volts=$(vcgencmd measure_volts)
volts=${volts:5:4}
if [ $volts != "1.20" ]; then
    overvolts=$(calculate_overvolts $volts)
fi
echo -n "Voltage:       $volts V"
[ $overvolts ] && echo " (+0.$overvolts overvolt)" || echo -e "\r"
 
minFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
minFreq=$(convert_to_MHz $minFreq)
echo "Min speed:     $minFreq MHz"

maxFreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
maxFreq=$(convert_to_MHz $maxFreq)
echo "Max speed:     $maxFreq MHz"
 
freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
freq=$(convert_to_MHz $freq)
echo "Current speed: $freq MHz"
 
governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
echo "Governor:      $governor"

echo
echo "----  ----"
echo

sysbench --test=cpu --num-threads=4 --cpu-max-prime=50000 --max-time=330 run

echo
echo "----  ----"
echo

t2=$(date +'%s')
elapsed=$(($t2-$t1))
timeStop=$(date)
echo
echo "---- Stop Stress Test: $timeStop, Durée: $elapsed ----"
echo

CpuLoad=$(uptime)
CpuLoad=${CpuLoad#*'load average: '}
echo "Cpu Load average last 1/2/5 min  (non normalized):	$CpuLoad"

tempStop=$(vcgencmd measure_temp)
tempStop=${tempStop:5:4}
# deltaTemp=$(($tempStop-$tempStart))
echo "Temperature:   $tempStop C"
 
volts=$(vcgencmd measure_volts)
volts=${volts:5:4}
if [ $volts != "1.20" ]; then
    overvolts=$(calculate_overvolts $volts)
fi
echo -n "Voltage:       $volts V"
[ $overvolts ] && echo " (+0.$overvolts overvolt)" || echo -e "\r"

freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
freq=$(convert_to_MHz $freq)
echo "Current speed: $freq MHz"

echo
echo "---- End ----"
echo

exit 0
