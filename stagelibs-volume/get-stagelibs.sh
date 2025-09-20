!/usr/bin/env bash

# This script downloads a set of SDC stage libs.
#
# Prerequisites:
#
#  - Set the SDC_VERSION
#
#  - Set SDC_STAGE_LIBS to a space-delimited set of stage libraries to include.
#    Use only short stage library names, like "apache-kafka" as the script will
#    prepend "streamsets-datacollector-" and append "-lib" to each entry.
#    You do not need to include the basic, dataformats, or dev stage libraries as these
#    will be downloaded by this script by default.
#

# SDC Version
SDC_VERSION=6.3.1

# A space delimited list of stage libs to download
USER_STAGE_LIBS="apache-kafka aws bigtable google-cloud groovy_4.0 jdbc jms jython_2_7 sdc-snowflake"


# Default stage libs
DEFAULT_STAGE_LIBS="basic dataformats dev"

# Combine the user-defined and default lists of stage libs
STAGE_LIBS="${DEFAULT_STAGE_LIBS} ${USER_STAGE_LIBS}" 

# Base URL to download SDC Stage Libs
BASE_URL=https://archives.streamsets.com/datacollector

# Download and extract the stage libs
for s in ${STAGE_LIBS};
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
echo 'Done'