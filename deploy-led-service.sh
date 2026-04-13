#!/bin/bash

DIR=$HOME/CAN-Tablo-Driver

git clone https://github.com/pyLerner/CAN-Tablo-Driver.git $DIR
cd $DIR

service=led-tablo.service
sudo cp $service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable $service
sudo systemctl start $service
