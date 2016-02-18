#! /bin/bash

##
##  Synchronize folders between raskolnikov and babylon. This scripts expects
##+ that you can ssh from raskolnikov to babylon without using a pass.
##
##  TODO
##      1. log the process to a file
##      2. provide exit status
##
##  Keep this script in sync with the one in /bin @ raskolnikov.
##
##  Feb-2016 xxx
##

SSH=/opt/openssh/bin/ssh
RSYNC=/opt/bin/rsync
PORT=2592
BABYLON=147.102.106.135

##  Transfer Tide Gauge Data (pub/tide-gauge/megisti/)
## ----------------------------------------------------
## ----------------------------------------------------
REMOTE_SOURCE=~/../raid0/data/pub/tide-gauge/megisti/
LOCAL_TARGET=/raid0/data/pub/tide-gauge/megisti/

##  Execute and let God have mercy on our souls
${RSYNC} -e "${SSH} -p ${PORT}" -av root@${BABYLON}:${REMOTE_SOURCE} ${LOCAL_TARGET}

##  These are 777 
/bin/chmod -R 777 ${LOCAL_TARGET}

##  Transfer GNSS Data (pub/gnss/data/daily/${YEAR} where
##+ YEAR is the current year.
## ----------------------------------------------------                                      
## ----------------------------------------------------
YEAR=$(date +%Y)

REMOTE_SOURCE=~/../raid0/data/pub/gnss/data/daily/${YEAR}/
LOCAL_TARGET=/raid0/data/pub/gnss/data/daily/${YEAR}/

${RSYNC} -e "${SSH} -p ${PORT}" -av root@${BABYLON}:${REMOTE_SOURCE} ${LOCAL_TARGET}
/bin/chmod -R 777 ${LOCAL_TARGET}
