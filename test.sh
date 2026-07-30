#!/usr/bin/env bash

echo "Test for the 3 backends:"
for i in {1..100}; do
	curl -s -H "X-User-ID: $i" http://localhost/;
done > before.txt

echo "Scale it to 4 backends now"
read -r

echo "Test for 4 backends"
for i in {1..100}; do 
	curl -s -H "X-User-ID: $i" http://localhost/;
done > after.txt

echo "Total users remapped to a new server:"
diff -y --suppress-common-lines <(cut -c 1-16 before.txt) <(cut -c 1-16 after.txt) | wc -l
