#!/bin/bash

FILEPATH=/apps/apache/htdocs/
START_YEAR=2018
START_WEEK=4
CURRENT_YEAR=`date +%Y`
CURRENT_WEEK=$((`date +%W` +1))

for week in `seq ${START_WEEK} 53`; do
	./weekly_report.pl --week=${week} --year=${START_YEAR} --filepath=/apps/apache/htdocs/
done
for year in `seq $((${START_YEAR}+1)) $((${CURRENT_YEAR} - 1))`; do
	for week in `seq 1 53`; do
		./weekly_report.pl --week=${week} --year=${year} --filepath=/apps/apache/htdocs/
	done
done
for week in `seq 1 ${CURRENT_WEEK}`; do
	./weekly_report.pl --week=${week} --year=${CURRENT_YEAR} --filepath=/apps/apache/htdocs/
done

./generate_index.pl --filepath=${FILEPATH}

./adhoc_reports.pl --filepath=${FILEPATH}

## Make sure to sync up CSS
cp css/* ${FILEPATH}vatican/css/
