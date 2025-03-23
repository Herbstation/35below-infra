#!/bin/bash
echo "herbstation infrastructure go brr"
set -uex
./update.sh
./compile.sh
./start.sh
