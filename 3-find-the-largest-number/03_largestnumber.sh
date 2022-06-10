#!/bin/bash
COUNT=0
until [[ $COUNT -eq 5 ]] # This command will run until it returns truthy
do
    read -p “Enter a number to find greatest of them :” NUMBER
    echo $NUMBER >> text.txt
    (( COUNT++ ))
done
sort -n text.txt | tail -1