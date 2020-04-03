#!/usr/bin/env bash

# Makes Phlashko-GeoIP if it doesn't exist
if [ ! -d Phlashko-GeoIP ]
	then
		mkdir "Phlashko-GeoIP"
fi

# This checks to see if the argument is entered, is a pcap, and exists
if [ -z "$1" ] || [[ ! $1 == *.pcap ]]
	then
		echo -e ' () ()\n(  >_<) ~ Bad format.  Your syntax should look like ip-geo-checker.sh PcapFile.pcap\n("")("")'
		exit
fi

# This checks to make sure the pcap is in the file with the script
if [ ! -f $1 ]
	then
		echo -e ' () ()\n(  >_<) ~ File does not exist.  Is the pcap in the same folder as the ip-geo-checker.sh script?\n("")("")'
		exit
fi

# Creates Temp Files
echo "" > Phlashko-GeoIP/ipinfo.csv
echo "" > Phlashko-GeoIP/temp.txt

# User Input
srcdst=""
read -p "What do you want to call the results file? : " filesave
clear

while true
do
   read -p "Do you want Geo info of IPs talking to or from a specifc ip? (dst = 3 or src = 5) : " srcdst
   if [ $srcdst == "3" ] || [ $srcdst == "5" ]
   	then
   		break
   	else
   		echo -e ' \n~~~~~Enter 3 for dst or 5 for src~~~~~~\n'
   fi
done

read -p "What is the IP you want to focus on? : " iprange

# This does the Destination GeoIP lookup against the GeoIP.dat
if [ $srcdst == "5" ] 
	then
		tshark -r $1 -Y "ip.src == $iprange" | awk -v srcdst="$srcdst" '{ print $srcdst }' >> temp.txt
       		cat temp.txt | while read line 
			do
				geoiplookup -f /usr/share/GeoIP/GeoIP.dat $line | awk '{print substr($0, index($0,$5))}' | sed 's/[0-9]*//g' >> ipinfo.csv
			done
	else
		tshark -r $1 -Y "ip.dst == $iprange" | awk -v srcdst="$srcdst" '{ print $srcdst }' >> temp.txt
       		cat temp.txt | while read line 
			do
				geoiplookup -f /usr/share/GeoIP/GeoIP.dat $line | awk '{print substr($0, index($0,$5))}' | sed 's/[0-9]*//g' >> ipinfo.csv
			done
fi 

# Sorts then counts
sort ipinfo.csv | uniq -c >> Phlashko-GeoIP/$filesave

# Removes Temp File
rm ipinfo.csv
rm temp.txt

# Congrats, it ran!
echo -e '\n '
cat Phlashko-GeoIP/$filesave
echo -e '\n () ()\n(  ^_^) ~ File has been saved to '$(pwd)'/Phlashko-GeoIP/'$filesave' \n(!!)(!!)\n'
