#!/usr/bin/env bash
# By default aug value is 10. if you want overwrite the default value, just pass the arg value while executing the gencsv.sh script.
# Generated output will store in inputFile
# rm /tmp/solution/inpuFile

for (( i = 0; i < ${1:-10}; i++ )); do
echo "$i, $RANDOM" >> inputFile
done
chmod +r inputFile
