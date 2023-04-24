#!/bin/env bash

# Copyright (c) 2013 Altera Corporation. All rights reserved.

# Your use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any output files
# any of the foregoing (including device programming or simulation files), and
# any associated documentation or information are expressly subject to the terms
# and conditions of the Altera Program License Subscription Agreement, Altera
# MegaCore Function License Agreement, or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose of
# programming logic devices manufactured by Altera and sold by Altera or its
# authorized distributors.  Please refer to the applicable agreement for
# further details.

# Check if we are running on a supported version of Linux distribution with pre-requisite packages installed.
# Both RedHat and CentOS have the /etc/redhat-release file.
unsupported_os=0
is_rhel_or_centos=0
missing_package=0

if [ -f /etc/redhat-release ] ;then
	os_version=`cat /etc/redhat-release | grep release | sed -e 's/ (.*//g'`
	os_platform=`echo ${os_version} | grep "Red Hat Enterprise" || echo ${os_version} | grep "CentOS"`

	if [ "$os_platform" != "" ] ;then

		is_rhel_or_centos=1
		os_rev=`echo ${os_version} | grep "release 3" || echo ${os_version} | grep "release 4"`
		if [ "$os_rev" != "" ] ;then
			unsupported_os=1
		fi
	fi
elif [ -f /etc/SuSE-release ] ;then
	os_version=`cat /etc/SuSE-release`
	os_platform=`echo ${os_version} | grep SUSE`
	if [ "$os_platform" != "" ] ;then
		os_rev=`echo ${os_version} | grep "VERSION = 10"`
		if [ "$os_rev" != "" ] ;then
			os_version=`cat /etc/SuSE-release | tr "\n" ' '| sed -e 's/ VERSION.*//g'`
			unsupported_os=1
		fi
	fi
fi

if [ $unsupported_os -eq 1 ] ;then
	echo ""
	echo "Altera software is not supported on the $os_version operating system. Refer to the Operating System Support page of the Altera website for complete operating system support information."
	echo ""

	answer="n"
	while [ "$answer" != "y" ]
	do
		echo -n "Do you want to continue to install the software? (y/n): "
		read answer

		if [ "$answer" = "n" ] ;then
			exit
		fi
	done
fi

if [ $is_rhel_or_centos -eq 1 ] ;then
	for item in libstdc++ glibc libX11 libXext libXau libXdmcp freetype fontconfig expat
	do
		if test -z `rpm -q $item --qf "%{n}-%{arch}\n"| grep "i386\|i486\|i586\|i686"` ; then
			if [ $missing_package -eq 0 ] ;then
				missing_package=1
				echo ""
				echo "You must install the 32-bit version of the following libraries for the Quartus II installer and software to operate properly:"
			fi
			echo "> $item"
		fi
	done

else
	machine_bitness=`uname -m`
	if [ "$machine_bitness" == "x86_64" ] ;then
		echo ""
		echo "You must have the 32-bit compatibility libraries installed for the Quartus II installer and software to operate properly."
		echo ""
	fi
fi

if [ $missing_package -eq 1 ] ;then
	echo ""
	echo "You can install these libraries with the RPM utility on Red Hat Linux Enterprise systems or with the yum utility on CentOS systems. Refer to the Altera Software Installation and Licensing Manual for any additional libraries required by Altera Software."
	echo ""
	echo "If you proceed with the installation your software may not function correctly."
	echo ""

	answer="n"
	while [ "$answer" != "y" ]
	do
		echo -n "Do you want to continue to install the software? (y/n): "
		read answer

		if [ "$answer" = "n" ] ;then
			exit
		fi
	done
fi

export SCRIPT_PATH=`dirname "$0"`
export CMD_NAME="$SCRIPT_PATH/components/QuartusSetupWeb-13.1.0.162.run"
eval exec "\"$CMD_NAME\"" $@
