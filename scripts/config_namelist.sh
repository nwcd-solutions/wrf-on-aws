#!/bin/bash

jobdir=$(pwd)
#Set-up current date as processing date variables
ftime=$(date +%Y%m%d)'00'
DATINA=$(date +%Y%m%d)
y=${ftime:0:4}
m=${ftime:4:2}
d=${ftime:6:2}
h=${ftime:8:2}
start_date=$y-$m-$d 
start_date=$(date -d ${start_date}"+0 day")
start_date=$(date -d "${start_date}" +%Y-%m-%d)
s_y=${start_date:0:4}
s_m=${start_date:5:2}
s_d=${start_date:8:2}
s_h='12'  
e_h='00'
forecast_days=2
end_date=$(date -d ${start_date}"+${forecast_days} day") 
end_date=$(date -d "${end_date}" +%Y-%m-%d)
e_y=${end_date:0:4}
e_m=${end_date:5:2}
e_d=${end_date:8:2}
start_date_tmp=${start_date}_${s_h}":00:00" 
end_date=${end_date}_${e_h}":00:00"
forecast_hours=$((forecast_days*24-s_h))
forecast_files=$((($forecast_days * 48)-32))
echo $forecast_hours

sed -i 's/STARTDATE/'"${start_date_tmp}"'/g' $jobdir/preproc/namelist.wps
sed -i 's/ENDDATE/'"${end_date}"'/g' $jobdir/preproc/namelist.wps
sed -i 's/START_YEAR/'"${s_y}"'/g' $jobdir/run/namelist.input
sed -i 's/START_MONTH/'"${s_m}"'/g' $jobdir/run/namelist.input
sed -i 's/START_DAY/'"${s_d}"'/g' $jobdir/run/namelist.input
sed -i 's/START_HOUR/'"${s_h}"'/g' $jobdir/run/namelist.input
sed -i 's/END_YEAR/'"${e_y}"'/g' $jobdir/run/namelist.input
sed -i 's/END_MONTH/'"${e_m}"'/g' $jobdir/run/namelist.input
sed -i 's/END_DAY/'"${e_d}"'/g' $jobdir/run/namelist.input
sed -i 's/END_HOUR/'"${e_h}"'/g' $jobdir/run/namelist.input
sed -i 's/FORECAST_HOUR/'"${forecast_hours}"'/g' $jobdir/run/namelist.input
