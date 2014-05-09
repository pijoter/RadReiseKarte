#!/bin/bash

heute=`date +%Y%m%d`
output=/media/Daten/RadReiseKarte
windows=/media/Daten/Garmin
mkgmap=./bin/mkgmap.jar
threads=4

echo "" >> log.log
echo $heute >> log.log
echo "" >> log.log


java -ea -jar $mkgmap --version 2>temp
version=`cat temp`
rm temp

read -p "Update OSM-data? y/n : " update
if [ "$update" == "y" ]; then
	echo `date +%T` updating planet >> log.log
	echo `date +%T` updating planet
	mv ./data/planet.o5m ./data/planet_old.o5m
	osmupdate --verbose ./data/planet_old.o5m ./data/planet.o5m
	split=y
fi
if [ "$split" != "y" ]; then
	read -p "Split OSM-data? y/n : " split
fi

if [ "$split" == "y" ]; then
	rm *.o5m
	echo `date +%T` splitting planet >> log.log
	echo `date +%T` splitting planet
	java -Xmx10000M -XX:+UseCompressedOops -XX:+UseParallelGC -jar ./bin/splitter.jar --status-freq=0 --output=o5m --max-areas=2048 --max-threads=$threads --overlap=0 --keep-complete --split-file=resources/list/Mallorca.list --description=RadReiseKarte ./data/planet.o5m ./data/srtm.o5m> splitter.log
	rm template.args
fi

echo "Map data (c) OpenStreetMap contributors, ODbL (http://opendatacommons.org/licenses/odbl/)" > ./resources/license-mkgmap.txt
echo "Map created with mkgmap-r$version and data of $heute" >> resources/license-mkgmap.txt

echo >mkgmap_error.log

name=Mallorca
famid=1020
codepage=1252

echo `date +%T` generating $name >> log.log
echo `date +%T` generating $name

rm ./maps/$name/*.tmp

echo $famid>>mkgmap_error.log

java -Xmx10000M -XX:+UseCompressedOops -jar $mkgmap --read-config=./resources/style_rrk/options --max-jobs=$threads --code-page=$codepage --mapname=$famid"0001" --overview-mapname=$famid"0000" --family-name="RRK $name" --series-name="RRK $name $heute" --product-version=$heute --description="RadReiseKarte $heute" --family-id=$famid --output-dir=./maps/$name $famid*.o5m ./resources/rrk_typ.txt 2>> mkgmap_error.log

echo `date +%T` compressing $name >> log.log
echo `date +%T` compressing $name

echo "Map data (c) OpenStreetMap and contributors" > ./maps/$name/$famid"0000_license.txt"
echo "http://www.openstreetmap.org/" >> ./maps/$name/$famid"0000_license.txt"
echo "" >> ./maps/$name/$famid"0000_license.txt"
echo "Map data licenced under Open Database License (ODbL) 1.0" >> ./maps/$name/$famid"0000_license.txt"
echo "See http://opendatacommons.org/licenses/odbl/" >> ./maps/$name/$famid"0000_license.txt"
echo "" >> ./maps/$name/$famid"0000_license.txt"
echo "Map created with mkgmap-r$version" >> ./maps/$name/$famid"0000_license.txt"

rm $output/$name.7z
rm $output/MS_$name.7z
rm ./maps/$name/ovm_*.img

7za a -t7z $output/$name.7z ./maps/$name/gmapsupp.img ./resources/license.txt ./resources/legende_de.png -mx9

rm maps/$name/gmapsupp.img

makensis ./maps/$name/$famid"0000.nsi"

cp -rf ./maps/$name/ $windows"/"

7za a -t7z $output/MS_$name.7z ./maps/$name/*.img ./maps/$name/*.mdx ./resources/license.txt ./maps/$name/*.typ ./maps/$name/*.tdb ./maps/$name/Install.exe ./resources/legende_de.png -mx9

rm ./maps/$name/*.img
rm ./maps/$name/*.mdx
rm ./maps/$name/*.typ
rm ./maps/$name/*.tdb
rm ./maps/$name/Install.exe

echo `date +%T` $name finished >> log.log
echo `date +%T` $name finished

echo `date +%T` finished >> log.log
echo `date +%T` finished
echo "" >>log.log