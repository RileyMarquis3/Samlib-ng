#!/bin/bash
#This library of Shell Accessible Modules is Copyright 1997-2003
#by William Stearns <wstearns@pobox.com>
#
#To include these functions in your shell script, enter the following:
#if [ -f /usr/lib/samlib/samlib ]; then
#	. /usr/lib/samlib/samlib
#else
#	echo "/usr/lib/samlib/samlib is missing - please get it from" >&2
#	echo "http://www.stearns.org/samlib/" >&2
#	echo "Exiting." >&2
#	exit 1
#fi
#for ONEFUNC in    list needed functions here   ; do
#	if ! type $ONEFUNC >/dev/null 2>/dev/null ; then
#		echo "Missing $ONEFUNC , please update samlib from" >&2
#		echo "http://www.stearns.org/samlib/" >&2
#		echo "Exiting." >&2
#		exit 1
#	fi
#done
#Checks done on the above: 1-3,5-7,9-16
#
#To make them available in your running shell, type:
#. /usr/lib/samlib/samlib

#Checks:
# 1. Sudo/askfirst checked; no root assumptions.
# 2. Standalone - no requirements of pre-existing functions
# 3. Support apps explicitly listed and Prereq'd in spec file
# 4. Regression test function for each function, listed in REGRESSIONTESTS
# 5. Only load tests if regression test requested.
# 6. Conditional functions based on whether support apps available or a fallback needed.
# 7. No assumptions about initialized variables.
# 8. Local variables if possible.
# 9. No modification of global variables.
#10. Hell, not even _use_ of global variables.
#11. No side effects to the system.
#12. Careful use of >&2 for status/errors.
#13. No assumptions that paths exist.
#14. Use mktemp if available, warn and fallback if not.
#15. Example calls in header.
#16. Quote variables to handle unset/null case.
#17. Debian "must return true" requirement checked.
#99. Header to show inputs, outputs, return codes, exceptions to the above, programs that are known to use this function.

#Programs known to use this library: buildkernel >= 1.04, Mason >= 0.13.9.4, mkrootfs.
#Programs that should: ramenfind, uml loader, ssh-keyinstall


#Future:
#- don't assume[/usr]/[s]bin in path
#FIXME - resolve SUDO vs PRECOMMAND.
#FIXME - do a requireutil $SUDO when SUDO assigned.
#FIXME - replacement mktemp if the real mktemp isn't on the system.

#Regression test template
#if [ "$DOREGRESSIONTEST" = "YES" ]; then
	#echo -n func...
	#Should return true
	#if !   ; then						error func-tx ; fi
	#Should return false
	#if   ; then						error func-fx ; fi
	#General return values
	#if [ ! `` = "" ]; then					error func-x ; fi
#fi



SAMVER="0.3.1, 5/1/2003"


if [ "${1}" = "regression-test" ]; then
	DOREGRESSIONTEST=YES
	#Checks done on the following function: 
	error () {
		echo 
		echo Failed test: $*
		if [ -d /usr/src/samlib-work ]; then
			echo Failed test: $* on $SAMVER >>/usr/src/samlib-work/regression-log
		fi
		echo -n -e "\a" >&2
		sleep 1
		echo -n -e "\a" >&2
		sleep 1
		echo -n -e "\a" >&2
		exit 1
	}
fi
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	#Internal check.  If you want to check that the error function actually catches failures, uncomment the following.
	#if ! false ; then									error testfail ; fi
	echo -n samver...
	if [ -z "$SAMVER" ]; then								error samver ; fi
fi


# Near the top of the library as some of the following functions call this
# to register their own needed functions.
#-------------------------------------------------------------------------
# requireutil function, makes sure that the needed external program(s)
# (listed on the command line) is/are in the path and executable.
# Correctly handles the case where the utility is a shell function.
# Example use:
#	requireutil ls || exit 1
#-------------------------------------------------------------------------
#Checks done on the following function: 
requireutil () {
	while [ -n "$1" ]; do
		if ! type -path "$1" >/dev/null 2>/dev/null ; then
			echo Missing utility "$1". Please install it. >&2
			return 1	#False, app is not available.
		fi
		shift
	done
	return 0	#True, app is there.
} #End of requireutil
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n requireutil...
	if ! requireutil ls ; then								error requireutil-t1 ; fi
	if requireutil wehwegtgwerbcvhjdsbf 2>/dev/null ; then					error requireutil-f1 ; fi
	#I think only debian includes that one... ;-)
fi


#ZZZZ
if /bin/false ; then	#Under development, hardly even complete.


#-------------------------------------------------------------------------
# mktemp replacement; creates a temporary file.  Used only if the system
# does not have an mktemp program.
#-------------------------------------------------------------------------
if ! type -path mktemp >/dev/null 2>/dev/null ; then
	echo 'Warning!  This system does not have mktemp program.  I will install' >&2
	echo 'a replacement, but it is not secure.  Please install the mktemp' >&2
	echo 'package.' >&2
	#Checks done on the following function: 
	mktemp () {
		if [ $# = 0 ]; then
			echo Too few parameters to mktemp, exiting. >&2
			return 1
		fi
		while [ -n "$1" ]; do
			case "$1" in
			-d)
				:
				shift
				;;
			-q)
				:
				shift
				;;
			-u)
				:
				shift
				;;
			*)
				BASEFILE="$1"			
				shift
				;;
			esac
		
		done
		if [ ! -d /tmp ]; then
			echo Missing /tmp directory, please create and restart. Mktemp Exiting. >&2
			return 1
		fi
		TEMPFILE=/tmp/file.$$.$RANDOM		#<-- Yes, this is a race condition.
		while [ -e $TEMPFILE ]; do		#
			TEMPFILE=/tmp/file.$$.$RANDOM	#    That's why I suggest they get a real mktemp.
		done					#
		touch $TEMPFILE				#<-- Oh well.
		
		#if some_check_that_a_file_was_actually_created ; then
			echo $TEMPFILE
			return 0
		#else
			#return 1
		#fi
	}
fi


fi


#-------------------------------------------------------------------------
# addline procedure, appends $2 to the end of file $1.
#-------------------------------------------------------------------------
#Params: $1 File that needs the additional line, $2 line to add.
requireutil cat $SUDO grep printf mktemp rm dd touch || exit 1	#umask is a shell builtin.
#Checks done on the following function: 
addline() {
	if [ "$#" != "2" ]; then
		echo Incorrect number of arguments to addline! >&2
	else
		#case "$1" in
		#/*)
		#    echo Filename is not relative in addline! >&2
		#    ;;
		#*)
		if $SUDO [ -f "$1" ] && $SUDO cat "$1" | grep -q "^$2\$" ; then
			echo \"$2\" is already in $1 - not adding again. >&2
		else
			printf "%-3s%-40s%-50s\n" '+' "$1" "$2"		#Was: echo Adding \"$2\" to $1
			if $SUDO [ -f $1 ]; then
				OLDUMASK=`umask`
				umask 177
				TMPFILE=`mktemp -q /tmp/addline.XXXXXX`
				if [ $? -ne 0 ]; then
					echo "$0: Can't create temp file, exiting..."
					exit 1
				fi
				#Yes, this is ugly, but _you_ try getting sudo to allow you to append as root as well!
				#$SUDO echo "$2" >>$1	- doesn't work.
				$SUDO cat "$1" >"$TMPFILE"
				echo "$2" | cat "$TMPFILE" - | $SUDO dd of="$1" 2>/dev/null
				$SUDO rm -f "$TMPFILE"
				umask $OLDUMASK
			else
				$SUDO touch "$1"
				echo "$2" | $SUDO dd of="$1" 2>/dev/null
			fi
		fi
		#    ;;
		#esac
	fi
} #End of addline
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n addline...
	REGRESSTESTFILE=`mktemp -q /tmp/$1.XXXXXX`
	if [ $? -ne 0 ]; then
		echo "$0: Can't create regression temp file, exiting..."
		exit 1
	fi
	addline $REGRESSTESTFILE "A line of text" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"A line of text" \
	]; then											error addline-1 ; fi
	addline $REGRESSTESTFILE "A new line of text" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"A line of text
A new line of text" \
	]; then											error addline-2 ; fi
	rm -f $REGRESSTESTFILE
fi


#-------------------------------------------------------------------------
# askYN function, returns true or false depending on user input.
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
askYN () {	#SUDO checked
	TESTYN=""
	while [ "$TESTYN" != 'Y' ] && [ "$TESTYN" != 'N' ] ; do
		echo -n '?' >&2
		read TESTYN || :
		case $TESTYN in
		T*|t*|Y*|y*)		TESTYN='Y'	;;
		F*|f*|N*|n*)		TESTYN='N'	;;
		esac
	done

	if [ "$TESTYN" = 'Y' ]; then
		return 0 #True
	else
		return 1 #False
	fi
} #End of askYN
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n askYN...
	if ! echo 'Y' | askYN 2>/dev/null ; then						error askYN-t1 ; fi
	if ! echo 'y' | askYN 2>/dev/null ; then						error askYN-t2 ; fi
	if ! echo 'T' | askYN 2>/dev/null ; then						error askYN-t3 ; fi
	if ! echo 't' | askYN 2>/dev/null ; then						error askYN-t4 ; fi
	if ! echo 'yES' | askYN 2>/dev/null ; then						error askYN-t5 ; fi
	if ! echo 'true' | askYN 2>/dev/null ; then						error askYN-t6 ; fi
	if echo 'N' | askYN 2>/dev/null ; then							error askYN-f1 ; fi
	if echo 'n' | askYN 2>/dev/null ; then							error askYN-f2 ; fi
	if echo 'F' | askYN 2>/dev/null ; then							error askYN-f3 ; fi
	if echo 'f' | askYN 2>/dev/null ; then							error askYN-f4 ; fi
	if echo 'No' | askYN 2>/dev/null ; then							error askYN-f5 ; fi
	if echo 'FALSE' | askYN 2>/dev/null ; then						error askYN-f6 ; fi
fi


#-------------------------------------------------------------------------
# bits2mask function, returns the netmask for the number of bits parameter.
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
bits2mask () {
	case $1 in
	32|*/32)	echo 255.255.255.255	;;
	31|*/31)	echo 255.255.255.254	;;
	30|*/30)	echo 255.255.255.252	;;
	29|*/29)	echo 255.255.255.248	;;
	28|*/28)	echo 255.255.255.240	;;
	27|*/27)	echo 255.255.255.224	;;
	26|*/26)	echo 255.255.255.192	;;
	25|*/25)	echo 255.255.255.128	;;

	24|*/24)	echo 255.255.255.0	;;
	23|*/23)	echo 255.255.254.0	;;
	22|*/22)	echo 255.255.252.0	;;
	21|*/21)	echo 255.255.248.0	;;
	20|*/20)	echo 255.255.240.0	;;
	19|*/19)	echo 255.255.224.0	;;
	18|*/18)	echo 255.255.192.0	;;
	17|*/17)	echo 255.255.128.0	;;

	16|*/16)	echo 255.255.0.0	;;
	15|*/15)	echo 255.254.0.0	;;
	14|*/14)	echo 255.252.0.0	;;
	13|*/13)	echo 255.248.0.0	;;
	12|*/12)	echo 255.240.0.0	;;
	11|*/11)	echo 255.224.0.0	;;
	10|*/10)	echo 255.192.0.0	;;
	9|*/9)		echo 255.128.0.0	;;

	8|*/8)		echo 255.0.0.0		;;
	7|*/7)		echo 254.0.0.0		;;
	6|*/6)		echo 252.0.0.0		;;
	5|*/5)		echo 248.0.0.0		;;
	4|*/4)		echo 240.0.0.0		;;
	3|*/3)		echo 224.0.0.0		;;
	2|*/2)		echo 192.0.0.0		;;
	1|*/1)		echo 128.0.0.0		;;
	0|*/0)		echo 0.0.0.0		;;
	*)		echo 255.255.255.255	;;
	esac
} #End of bits2mask
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n bits2mask...
	#General return values
	if [ ! `bits2mask` = "255.255.255.255" ]; then						error bits2mask-1 ; fi
	if [ ! `bits2mask 5` = "248.0.0.0" ]; then						error bits2mask-2 ; fi
	if [ ! `bits2mask 1/30` = "255.255.255.252" ]; then					error bits2mask-3 ; fi
fi


#-------------------------------------------------------------------------
# broadcastof function, returns the broadcast of the given ip and netmask.
#-------------------------------------------------------------------------
requireutil bits2mask || exit 1
#Checks done on the following function: 
broadcastof () {
#The broadcast is (ip bitwise-or (255.255.255.255-netmask))
	CKPTBROADCASTOF=" broadcastof: Start $1 mask $2" ; #ckpt $CKPTBROADCASTOF

	case $2 in
	32|255.255.255.255)	echo $1									;;
	0|0.0.0.0)			echo 255.255.255.255					;;
	*)
		SPLITIP=$1
		I1O1=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O2=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O3=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O4=$SPLITIP
		case $2 in
		[0-9]|[1-2][0-9]|3[0-2])	SPLITIP=`bits2mask $2`			;;
		*)							SPLITIP=$2						;;
		esac
		I2O1=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O2=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O3=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O4=$SPLITIP
	
		echo $[ $I1O1 | (255-$I2O1) ].$[ $I1O2 | (255-$I2O2) ].$[ $I1O3 | (255-$I2O3) ].$[ $I1O4 | (255-$I2O4) ]
																;;
	esac

	CKPTBROADCASTOF=""
} #End of broadcastof
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n broadcastof...
	if [ ! `broadcastof 0.0.0.0 0.0.0.0` = "255.255.255.255" ]; then			error broadcastof-1 ; fi
	if [ ! `broadcastof 1.2.3.4 255.255.255.0` = "1.2.3.255" ]; then			error broadcastof-2 ; fi
	if [ ! `broadcastof 15.1.2.3 255.0.0.0` = "15.255.255.255" ]; then			error broadcastof-3 ; fi
	if [ ! `broadcastof 1.2.3.4 128.0.0.0` = "127.255.255.255" ]; then			error broadcastof-4 ; fi
fi


#-------------------------------------------------------------------------
# delline procedure, removes all lines matching $2 from the given file $1.
#-------------------------------------------------------------------------
requireutil cat $SUDO grep mktemp dd printf rm || exit 1
#Checks done on the following function: 
delline() {
#Params: $1 File that needs the line removed, $2 line to remove (may be a partial line).
#Example: delline somefile '.*'		#Remove all lines, essentially ">somefile" but using sudo.
	if [ "$#" != "2" ]; then
		echo Incorrect number of arguments to delline! >&2
	else
		#case "$1" in
		#/*)
		#    echo Filename is not relative in delline! >&2
		#    ;;
		#*)
		if $SUDO [ ! -f "$1" ]; then
			echo "$1" doesn\'t exist, can\'t remove \"$2\". >&2
#FIXME - does this allow a partial line?
		elif $SUDO cat "$1" | grep -q "$2" ; then
			OLDUMASK=`umask`
			umask 177
			TMPFILE=`mktemp -q /tmp/delline.XXXXXX`
			if [ $? -ne 0 ]; then
				echo "$0: Can't create temp file, exiting..."
				exit 1
			fi
			$SUDO cat "$1" >"$TMPFILE"
			cat "$TMPFILE" | grep -v "$2" | $SUDO dd of="$1" 2>/dev/null
			printf "%1s%-2s%-40s%-50s\n" '-' "$[ `$SUDO cat "$TMPFILE" | wc -l` - `$SUDO cat "$1" | wc -l` ]" "$1" "$2"
			#Was: echo -n "Removing \"$2\" from $1; " ; echo $[ `$SUDO cat "$TMPFILE" | wc -l` - `$SUDO cat "$1" | wc -l` ] lines removed.
			$SUDO rm -f "$TMPFILE"
			umask $OLDUMASK
		else
			echo \"$2\" is not in "$1" - not removing. >&2
		fi
		#    ;;
		#esac
	fi
}
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n delline...
	REGRESSTESTFILE=`mktemp -q /tmp/$1.XXXXXX`
	if [ $? -ne 0 ]; then
		echo "$0: Can't create regression temp file, exiting..."
		exit 1
	fi
	echo Line 1 >$REGRESSTESTFILE
	echo Line 2 >>$REGRESSTESTFILE
	echo Line 3 >>$REGRESSTESTFILE
	echo Line 4 >>$REGRESSTESTFILE
	echo Line 5 >>$REGRESSTESTFILE
	delline $REGRESSTESTFILE "Line 4" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 1
Line 2
Line 3
Line 5" \
	]; then											error delline-1 ; fi
	delline $REGRESSTESTFILE "Isnt in the file" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 1
Line 2
Line 3
Line 5" \
	]; then											error delline-2 ; fi
	delline $REGRESSTESTFILE "3" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 1
Line 2
Line 5" \
	]; then											error delline-3 ; fi
	delline $REGRESSTESTFILE "Line 1" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 2
Line 5" \
	]; then											error delline-4 ; fi
	delline $REGRESSTESTFILE "Line 5" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 2" \
	]; then											error delline-5 ; fi
	rm -f $REGRESSTESTFILE
fi


#-------------------------------------------------------------------------
# ipeq function, returns true/false: ip addresses are equal? 
#-------------------------------------------------------------------------
#Not currently used...
#No external apps needed.
#Checks done on the following function: 
ipeq () {	#SUDO checked
	if [ "$1" = "$2" ]; then
		return 0	#True
	else
		SPLITIP=$1
		I1O1=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O2=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O3=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O4=$SPLITIP
		SPLITIP=$2
		I2O1=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O2=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O3=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O4=$SPLITIP
	
		if [ $I1O1 -eq $I2O1 ] && [ $I1O2 -eq $I2O2 ] && [ $I1O3 -eq $I2O3 ] && [ $I1O4 -eq $I2O4 ]; then
			return 0 #True
		else
			return 1 #False
		fi
	fi
} #End of ipeq
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n ipeq...
	if ! ipeq 1.1.1.1 1.1.1.1 ; then							error ipeq-t1 ; fi
	if ! ipeq 255.255.255.255 255.255.255.255 ; then					error ipeq-t2 ; fi
	if ipeq 1.1.1.1 1.2.3.4 ; then								error ipeq-f1 ; fi
fi


#-------------------------------------------------------------------------
# iple function, returns true (0) if first IP <= second IP, else false(1)
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
iple () {	#SUDO checked
#if iple 128.2.3.4 127.0.0.1 ; then echo less than or eq >&2 ; else echo gt >&2 ; fi
	if [ "$1" = "$2" ]; then
		CKPTIPLE="" ; return 0	#True
	else
		CKPTIPLE=" iple: start, addresses $1 and $2" ; #ckpt $CKPTIPLE

		SPLITIP1=$1 ;			I1O1=${SPLITIP1%%.*}
		SPLITIP2=$2 ;			I2O1=${SPLITIP2%%.*}
		  if [ $I1O1 -lt $I2O1 ]; then	CKPTIPLE="" ; return 0
		elif [ $I1O1 -gt $I2O1 ]; then	CKPTIPLE="" ; return 1
		fi

		SPLITIP1=${SPLITIP1#*.} ;	I1O2=${SPLITIP1%%.*}
		SPLITIP2=${SPLITIP2#*.} ;	I2O2=${SPLITIP2%%.*}
		  if [ $I1O2 -lt $I2O2 ]; then	CKPTIPLE="" ; return 0
		elif [ $I1O2 -gt $I2O2 ]; then	CKPTIPLE="" ; return 1
		fi

		SPLITIP1=${SPLITIP1#*.} ;	I1O3=${SPLITIP1%%.*}
		SPLITIP2=${SPLITIP2#*.} ;	I2O3=${SPLITIP2%%.*}
		  if [ $I1O3 -lt $I2O3 ]; then	CKPTIPLE="" ; return 0
		elif [ $I1O3 -gt $I2O3 ]; then	CKPTIPLE="" ; return 1
		fi

		SPLITIP1=${SPLITIP1#*.} ;	I1O4=$SPLITIP1
		SPLITIP2=${SPLITIP2#*.} ;	I2O4=$SPLITIP2
		  if [ $I1O4 -lt $I2O4 ]; then	CKPTIPLE="" ; return 0
		elif [ $I1O4 -gt $I2O4 ]; then	CKPTIPLE="" ; return 1
		else				CKPTIPLE="" ; return 0
		fi
	fi
} #End of iple
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n iple...
	if ! iple 12.13.14.15 12.13.14.15 ; then						error iple-t1 ; fi
	if ! iple 12.13.14.15 12.13.14.16 ; then						error iple-t2 ; fi
	if ! iple 0.0.0.0 12.13.14.15 ; then							error iple-t3 ; fi
	if ! iple 0.0.0.0 255.255.255.255 ; then						error iple-t4 ; fi
	if ! iple 12.11.11.11 12.44.45.46 ; then						error iple-t5 ; fi
	if ! iple 12.11.11.11 12.11.45.46 ; then						error iple-t6 ; fi
	if ! iple 12.11.11.11 12.11.11.46 ; then						error iple-t7 ; fi
	if iple 12.13.14.16 12.13.14.15 ; then							error iple-f1 ; fi
	if iple 12.13.14.15 0.0.0.0 ; then							error iple-f2 ; fi
	if iple 255.255.255.255 0.0.0.0 ; then							error iple-f3 ; fi
	if iple 12.44.45.46 12.11.11.11 ; then							error iple-f4 ; fi
fi


#-------------------------------------------------------------------------
# iplt function, returns true (0) if first IP < second IP, else false(1)
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
iplt () {	#SUDO checked
#if iplt 128.2.3.4 127.0.0.1 ; then echo less than >&2 ; else echo ge >&2 ; fi
#As a speedup, only come up with the individual numbers as they are needed.
	if [ "$1" = "$2" ]; then
		CKPTIPLT="" ; return 1	#False
	else
		CKPTIPLT=" iplt: start, addresses $1 and $2" ; #ckpt $CKPTIPLT

		SPLITIP1=$1 ;			I1O1=${SPLITIP1%%.*}
		SPLITIP2=$2 ;			I2O1=${SPLITIP2%%.*}
		  if [ $I1O1 -lt $I2O1 ]; then	CKPTIPLT="" ; return 0
		elif [ $I1O1 -gt $I2O1 ]; then	CKPTIPLT="" ; return 1
		fi

		SPLITIP1=${SPLITIP1#*.} ;	I1O2=${SPLITIP1%%.*}
		SPLITIP2=${SPLITIP2#*.} ;	I2O2=${SPLITIP2%%.*}
		  if [ $I1O2 -lt $I2O2 ]; then	CKPTIPLT="" ; return 0
		elif [ $I1O2 -gt $I2O2 ]; then	CKPTIPLT="" ; return 1
		fi

		SPLITIP1=${SPLITIP1#*.} ;	I1O3=${SPLITIP1%%.*}
		SPLITIP2=${SPLITIP2#*.} ;	I2O3=${SPLITIP2%%.*}
		  if [ $I1O3 -lt $I2O3 ]; then	CKPTIPLT="" ; return 0
		elif [ $I1O3 -gt $I2O3 ]; then	CKPTIPLT="" ; return 1
		fi

		SPLITIP1=${SPLITIP1#*.} ;	I1O4=$SPLITIP1
		SPLITIP2=${SPLITIP2#*.} ;	I2O4=$SPLITIP2
		  if [ $I1O4 -lt $I2O4 ]; then	CKPTIPLT="" ; return 0
		elif [ $I1O4 -gt $I2O4 ]; then	CKPTIPLT="" ; return 1
		else				CKPTIPLT="" ; return 1
		fi
	fi
} #End of iplt
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n iplt...
	if ! iplt 12.13.14.15 12.13.14.16 ; then						error iplt-t1 ; fi
	if ! iplt 0.0.0.0 12.13.14.15 ; then							error iplt-t2 ; fi
	if ! iplt 0.0.0.0 255.255.255.255 ; then						error iplt-t3 ; fi
	if ! iplt 12.11.11.11 12.44.45.46 ; then						error iplt-t4 ; fi
	if iplt 12.13.14.16 12.13.14.15 ; then							error iplt-f1 ; fi
	if iplt 12.13.14.15 0.0.0.0 ; then							error iplt-f2 ; fi
	if iplt 255.255.255.255 0.0.0.0 ; then							error iplt-f3 ; fi
	if iplt 12.44.45.46 12.11.11.11 ; then							error iplt-f4 ; fi
	if iplt 12.44.45.46 12.44.45.46 ; then							error iplt-f5 ; fi
fi


#-------------------------------------------------------------------------
# ipof function, returns the ip address of the given interface, or '' if none assigned.
#-------------------------------------------------------------------------
requireutil ifconfig awk || exit 1
#Checks done on the following function: 
ipof () {	#SUDO checked
    ifconfig $1 2>/dev/null | awk '/inet addr/{print substr($2,6)}'
} #End of ipof
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n ipof...
	if [ ! "`ipof lo`" = "127.0.0.1" ]; then						error ipof-1 ; fi
	if [ ! "`ipof qeqeqeqeqeqeqeqe`" = "" ]; then						error ipof-2 ; fi
fi


#-------------------------------------------------------------------------
# isdigits function, returns true (0) if parameter is numeric and between 0 and 99999, else false(1)
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
isdigits () {	#SUDO checked
	case $1 in
	[0-9])						return 0						;;
	[0-9][0-9])					return 0						;;
	[0-9][0-9][0-9])			return 0						;;
	[0-9][0-9][0-9][0-9])		return 0						;;
	[0-9][0-9][0-9][0-9][0-9])	return 0						;;
	*)							return 1						;;
	esac
}
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n isdigits...
	if ! isdigits 0 ; then									error isdigits-t1 ; fi
	if ! isdigits 00 ; then									error isdigits-t2 ; fi
	if ! isdigits 101 ; then								error isdigits-t3 ; fi
	if ! isdigits 4987 ; then								error isdigits-t4 ; fi
	if ! isdigits 44567 ; then								error isdigits-t5 ; fi
	if ! isdigits 00000 ; then								error isdigits-t6 ; fi
	if ! isdigits 99999 ; then								error isdigits-t7 ; fi
	if isdigits '' ; then									error isdigits-f1 ; fi
	if isdigits a ; then									error isdigits-f2 ; fi
	if isdigits a0a ; then									error isdigits-f3 ; fi
	if isdigits 00B ; then									error isdigits-f4 ; fi
	if isdigits 123456 ; then								error isdigits-f5 ; fi
	if isdigits "" ; then									error isdigits-f6 ; fi
fi


#-------------------------------------------------------------------------
# isnumericip function, returns true (0) if IP is a numeric IP address, else false(1)
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
isnumericip () {	#SUDO checked
	CKPTISNUMERICIP=" isnumericip: start $1" ; #ckpt $CKPTISNUMERICIP

	SPLITIP=$1
	I1O1=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
	I1O2=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
	I1O3=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
	I1O4=$SPLITIP

	case $I1O1 in
	[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])	:					;;
	*)								CKPTISNUMERICIP="" ; return 1	;;
	esac
	case $I1O2 in
	[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])	:					;;
	*)								CKPTISNUMERICIP="" ; return 1	;;
	esac
	case $I1O3 in
	[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])	:					;;
	*)								CKPTISNUMERICIP="" ; return 1	;;
	esac
	case $I1O4 in
	[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])	:					;;
	*)								CKPTISNUMERICIP="" ; return 1	;;
	esac

	CKPTISNUMERICIP="" ; return 0
} #End of isnumericip
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n isnumericip...
	if ! isnumericip 1.1.1.1 ; then								error isnumericip-t1 ; fi
	if ! isnumericip 0.0.0.0 ; then								error isnumericip-t2 ; fi
	if ! isnumericip 255.255.255.255 ; then							error isnumericip-t3 ; fi
	if ! isnumericip 1.2.3.4 ; then								error isnumericip-t4 ; fi
	if ! isnumericip 127.0.0.1 ; then							error isnumericip-t5 ; fi
	if ! isnumericip 192.168.234.243 ; then							error isnumericip-t6 ; fi
	if isnumericip 1.1.1. ; then								error isnumericip-f1 ; fi
	if isnumericip a ; then									error isnumericip-f2 ; fi
	if isnumericip 1..1.1.1 ; then								error isnumericip-f3 ; fi
	if isnumericip .1.1.1.1 ; then								error isnumericip-f4 ; fi
	if isnumericip 1.1.1.1.1 ; then								error isnumericip-f5 ; fi
	if isnumericip 256.1.1.1 ; then								error isnumericip-f6 ; fi
	if isnumericip 1.256.1.1 ; then								error isnumericip-f7 ; fi
	if isnumericip 1.1.256.1 ; then								error isnumericip-f8 ; fi
	if isnumericip 1.1.1.256 ; then								error isnumericip-f9 ; fi
	if isnumericip -1.5.6.7 ; then								error isnumericip-f10 ; fi
	if isnumericip 12.13.14.15a ; then							error isnumericip-f11 ; fi
	if isnumericip a.b.c.d ; then								error isnumericip-f12 ; fi
	if isnumericip ... ; then								error isnumericip-f13 ; fi
fi


#-------------------------------------------------------------------------
# mask2bits function, returns the number of bits in the netmask parameter.
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
mask2bits () {	#SUDO checked
	case $1 in
	255.255.255.255)	echo 32									;;
	255.255.255.254)	echo 31									;;
	255.255.255.252)	echo 30									;;
	255.255.255.248)	echo 29									;;
	255.255.255.240)	echo 28									;;
	255.255.255.224)	echo 27									;;
	255.255.255.192)	echo 26									;;
	255.255.255.128)	echo 25									;;
	255.255.255.0)		echo 24									;;
	255.255.254.0)		echo 23									;;
	255.255.252.0)		echo 22									;;
	255.255.248.0)		echo 21									;;
	255.255.240.0)		echo 20									;;
	255.255.224.0)		echo 19									;;
	255.255.192.0)		echo 18									;;
	255.255.128.0)		echo 17									;;
	255.255.0.0)		echo 16									;;
	255.254.0.0)		echo 15									;;
	255.252.0.0)		echo 14									;;
	255.248.0.0)		echo 13									;;
	255.240.0.0)		echo 12									;;
	255.224.0.0)		echo 11									;;
	255.192.0.0)		echo 10									;;
	255.128.0.0)		echo 9									;;
	255.0.0.0)		echo 8									;;
	254.0.0.0)		echo 7									;;
	252.0.0.0)		echo 6									;;
	248.0.0.0)		echo 5									;;
	240.0.0.0)		echo 4									;;
	224.0.0.0)		echo 3									;;
	192.0.0.0)		echo 2									;;
	128.0.0.0)		echo 1									;;
	0.0.0.0)		echo 0									;;
	*)			echo 32									;;
	esac
} #End of mask2bits
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n mask2bits...
	if [ ! `mask2bits 255.255.255.255` = "32" ]; then					error mask2bits-1 ; fi
	if [ ! `mask2bits 255.255.255.254` = "31" ]; then					error mask2bits-2 ; fi
	if [ ! `mask2bits 255.255.255.252` = "30" ]; then					error mask2bits-3 ; fi
	if [ ! `mask2bits 255.255.255.248` = "29" ]; then					error mask2bits-4 ; fi
	if [ ! `mask2bits 128.0.0.0` = "1" ]; then						error mask2bits-5 ; fi
	if [ ! `mask2bits 0.0.0.0` = "0" ]; then						error mask2bits-6 ; fi
fi


#-------------------------------------------------------------------------
# mask2cisco function, returns the cisco "reverse netmask" of the netmask parameter.
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
mask2cisco () {	#SUDO checked
#This could be done in fewer lines by subtracting each octet from 255.
#I'm trying to avoid forking as it hurts performance.
	case $1 in
	32|255.255.255.255)	echo 0.0.0.0							;;
	31|255.255.255.254)	echo 0.0.0.1							;;
	30|255.255.255.252)	echo 0.0.0.3							;;
	29|255.255.255.248)	echo 0.0.0.7							;;
	28|255.255.255.240)	echo 0.0.0.15							;;
	27|255.255.255.224)	echo 0.0.0.31							;;
	26|255.255.255.192)	echo 0.0.0.63							;;
	25|255.255.255.128)	echo 0.0.0.127							;;
	24|255.255.255.0)	echo 0.0.0.255							;;
	23|255.255.254.0)	echo 0.0.1.255							;;
	22|255.255.252.0)	echo 0.0.3.255							;;
	21|255.255.248.0)	echo 0.0.7.255							;;
	20|255.255.240.0)	echo 0.0.15.255							;;
	19|255.255.224.0)	echo 0.0.31.255							;;
	18|255.255.192.0)	echo 0.0.63.255							;;
	17|255.255.128.0)	echo 0.0.127.255						;;
	16|255.255.0.0)		echo 0.0.255.255						;;
	15|255.254.0.0)		echo 0.1.255.255						;;
	14|255.252.0.0)		echo 0.3.255.255						;;
	13|255.248.0.0)		echo 0.7.255.255						;;
	12|255.240.0.0)		echo 0.15.255.255						;;
	11|255.224.0.0)		echo 0.31.255.255						;;
	10|255.192.0.0)		echo 0.63.255.255						;;
	9|255.128.0.0)		echo 0.127.255.255						;;
	8|255.0.0.0)		echo 0.255.255.255						;;
	7|254.0.0.0)		echo 1.255.255.255						;;
	6|252.0.0.0)		echo 3.255.255.255						;;
	5|248.0.0.0)		echo 7.255.255.255						;;
	4|240.0.0.0)		echo 15.255.255.255						;;
	3|224.0.0.0)		echo 31.255.255.255						;;
	2|192.0.0.0)		echo 63.255.255.255						;;
	1|128.0.0.0)		echo 127.255.255.255						;;
	0|0.0.0.0)		echo 255.255.255.255						;;
	*)			echo 0.0.0.0							;;
	esac
} #End of mask2cisco
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n mask2cisco...
	if [ ! `mask2cisco 255.255.255.128` = "0.0.0.127" ]; then				error mask2cisco-1 ; fi
	if [ ! `mask2cisco 255.255.192.0` = "0.0.63.255" ]; then				error mask2cisco-2 ; fi
	if [ ! `mask2cisco 22` = "0.0.3.255" ]; then						error mask2cisco-3 ; fi
fi


#-------------------------------------------------------------------------
# max function, Returns the largest of the CLP's, or 0 if none.
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
max () {
    if [ $# -eq 0 ]; then
	echo 0
    else
	MAX=$1
	shift
	while [ -n "$1" ]; do
	    if [ $[ $1 ] -gt $MAX ]; then
		MAX=$[ $1 ]
	    fi
	    shift
	done
	echo $MAX
    fi
} #End of max
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n max...
	#General return values
	if [ ! `max` = "0" ]; then								error max-1 ; fi
	if [ ! `max 1` = "1" ]; then								error max-2 ; fi
	if [ ! `max 2 5` = "5" ]; then								error max-3 ; fi
	if [ ! `max -2 -4` = "-2" ]; then							error max-4 ; fi
	if [ ! `max -2 -4 13 -10` = "13" ]; then						error max-5 ; fi
	if [ ! `max 1 1 1 1 1` = "1" ]; then							error max-6 ; fi
fi


#-------------------------------------------------------------------------
# networkof function, returns the network of the given ip and netmask.
#-------------------------------------------------------------------------
requireutil bits2mask || exit 1
#Checks done on the following function: 
networkof () {
#Basically, the network is (ip bitwise-and netmask)
	CKPTNETWORKOF=" networkof: Start $1 mask $2" ; #ckpt $CKPTNETWORKOF

	case $2 in
	32|255.255.255.255)	echo $1									;;
	0|0.0.0.0)			echo 0.0.0.0							;;
	*)
		SPLITIP=$1
		I1O1=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O2=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O3=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I1O4=$SPLITIP
		case $2 in
		[0-9]|[1-2][0-9]|3[0-2])	SPLITIP=`bits2mask $2`			;;
		*)							SPLITIP=$2						;;
		esac
		I2O1=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O2=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O3=${SPLITIP%%.*} ; SPLITIP=${SPLITIP#*.}
		I2O4=$SPLITIP

		echo $[ $I1O1 & $I2O1 ].$[ $I1O2 & $I2O2 ].$[ $I1O3 & $I2O3 ].$[ $I1O4 & $I2O4 ]
																;;
	esac
	CKPTNETWORKOF=""
} #End of networkof
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n networkof...
	if [ ! `networkof 0.0.0.0 0.0.0.0` = "0.0.0.0" ]; then					error networkof-1 ; fi
	if [ ! `networkof 1.2.3.4 255.255.255.0` = "1.2.3.0" ]; then				error networkof-2 ; fi
	if [ ! `networkof 15.1.2.3 255.0.0.0` = "15.0.0.0" ]; then				error networkof-3 ; fi
	if [ ! `networkof 1.2.3.4 128.0.0.0` = "0.0.0.0" ]; then				error networkof-4 ; fi
	if [ ! `networkof 0.0.0.0 0` = "0.0.0.0" ]; then					error networkof-5 ; fi
	if [ ! `networkof 1.2.3.4 24` = "1.2.3.0" ]; then					error networkof-6 ; fi
	if [ ! `networkof 15.1.2.3 8` = "15.0.0.0" ]; then					error networkof-7 ; fi
	if [ ! `networkof 1.2.3.4 1` = "0.0.0.0" ]; then					error networkof-8 ; fi
	if [ ! `networkof 1.2.3.4 0.0.0.0` = "0.0.0.0" ]; then					error networkof-9 ; fi
fi

#-------------------------------------------------------------------------
# networksoverlap function, returns true (0) if the two param networks overlap, false otherwise.
#-------------------------------------------------------------------------
requireutil networkof broadcastof iple || exit 1
#Checks done on the following function: 
networksoverlap () {	#SUDO checked
	#FIXME - handle, or get networkof/broadcastof to handle, '0' as the network
	N1NET=`networkof ${1%%/*} ${1##*/}` ;	N1BROAD=`broadcastof ${1%%/*} ${1##*/}`
	N2NET=`networkof ${2%%/*} ${2##*/}` ;	N2BROAD=`broadcastof ${2%%/*} ${2##*/}`

	  if iple $N2NET $N1NET &&	iple $N1NET $N2BROAD ; then	return 0	#N1NET inside N2?
	elif iple $N2NET $N1BROAD &&	iple $N1BROAD $N2BROAD ; then	return 0	#N1BROAD inside N2?
	elif iple $N1NET $N2NET &&	iple $N2NET $N1BROAD ; then	return 0	#N2NET inside N1?
	elif iple $N1NET $N2BROAD &&	iple $N2BROAD $N1BROAD ; then	return 0	#N2BROAD inside N1?
	fi
	return 1	#False
} #End of networksoverlap
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n networksoverlap...
	if ! networksoverlap 127.0.0.0/8 127.0.0.0/16 ; then					error networksoverlap-t1 ; fi
	if ! networksoverlap 192.168.1.0/24 192.168.1.252/30 ; then				error networksoverlap-t2 ; fi
	if ! networksoverlap 12.13.14.0/24 0.0.0.0/0; then					error networksoverlap-t3 ; fi
	if ! networksoverlap 0.0.0.0/0 0.0.0.0/0 ; then						error networksoverlap-t4 ; fi
	if networksoverlap 1.2.3.0/24 5.6.7.0/24 ; then						error networksoverlap-f1 ; fi
	if networksoverlap 0.0.0.0/1 128.0.0.0/1 ; then						error networksoverlap-f2 ; fi
	if networksoverlap 1.2.3.248/30 1.2.3.252/30 ; then					error networksoverlap-f3 ; fi
	if networksoverlap 1.2.3.0/24 1.2.4.0/24 ; then						error networksoverlap-f4 ; fi
fi


#Out of alphabetical order because it depends on networkof.  While not a problem
#for simply placing the functions in memory, it makes a difference for this 
#approach of calling the regression tests right after the function.
#-------------------------------------------------------------------------
# encompassingnetworkof function, returns the smallest network that includes
# all of the given ip's.  There must be at least one parameter.
# Please hand in only straight IP's; to include a network in the calculation,
# hand in both: `networkof $NET $NETMASK` `broadcastof $NET $NETMASK`
#-------------------------------------------------------------------------
requireutil iplt bits2mask networkof broadcastof || exit 1
#Checks done on the following function: 
encompassingnetworkof () {	#SUDO checked
	CKPTENCOMPASSINGNETWORKOF=" encompassingnetworkof: Start, ips: $*" ; #ckpt $CKPTENCOMPASSINGNETWORKOF

	case $# in
	0)	:														;;
	1)	echo "$1/32"											;;
	*)
		MINIP=$1	; MAXIP=$1
		shift
		for ONEIP in $* ; do
			if iplt $ONEIP $MINIP ; then MINIP=$ONEIP ; fi
			if iplt $MAXIP $ONEIP ; then MAXIP=$ONEIP ; fi
		done

		SPLITIP=$MINIP ;			MINO1=${SPLITIP%%.*}
		SPLITIP=${SPLITIP#*.} ;		MINO2=${SPLITIP%%.*}
		SPLITIP=${SPLITIP#*.} ;		MINO3=${SPLITIP%%.*}
		#SPLITIP=${SPLITIP#*.} ;	MINO4=$SPLITIP			#We don't need the MIN04 and MAX04.
		SPLITIP=$MAXIP ;			MAXO1=${SPLITIP%%.*}
		SPLITIP=${SPLITIP#*.} ;		MAXO2=${SPLITIP%%.*}
		SPLITIP=${SPLITIP#*.} ;		MAXO3=${SPLITIP%%.*}
		#SPLITIP=${SPLITIP#*.} ;	MAXO4=$SPLITIP

		#Find the _starting_ _point_ for the search.
		# - if the first octets are different, start at /8.
		# - if the second octets are different, start at /16.
		# - if the third octets are different, start at /24.
		# - else start at /32.
		#This relatively simple optimization sped up this function by a theoretical factor of 4 
		#and a timed factor of 10 on one example.  *smile*
		#(BTW - It would appear we could start the search at 7, 15, or 23, but the result from 
		#encompassingnetworkof 10.1.2.3 11.12.13.14 10.2.3.4  comes back as 8.0.0.0/6: wrong.
		  if [ $MINO1 -ne $MAXO1 ]; then		ENONUMBITS=8 ;	ENONETMASK=255.0.0.0
		elif [ $MINO2 -ne $MAXO2 ]; then		ENONUMBITS=16 ;	ENONETMASK=255.255.0.0
		elif [ $MINO3 -ne $MAXO3 ]; then		ENONUMBITS=24 ;	ENONETMASK=255.255.255.0
		else						ENONUMBITS=32 ;	ENONETMASK=255.255.255.255 ; fi
		ENONETWORK=$MINIP
		ENOBROADCAST=$MINIP

		#Keep expanding the network until it includes MAXIP.  This takes almost all of the time.
		while [ $ENONUMBITS -gt 0 ] && iplt $ENOBROADCAST $MAXIP ; do
			ENONUMBITS=$[ $ENONUMBITS - 1 ]
			ENONETMASK=`bits2mask $ENONUMBITS`
			ENONETWORK=`networkof $MINIP $ENONETMASK`
			ENOBROADCAST=`broadcastof $MINIP $ENONETMASK`
		done
		if [ "$ENONETWORK/$ENONUMBITS" = "0.0.0.0/0" ]; then ENONETWORK="0" ; fi
		echo "$ENONETWORK/$ENONUMBITS"
																;;
	esac
	CKPTENCOMPASSINGNETWORKOF=""
} #End of encompassingnetworkof
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n encompassingnetworkof...
	if [ ! `encompassingnetworkof 1.2.3.1 1.2.3.1` = "1.2.3.1/32" ]; then			error encompassingnetworkof-1 ; fi
	if [ ! `encompassingnetworkof 1.2.3.2 1.2.3.3` = "1.2.3.2/31" ]; then			error encompassingnetworkof-2 ; fi
	if [ ! `encompassingnetworkof 1.2.3.1 1.2.3.3` = "1.2.3.0/30" ]; then			error encompassingnetworkof-3 ; fi
	if [ ! `encompassingnetworkof 1.2.3.0 1.2.3.255` = "1.2.3.0/24" ]; then			error encompassingnetworkof-4 ; fi
	if [ ! `encompassingnetworkof 0.0.0.0 255.255.255.255` = "0/0" ]; then			error encompassingnetworkof-5 ; fi
	if [ ! `encompassingnetworkof 127.255.255.255 128.0.0.0` = "0/0" ]; then		error encompassingnetworkof-6 ; fi
	if [ ! `encompassingnetworkof 172.16.0.1 172.16.5.5` = "172.16.0.0/21" ]; then		error encompassingnetworkof-7 ; fi
	if [ ! `encompassingnetworkof 206.231.24.3 206.231.24.254 209.91.2.2 209.91.2.253 209.91.28.2 209.91.28.252 209.91.3.1 209.91.3.254 209.91.32.54 209.91.32.72` = "192.0.0.0/3" ]; then	error encompassingnetworkof-8 ; fi
	if [ ! `encompassingnetworkof 10.1.2.3 9.1.2.3` = "8.0.0.0/6" ]; then			error encompassingnetworkof-9 ; fi
	if [ ! `encompassingnetworkof 10.1.2.3 10.255.1.1` = "10.0.0.0/8" ]; then		error encompassingnetworkof-10 ; fi
	if [ ! `encompassingnetworkof 10.1.2.3 11.12.13.14 10.2.3.4` = "10.0.0.0/7" ]; then	error encompassingnetworkof-11 ; fi
	if [ ! `encompassingnetworkof 14.12.1.2 14.12.129.0` = "14.12.0.0/16" ]; then		error encompassingnetworkof-12 ; fi
	if [ ! `encompassingnetworkof 14.13.1.1 14.12.255.255` = "14.12.0.0/15" ]; then		error encompassingnetworkof-13 ; fi
fi


#-------------------------------------------------------------------------
# seqfunc function, creates a sequence of integers from $1 to $2
# Integers only!
#-------------------------------------------------------------------------
#No external apps needed.
#Checks done on the following function: 
seqfunc () {	#SUDO checked
	unset SEQSTART SEQSTOP SEQCOUNT || :
	case $# in
	0)	:														;;
	1)	SEQSTART=1 ; SEQSTOP=$[ $1 ]							;;
	*)	SEQSTART=$[ $1 ] ; SEQSTOP=$[ $2 ]						;;
	esac
	if [ -n "$SEQSTART" ]; then
		if [ $SEQSTART -eq $SEQSTOP ]; then
			echo $SEQSTART
		elif [ $SEQSTART -lt $SEQSTOP ]; then
			SEQCOUNT=$SEQSTART
			while [ $SEQCOUNT -le $SEQSTOP ]; do
				echo $SEQCOUNT
				SEQCOUNT=$[ $SEQCOUNT + 1 ]
			done
		else #$1 > $2
			SEQCOUNT=$SEQSTART
			while [ $SEQCOUNT -ge $SEQSTOP ]; do
				echo $SEQCOUNT
				SEQCOUNT=$[ $SEQCOUNT - 1 ]
			done
		fi
	fi
} #End of seqfunc
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n seqfunc...
	if [ ! "`seqfunc 1`" = "1" ]; then							error seqfunc-1 ; fi
	if [ ! "`seqfunc 5`" = "1
2
3
4
5" \
	]; then											error seqfunc-2 ; fi
	if [ ! "`seqfunc -5`" = "1
0
-1
-2
-3
-4
-5" \
	]; then											error seqfunc-3 ; fi
	if [ ! "`seqfunc 1 5`" = "1
2
3
4
5" \
	]; then											error seqfunc-4 ; fi
	if [ ! "`seqfunc 5 5`" = "5" ]; then							error seqfunc-5 ; fi
	if [ ! "`seqfunc 2 -2`" = "2
1
0
-1
-2" \
	]; then											error seqfunc-6 ; fi
	if [ ! "`seqfunc -1 -1`" = "-1" ]; then							error seqfunc-7 ; fi
	if [ ! "`seqfunc`" = "" ]; then								error seqfunc-8 ; fi


fi



#-------------------------------------------------------------------------
# showstate procedure, used to display the state of the running program
#-------------------------------------------------------------------------
showstate () {  #SUDO checked
#Param: p1 is the string to be displayed.
        if [ "$USEANSI" != "NO" ]; then
                if [ "${TERM}" = "xterm" -o "${TERM}" = "xterm-color" ]; then
                        echo -ne "\033]0;${*}\007"
		else
			echo "==== ${*} ===="
                fi
        fi
} #end of showstate
									

#-------------------------------------------------------------------------
# substline procedure, replaces $2 with $3 in the given file $1
#-------------------------------------------------------------------------
#Params: $1 File that needs the additional line, $2 string to look for, $3 string with which it should be replaced.
#Example:
#substline somefile     "\(^[^#].*\)"   "#\1"
#Translation: add a # in front of all lines that don't have one.
requireutil $SUDO touch cat grep printf umask mktemp sed dd rm || exit 1
#Checks done on the following function: 
substline() {
	if [ "$#" != "3" ]; then
		echo Incorrect number of arguments to substline! >&2
	else
		#case "$1" in
		#/*)
		#    echo Filename is not relative in substline! >&2
		#    ;;
		#*)
		if $SUDO [ ! -f "$1" ]; then
			$SUDO touch "$1"
		fi
		if $SUDO cat "$1" | grep -q "$2" ; then
			printf "%-3s%-40s%-50s\n" '-/+' "$1" "$2 -> $3"	#Was: echo Replacing \"$2\" with \"$3\" in $1
			OLDUMASK=`umask`
			umask 177
			TMPFILE=`mktemp -q /tmp/substline.XXXXXX`
			if [ $? -ne 0 ]; then
				echo "$0: Can't create temp file, exiting..."
				exit 1
			fi
			$SUDO cat "$1" >"$TMPFILE"
			cat "$TMPFILE" | sed -e "s@$2@$3@g" | $SUDO dd of="$1" 2>/dev/null
			$SUDO rm -f "$TMPFILE"
			umask $OLDUMASK
		fi
		#    ;;
		#esac
	fi
}
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n substline...
	REGRESSTESTFILE=`mktemp -q /tmp/$1.XXXXXX`
	if [ $? -ne 0 ]; then
		echo "$0: Can't create regression temp file, exiting..."
		exit 1
	fi
	echo Line 1 >$REGRESSTESTFILE
	echo Line 2 >>$REGRESSTESTFILE
	echo Line 3 >>$REGRESSTESTFILE
	echo Line 4 >>$REGRESSTESTFILE
	echo Line 5 >>$REGRESSTESTFILE
	substline $REGRESSTESTFILE "2" "goobers" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 1
Line goobers
Line 3
Line 4
Line 5" \
	]; then											error substline-1 ; fi
	substline $REGRESSTESTFILE "Isnt in the file" "ggg" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 1
Line goobers
Line 3
Line 4
Line 5" \
	]; then											error substline-2 ; fi
	substline $REGRESSTESTFILE "Line 3" "replacement line" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"Line 1
Line goobers
replacement line
Line 4
Line 5" \
	]; then											error substline-3 ; fi
	substline $REGRESSTESTFILE "Line 1" "new line 1">/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"new line 1
Line goobers
replacement line
Line 4
Line 5" \
	]; then											error substline-4 ; fi
	substline $REGRESSTESTFILE "Line " "circle " >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"new line 1
circle goobers
replacement line
circle 4
circle 5" \
	]; then											error substline-5 ; fi
	substline $REGRESSTESTFILE "e" "qq" >/dev/null 2>/dev/null
	if [ ! "`cat $REGRESSTESTFILE`" = \
"nqqw linqq 1
circlqq goobqqrs
rqqplacqqmqqnt linqq
circlqq 4
circlqq 5" \
	]; then											error substline-6 ; fi
	rm -f $REGRESSTESTFILE
fi




#-------------------------------------------------------------------------
# wrap function, which displays the words on the command line, wrapped
# at LINELENGTH characters.
#-------------------------------------------------------------------------
#The linelength must be larger than the longest word in the string.
#LINELENGTH is the number of displayed characters.
#This should handle command line parameters or stdin.
#If WRAPHEADER is set, its value is placed at the head of each line.
#Uses $ENH (=-e) from calling app.
#No external apps needed.  Even if sed and wc missing, we have a less elegant fallback.
if type -path sed >/dev/null 2>/dev/null && type -path wc >/dev/null 2>/dev/null ; then
	#Checks done on the following function: 1
	wrap () {
		if [ -n "$LINELENGTH" ]; then
			LINELENGTH_INT=$[ $LINELENGTH - `echo -n "$WRAPHEADER" | wc -c` ]
		else
			LINELENGTH_INT=$[ 72 - `echo -n "$WRAPHEADER" | wc -c` ]
		fi
		if [ $[ $LINELENGTH_INT ] -lt 20 ]; then
			LINELENGTH_INT=20
		fi
		if [ $# -eq 0 ]; then
			#Double sed is required as the first sed only thinks there's one ^, even after we've stuck in newlines.
			sed -e "s/\(.\{1,$LINELENGTH_INT\}\)[[:space:]]\+/\1!!LINEFEED!!/g" -e 's/!!LINEFEED!!/\
/g' | sed -e "s/^/$WRAPHEADER/"
		else
			echo $ENH -n "$* " | sed -e "s/\(.\{1,$LINELENGTH_INT\}\)[[:space:]]\+/\1!!LINEFEED!!/g" -e 's/!!LINEFEED!!/\
/g' | sed -e "s/^/$WRAPHEADER/"
		fi
	} #End of wrap
else	#Fall back on alternate form of the function that doesnt need sed or wc.
	#Checks done on the following function: 1
	wrap () {
		if [ $# -eq 0 ]; then
			while read LINE ; do echo $LINE ; done
		else
			echo $ENH $*
		fi
	} #End of wrap
fi
if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo -n wrap...
#FIXME - this whacks LINELENGTH in the current shell.  LINELENGTH=20 wrap..., perhaps?
	export LINELENGTH=20
	if [ ! "`wrap Hello there, world.`" = \
"Hello there, world." \
	]; then											error wrap-1 ; fi

	if [ ! "`wrap The licenses for most software are designed to take away your freedom to share and change it.`" = \
"The licenses for
most software are
designed to take
away your freedom to
share and change it." \
	]; then											error wrap-2 ; fi

	export LINELENGTH=40
	if [ ! "`wrap The licenses for most software are designed to take away your freedom to share and change it.`" = \
"The licenses for most software are
designed to take away your freedom to
share and change it." \
	]; then											error wrap-3 ; fi

	if [ ! "`echo 'The licenses for most software are designed to take away your freedom to share and change it. ' | wrap`" = \
"The licenses for most software are
designed to take away your freedom to
share and change it." \
	]; then											error wrap-4 ; fi

	unset LINELENGTH
fi



if [ "$DOREGRESSIONTEST" = "YES" ]; then
	echo done.

	echo ---------- Exit with a fanfare ----------
	echo `cat $0 | sed -e 's/#.*//' | grep 'error .* fi' | grep -v regression | wc -l` regression tests successful on $SAMVER

	if [ -d /usr/src/samlib-work ]; then
		date >>/usr/src/samlib-work/regression-log
		echo `cat $0 | sed -e 's/#.*//' | grep 'error .* fi' | grep -v regression | wc -l` regression tests successful on $SAMVER >>/usr/src/samlib-work/regression-log
	fi
	exit 0
fi


