#! /bin/bash

##
##  This script will check the files contained in a folder and export
##+ a summary file. The given folder should actually be a tree, as e.g.
##
##  2015/
##     |
##     +-- 001/
##     |     |
##     |     +-- sta1ddds.yyd*
##     |     |
##     |     +-- sta2ddds.yyd*
##     |     |
##     |     +-- ...
##     |
##     +-- 002/
##     |     |
##     |     +-- sta1ddds.yyd*
##     |     |
##     |     +-- sta2ddds.yyd*
##     |     |
##     |     +-- ...
##     |
##    ...
##     |
##     +-- 365/
##     |     |
##     |     +-- sta1ddds.yyd*
##     |     |
##     |     +-- sta2ddds.yyd*
##     |     |
##     |     +-- ...
##
##  The script expects to find an executable named "yday_to_mday.awk"
##+ in the current path.
##
##  The summary file is directed to STDOUT and each line has the form:
##  "2009-12-26 akyr 321020 ark2 309207 ... xrso 325932"
##
##  Feb-2016 xxx
##

month_day0=(0 31 59 90 120 151 181 212 243 273 304 334)
month_day1=(0 31 60 91 121 152 182 213 244 274 305 335)

##  YEAR(1) MONTH(2) DAY(3) to DOY
mday_to_yday() {
	leap=$(expr $1 % 4)
	mm1=$(expr $2 - 1)
	if [ ${leap} -eq 0 ] ; then
		doy=${month_day0{$mm1}}
	else
		doy=${month_day1{$mm1}}
	fi
	echo "$doy"
}

if test $# -ne 1 ; then
	echo 1>&2 "Invalid number of arguments"
	echo 1>&2 "Usage compile_year_report.sh <YEAR_FOLDER>"
	exit 1
fi

FOLDER=${1}

if ! test -d ${FOLDER} ; then
	echo 1>&2 "Invalid folder \"${FOLDER}\""
	exit 1
else
	if ! [[ "${FOLDER}" =~ ^[0-9]+$ ]] ; then
		echo 1>&2 "Folder \"${FOLDER}\" is not a year! Stoping."
		exit 1
	fi
fi

YEAR=${FOLDER}
STATIONS=()

for dir in `ls ${FOLDER}` ; do
	if ! [[ $dir =~ ^[0-9]+$ ]] ; then
		echo 1>&2 "Directory \"${dir}\" is not a number; omiting ..."
	else
		if [ "${dir}" -lt 1 ] || [ "${dir}" -gt 366 ] ; then
			echo 1>&2 "Directory \"${dir}\" is not a number in range 0-366; omiting ..."
			else
				d_str=$(echo "${YEAR} ${dir}" | ./yday_to_mday.awk)
				printf "\n%s" "${d_str}"
				for file in `ls ${FOLDER}/${dir}/` ; do
					station=${file:0:4}
					doy=${file:4:3}
					session=${file:7:1}
					yr2=${file:9:2}
					if [ "${yr2}" != "${FOLDER:2:2}" ] ; then 
						echo 1>&2 "[WARNING] File \"${FOLDER}/${dir}/${file}\" seems not to belong here."
					else
						size=$(stat -c"%s" ${FOLDER}/${dir}/${file})
						printf " %s %s" "${station}" "${size}"
					fi
				done
		fi
	fi
done

printf "\n"
