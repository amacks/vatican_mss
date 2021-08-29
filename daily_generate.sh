#!/bin/bash

FILEPATH=/apps/apache/htdocs/

./weekly_report.pl --today --filepath=${FILEPATH}
./generate_index.pl --filepath=${FILEPATH}
./generate_rss.pl --filepath=${FILEPATH} --mss-limit=100

## Make sure to sync up CSS
cp css/* ${FILEPATH}vatican/css/
