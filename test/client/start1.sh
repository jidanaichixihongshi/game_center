#!/bin/bash

localip=`/sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'` \
NODE="game_center_client1"
NODENAME="$NODE@$localip"

erl -pa ebin deps/*/ebin\
		-config config/sys1.config \
		-name $NODENAME \
		-setcookie game_center_client \
		-s game_center_client

