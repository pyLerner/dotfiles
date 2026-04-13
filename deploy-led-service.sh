#!/bin/bash

git clone https://github.com/pyLerner/CAN-Tablo-Driver.git
cd CAN-Tablo-Driver

service=led-tablo.service
sudo cp $service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable $service
sudo systemctl start $service
