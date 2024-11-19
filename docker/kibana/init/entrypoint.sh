#!/bin/bash
/usr/share/kibana/bin/kibana &
python3 /usr/local/bin/init_kibana.py
wait