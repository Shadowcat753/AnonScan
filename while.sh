#!/bin/bash

if [ EUID != 0 ]; then
	echo "Run as root only please!"
	exit 0
fi


read -p "Enter password: " pass

while [ "$pass" != "roncha123" ]; do
	read -p "Password incorrect, try again: " pass
done

echo "Welcome back!"
