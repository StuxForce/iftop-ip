#!/bin/bash

#==========================================================
# This script is used to find the top IP addresses
# with max Rx/Tx speed rate
# 
# @author	Denis Pantsyrev <denis.pantsyrev@gmail.com>
# @version	0.2.0 (2019-03-26)
#==========================================================

if [[ "$1" = "" ]]; then
    echo "ERROR! Need to pass interface name, eg. eth0"
    exit 1
fi

if ! [[ -f /usr/sbin/iftop ]]; then
	echo "ERROR! No iftop installed"
	exit 2
fi

declare -A fromIPTrafArray
declare -A fromIPTrafArrayConnections
declare -A toIPTrafArray
declare -A toIPTrafArrayConnections
topLimit=5

# Output starts from left ip and traffic from this ip to right ip,
# then right ip and traffic from this ip to left ip
# so, we need to connect these output to bind traffic "to right ip" and "to left ip"  
for row in $(/usr/sbin/iftop -tnN -s 3 -i $1 -L 4096 2>&1 | egrep "=>|<="\
| awk '{ if ($3 == "=>") {print $2" "$3" "$4} else {print $1" "$2" "$3}}'); do

    # Set current IP
    if [[ $row =~ ([0-9]{1,3}\.?){4} ]]; then
        curIP=$row
        continue
    fi
    
    # Set current tradffic direction
    if [[ $row =~ \=\> ]]; then
        trafDirect=toRight
        curLeftIP=$curIP
        continue
    fi

    if [[ $row =~ \<\= ]]; then
        trafDirect=toLeft
        curRightIP=$curIP
        continue
    fi

    # Parse speed value and transform to Mbit/s
    if [[ $row =~ Mb ]]; then
        speed=${row/Mb/}
    elif [[ $row =~ Kb ]]; then  
        speed=${row/Kb/}
        speed=$(awk -v speed="$speed" 'BEGIN {print speed/1024}')
    else 
        speed=${row/b/} 
        speed=speed=$(awk -v speed="$speed" 'BEGIN {print speed/1024/1024}')
    fi
    
    # Add speed value to suitable array
    if [[ $trafDirect = toRight ]]; then
        fromIPTrafArray["$curLeftIP"]=$(awk -v a="${fromIPTrafArray["$curLeftIP"]}" -v b="$speed" 'BEGIN {print a+b}')
		fromIPTrafArrayConnections["$curLeftIP"]=$(awk -v a="${fromIPTrafArray["$curLeftIP"]}" 'BEGIN {print a+1}')
        # Remember current value because we still don't know right IP
        toRightIPCurTraf=$speed
        continue
    fi

    if [[ $trafDirect = toLeft ]]; then
        fromIPTrafArray["$curRightIP"]=$(awk -v a="${fromIPTrafArray["$curRightIP"]}" -v b="$speed" 'BEGIN {print a+b}')
		fromIPTrafArrayConnections["$curRightIP"]=$(awk -v a="${fromIPTrafArray["$curLeftIP"]}" 'BEGIN {print a+1}')
		toIPTrafArray["$curLeftIP"]=$(awk -v a="${toIPTrafArray["$curLeftIP"]}" -v b="$speed" 'BEGIN {print a+b}')
        toIPTrafArrayConnections["$curLeftIP"]=$(awk -v a="${toIPTrafArray["$curLeftIP"]}" 'BEGIN {print a+1}')
        toIPTrafArray["$curRightIP"]=$(awk -v a="${toIPTrafArray["$curRightIP"]}" -v b="$speed" 'BEGIN {print a+b}')
        toIPTrafArrayConnections["$curRightIP"]=$(awk -v a="${toIPTrafArray["$curRightIP"]}" 'BEGIN {print a+1}')
        continue
    fi

done

# Print results
echo "Top $topLimit traffic receiving IPs at $1 interface:"
for i in "${!toIPTrafArray[@]}"
do
    speed=$(printf "%.2f" ${toIPTrafArray["$i"]})
	count=$(printf "%.0f" ${toIPTrafArrayConnections["$i"]})
    echo "$i <= $speed Mbit/s ($count)"
done | sort -rn -k3 | head -n $topLimit

echo ""

echo "Top $topLimit traffic sending IPs at $1 interface:"
for i in "${!fromIPTrafArray[@]}" 
do 
    speed=$(printf "%.2f" ${fromIPTrafArray["$i"]})
	count=$(printf "%.0f" ${fromIPTrafArrayConnections["$i"]})
    echo "$i => $speed Mbit/s ($count)" 
done | sort -rn -k3 | head -n $topLimit

exit 0
