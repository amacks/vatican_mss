#!/bin/bash

FILEPATH=/apps/apache/htdocs/

./weekly_report.pl --today --filepath=${FILEPATH}
./generate_index.pl --filepath=${FILEPATH}
./generate_rss.pl --filepath=${FILEPATH} --mss-limit=100
./generate_ms_pages.pl --filepath=${FILEPATH} --days=3

## Make sure to sync up CSS
cp css/* ${FILEPATH}vatican/css/

## generate static pages
tpage --include_path=tt tt/search-test.tt > ${FILEPATH}vatican/search-test.html

## now index it
pagefind --site=${FILEPATH}vatican
