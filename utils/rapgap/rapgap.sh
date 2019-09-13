#! /usr/bin/env bash

### usage: ./rapgap.sh --help

###
seed=123456789
output=rapgap.hepmc
params=$RAPGAP_ROOT/share/steer-pp

while [ ! -z "$1" ]; do
    option="$1"
    shift
    if [ "$option" = "--help" ]; then
	echo "usage: ./rapgap.sh"
	echo "options:"
	echo "          --output     [output filename] ($output)"
	echo "          --seed       [random seed] ($seed)"
	echo "          --params     [parameters filename] ($params)"
	exit
    elif [ "$option" = "--output" ]; then
	output="$1"
	shift
    elif [ "$option" = "--seed" ]; then
	seed="$1"
	shift
    elif [ "$option" = "--params" ]; then
	params="$1"
	shift
    fi
done

export RASEED=$seed
export HEPMCOUT=$output

rapgap_hepmc < $params

