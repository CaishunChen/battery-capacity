#!/bin/sh

mv "$2" "$3.csv"
mv "$3.csv" "/home/nathanpc/Developer/Statistics/Battery-Capacity/data/$1/"

# TODO: Add a new line to the index.csv

