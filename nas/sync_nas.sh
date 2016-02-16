#! /bin/bash

##  Synchronize folders between raskolnikov and babylon. This scripts expects
##+ that you can ssh from raskolnikov to babylon without using a pass, i.e.
##+ babylon should have the pub key of babylon in .ssh/authorized_keys, in
##+ the root's $HOME directory.

SSH=/opt/openssh/bin/ssh
RSYNC=/opt/bin/rsync
PORT=2592
BABYLON=147.102.106.135
REMOTE_SOURCE=~/../raid0/data/pub/tide-gauge/megisti/
LOCAL_TARGET=/raid0/data/pub/tide-gauge/megisti/

##  Execute and let God have mercy on our souls
${RSYNC} -e "${SSH} -p ${PORT}" -av root@${BABYLON}:${REMOTE_SOURCE} ${LOCAL_TARGET}

##  These are 777 
/bin/chmod -R 777 ${LOCAL_TARGET}
