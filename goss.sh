#!/bin/bash
# MadStu's Small Install Script
cd ~
wget https://raw.githubusercontent.com/MadStu/GOSS/master/newgossmn.sh
chmod 777 newgossmn.sh
sed -i -e 's/\r$//' newgossmn.sh
./newgossmn.sh
