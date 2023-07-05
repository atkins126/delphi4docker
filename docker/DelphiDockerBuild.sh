#!/bin/bash

export TZ=$(cat /etc/timezone)
docker build --build-arg TZ=$TZ \
             -t delphi:0.0.1-alpha \
             -f DelphiDockerfile\
             .            		   
