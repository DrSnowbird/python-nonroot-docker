#!/bin/bash -x

#set -e

whoami

env | sort

echo "Inputs: $*"

############################################
#### ---- set command pattern here ---- ####
############################################
CMD_PATTERN=""

############################################
#### ---- set up virutalenv here:  ---- ####
############################################

set -v
if [ $# -gt 0 ]; then

    ############################################
    #### 1.) Setup needed stuffs, e.g., init db etc. ....
    #### (do something here for preparation)
    ############################################

    if [ "${CMD_PATTERN}" != "" ] && [[ $1 =~ "${CMD_PATTERN}" ]]; then
        echo ">>>> Seen command: ${CMD_PATTERN} : ... wait indefinitely ..."
        $@
        tail -f /dev/null
    else
        echo ">>>> Not Seen command: ${CMD_PATTERN} : ... continue"
        $@
    fi

else
    /bin/bash
fi

