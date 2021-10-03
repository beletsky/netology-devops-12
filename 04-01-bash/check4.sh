#!/usr/bin/env bash

hosts=(192.168.0.1 173.194.222.113 87.250.250.242)

for cur in {0..4}
do
  for host in ${hosts[@]}
  do
    if nc -zw1 $host 80
    then
      echo "$host accessible" >> log
    else
      echo "$host" > error
      exit
    fi
  done
done
