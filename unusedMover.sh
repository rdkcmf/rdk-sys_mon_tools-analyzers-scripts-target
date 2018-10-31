#!/bin/sh
##########################################################################
# If not stated otherwise in this file or this component's Licenses.txt
# file the following copyright and licenses apply:
#
# Copyright 2016 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################
#
# $0 : unusedMover.sh is a script to move/remove/list unused objects listed in a file.
# $1 : param1 is a file with a list of unused objects.
# $2 : param2 is a "move"/"remove"/"list" command option.

usage()
{
	echo "$name# Usage : $0 must be executed from the root folder of target rootFS!"
	echo "$name# Usage : $0 param1 param2"
	echo "$name# param1: an input file with a list of unused objects to be moved/removed from the rootFS"
	echo "$name# param2: command option: mv - move; mb - move back; rm - remove; ls - list"
}

name=`basename $0 .sh`
if [ "$1" == "" ] || [ "$2" == "" ]; then
	echo "$name# Error : $0 Params $1 or $2 empty!"
	usage
	exit
fi

if [ ! -e ./version.txt ]; then
	echo "$name# Error : $0 must be executed from the root folder of target rootFS!"
	usage
	exit
else
	rootFS=`cat ./version.txt | grep -i imagename |  tr ': =' ':' | cut -d ':' -f2`
	unusedFS=`basename $1 .h`
	if [ "$rootFS" != "`echo $unusedFS | grep -o $rootFS`" ]; then
		echo "$name# Error   : unused ELF objects FS = $unusedFS doesn't match rootFS = $rootFS !"
		usage
		#exit
	fi
fi

echo "$name# rootFS  : $rootFS"
nf=`cat $1 | awk 'BEGIN{FS=" "}; { print NF }' | head -n 1`
if [ "$nf" -eq 1 ]; then
	#short input file format
	echo "$name# informat: short"
else
	if [ "$nf" -eq 8 ]; then
		#long input file format
		echo "$name# informat: long"
	else
		echo "$name# Error : unknown input file format!"
		exit
	fi
fi

cat $1 | while read line
do
	if [ "$nf" -eq 1 ]; then
		#short input file format
		file=".`echo "$line"`"
	else
		if [ "$nf" -eq 8 ]; then
			#long input file format
			file=".`echo "$line" | tr -s ' ' | cut -d ' ' -f8`"
		else
			echo "$name# Error : unknown input file format!"
			exit
		fi
	fi

	#echo "`ls $file*`"
	case $2 in
		"-mv")
			if [ -e $file ] && [ ! -e $file.tbm ]; then
				echo "$name# mv $file $file.tbm"
				mv $file $file.tbm
			else
				echo "$name# cannot mv $file $file.tbm"
			fi
		;;
		"-mb")
			if [ ! -e $file ] && [ -e $file.tbm ]; then
				echo "$name# mv $file.tbm $file"
				mv $file.tbm $file
			else
				echo "$name# cannot mv $file.tbm $file"
			fi
		;;
		"-rm")
			if [ -e $file.tbm ]; then
				echo "$name# rm $file.tbm"
				rm $file.tbm
			fi
		;;
		"-ls")
			ls -la $file*
		;;
		"*")
			echo "$name# Error : $0 Param $2 is not supported!"
			usage
		;;
	esac
done

