#!/bin/bash

filedefaults=$1
destdir=$2






cd $destdir

for i in $(grep "FFFFFFFFFFFFF " $filedefaults | awk '{print $2}')
do
 converted="01-$(echo $i | tr : -)"
 sed -i "s/$i/$converted/g" $filedefaults
done


for i in $(grep "FFFFFFFFFFFFF " $filedefaults | awk '{print $2}')
do
    sed -n "/$i/,/FFFFFFFFFFFFF/p" all-default | grep -v FFFFFFFFFFFFF > $i
 done

