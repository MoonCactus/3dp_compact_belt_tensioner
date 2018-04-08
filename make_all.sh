#!/bin/bash
set +x 
mkdir -p stl/

for offset in 0 2.5; do
	for what in exploded plunger ring body; do
		outfile="stl/txy_bt_${what}_${offset}.stl"
		echo "Building $outfile..."
		openscad txy_belt_tensioner.scad \
			-D "belt_offset=\"$offset\"" \
			-D "print_what=\"$what\"" \
			-o $outfile
	done
done 
