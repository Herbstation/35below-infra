#!/bin/bash
rp_mode=${1}
save_station_z=${2}

build_out=""

if [ "$rp_mode" == "yes" ]; then
	build_out+="
#define RP_MODE"
fi

if [ "$save_station_z" == "yes" ]; then
	build_out+="
#define SAVE_STATION_Z"
fi

echo "$build_out" >> _std/__build.dm