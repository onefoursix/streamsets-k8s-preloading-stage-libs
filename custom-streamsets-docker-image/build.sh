#!/usr/bin/env bash

# This script builds a custom Docker image that extends the base SDC image.
# It downloads a set of SDC stage libs to a local directory. and then the
# Dockerfile copies those libs into the SDC image.
#
# Prerequisites:
#
#  - Set the SDC_VERSION 
#
#  - Set IMAGE_NAME to your custom image name
#
#  - Set SDC_STAGE_LIBS to a space-delimited set of stage libraries to include.  
#    Use only short stage library names, like "apache-kafka" as the script will
#    prepend "streamsets-datacollector-" and append "-lib" to each entry.
#    You do not need to include the basic, dataformats, or dev stage libraries as these 
#    will be included by default.
#
#  - For the docker push command to work (the last line of the script), 
#    login to your Docker Hub or other image registry before running the script. 

# SDC Version
SDC_VERSION=6.3.1

# Your custom image name
IMAGE_NAME=<org>/<image>:<tag>

# A space delimited list of stage libs to download
SDC_STAGE_LIBS="apache-kafka aws bigtable google-cloud groovy_4.0 jdbc jms jython_2_7 sdc-snowflake"

# Base URL to download SDC Stage Libs
BASE_URL=https://archives.streamsets.com/datacollector

# Create and switch to a temp directory to unpack the downloaded stage libs
mkdir -p tmp-stages
cd tmp-stages

# Download and extract the stage libs
for s in ${SDC_STAGE_LIBS};
do
  STAGE_LIB='streamsets-datacollector-'${s}'-lib'
  STAGE_LIB_FILE=${STAGE_LIB}-${SDC_VERSION}.tgz
  STAGE_LIB_URL=${BASE_URL}/${SDC_VERSION}/tarball/${STAGE_LIB_FILE}
  echo '---------------------'
  echo 'Getting stage lib:  '${STAGE_LIB_FILE}
  echo '---------------------'
  wget ${STAGE_LIB_URL}
  tar -xvf ${STAGE_LIB_FILE}
  rm ${STAGE_LIB_FILE}
done

echo '---------------------'
echo 'Summary of downloaded stage libs:'
ls -l streamsets-datacollector-${SDC_VERSION}/streamsets-libs | tail -n +2
echo '---------------------'

cd ..

# move the stage libs to the ./streamsets-libs dir
mv tmp-stages/streamsets-datacollector-${SDC_VERSION}/streamsets-libs streamsets-libs

# remove the tmp-stages dir
rm -rf tmp-stages

# Build the image
docker build -t $IMAGE_NAME .

# remove up the streamsets-libs dir
rm -rf streamsets-libs

# Push the image
docker push $IMAGE_NAME