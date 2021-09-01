#!/bin/bash

set -e

whoami

env | sort

echo "Inputs: $*"

############################################
#### ---- set command pattern here ---- ####
############################################
CMD_PATTERN=""

#### ------------------------------------------------------------------------
#### ---- Extra line added in the script to run all command line arguments
#### ---- To keep the docker process staying alive if needed.
#### ------------------------------------------------------------------------
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

