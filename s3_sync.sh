#!/bin/bash

SOURCE=/apps/apache/htdocs
SOURCE_FOLDER=vatican
BUCKET=wiglaf-static-us-east-1

aws s3 sync ${SOURCE}/${SOURCE_FOLDER} s3://${BUCKET}/${SOURCE_FOLDER}

