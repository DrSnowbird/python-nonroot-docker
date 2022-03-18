#!/bin/bash -x

echo "####################### Components: $(basename $0) ###########################"

if [ -s "/usr/bin/sudo" ]; then
    sudo=sudo
else
    sudo=""
fi

cat /etc/*rel*

find . -name "ca-certificates"

if [ "$1" != "" ]; then
    SOURCE_CERTIFICATES_DIR=${SOURCE_CERTIFICATES_DIR:-$1}
else
    SOURCE_CERTIFICATES_DIR=${SOURCE_CERTIFICATES_DIR:-/certificates}
fi

CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/pki/ca-trust/source/anchors/}

#### ---------------------------------------------------------------------------------------------------------------------------------- ####
#### ---- (ref: https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself)
#### ---------------------------------------------------------------------------------------------------------------------------------- ####
function findMyAbsDir() {
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    MY_ABS_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
}
# findMyAbsDir
MY_ABS_DIR=$(dirname "$(readlink -f "$0")")

#### ---- Usage ---- ####
function usage() {
    echo "Usage setup_system_certificates -d <certificates_dir> [ -h | --help]"
}

#### ---- Usage ---- ####
ORIG_ARGS="$*"
SHORT="hd:"
LONG="help,certificates_dir:"

# $@ is all command line parameters passed to the script.
# -o is for short options like -v
# -l is for long options with double dash like --version
# the comma separates different long options
# -a is for long options with single dash like -version
#OPTIONS=$(getopt --options ${SHORT} --longoptions ${LONG} --name "$0" -a -- "$@")
OPTIONS=$(getopt -o ${SHORT} -l ${LONG} --name "$0" -a -- "$@")

if [[ $? != 0 ]]; then
    echo "Arguments Parsing Error! Abort!"
    exit 1
fi
eval set -- "${OPTIONS}"

while true; do
    case "$1" in
        -h|--help)
            usage "Usage setup_system_certificates -d <certificates_dir> [ -h | --help]"
            ;;
        -d|--certificates_dir)
            shift
            SOURCE_CERTIFICATES_DIR=$1
            echo "SOURCE_CERTIFICATES_DIR=$SOURCE_CERTIFICATES_DIR"
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "*****: input args error"
            echo "$ORIG_ARGS"
            exit 3
            ;;
    esac
    shift
done

echo "ORIGINAL INPUT >>>>>>>>>>:"
echo "${ORIG_ARGS}"
echo "-------------"

#### -------------------------------------------------
#### OS_TYPE=
#### >>>
#### 0: OS_TYPE_NOT_FOUND
#### 1: ubuntu/debian
#### 2: centos/redhat/fedora
#### 3: alpine
#### 4: others
#### -------------------------------------------------
OS_TYPE=0

REPO_CONF=/etc/apt/apt.conf
ETC_ENV=/etc/environment
APT_PATH=/usr/bin/apt
YUM_PATH=/usr/bin/yum

OS_NAME=
function detectOS_alt() {
    OS_NAME="`which yum`"
    if [ -s ${APT_PATH} ]; then
        OS_NAME="ubuntu"
        OS_TYPE=1
    elif [ -s ${YUM_PATH} ]; then
        OS_NAME="centos"
        OS_TYPE=2
    fi
 
}


function detectOS() {
    OS_NAME="`cat /etc/os-release |grep -i '^id='|cut -d'=' -f2|cut -d'"' -f2 | tr '[:upper:]' '[:lower:]'`"
    #OS_NAME="`cat /etc/os-release | grep -i '^NAME=\"Ubuntu\"' | awk -F= '{print $2}' | tr '[:upper:]' '[:lower:]' |sed 's/"//g' `"
    if [ "${OS_NAME}" == "" ]; then
        detectOS_alt
    fi
    case ${OS_NAME} in
        ubuntu*|debian*)
            OS_TYPE=1
            REPO_CONF=/etc/apt/apt.conf
            ETC_ENV=/etc/environment
            ;;
        centos*)
            OS_TYPE=2
            REPO_CONF=/etc/yum.conf
            ETC_ENV=/etc/environment
            ;;
        alpine*)
            OS_TYPE=3
            REPO_CONF=/etc/conf.d
            ETC_ENV=/etc/environment
            ;;
        *)
            OS_TYPE=0
            REPO_CONF=
            ETC_ENV=
            echo "***** ERROR: Can't detect OS Type (e.g., Ubuntu, Centos)! *****"
            echo "Abort now!"
            exit 9
            ;;
    esac
}
detectOS

#### --------------------------------------------------------------------------------------------
#### After these steps the new CA is known by system utilities like curl and get. 
#### Unfortunately, this does not affect most web browsers like Mozilla Firefox or Google Chrome.
#### -------------------------------------------------------------------------------------------- 
## -- CentOS
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/pki/ca-trust/source/anchors}
## -- Debian/Ubuntu
# /etc/ca-certificates
# /usr/local/share/ca-certificates
# /usr/sbin/update-ca-certificates
# /usr/share/doc/ca-certificates
# /usr/share/ca-certificates
# /var/lib/dpkg/triggers/update-ca-certificates
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/usr/local/share/ca-certificates}
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/usr/share/ca-certificates}
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/ca-certificates}
# CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/ssl/certs}

## -- Converting from PEM to CRT: -- ##
## openssl x509 -ouform der -in Some-Certificate.pem -out Some-Certificate.crt

#    update-ca-certificates # (for Ubuntu OS)
#    # update-ca-trust extract # (for CentOS OS)
#### (Unbunt version)
#CERTITICATES_INSTALL_DIR=/usr/local/share/ca-certificates/extra
if [ $OS_TYPE -eq 1 ]; then
    # -- Ubuntu --
    #CERT_COMMAND=`which update-ca-certificates`
    CERT_COMMAND=/usr/sbin/update-ca-certificates
    CMD_OPT=
    CERTITICATES_INSTALL_DIR=/usr/local/ca-certificates
    if [ -s /usr/local/share/ca-certificates ]; then
        CERTITICATES_INSTALL_DIR=/usr/local/share/ca-certificates
    fi
elif [ $OS_TYPE -eq 2 ]; then
    # -- CentOS --
    #CERT_COMMAND=`which update-ca-trust`
    CERT_COMMAND=/usr/bin/update-ca-trust
    #CMD_OPT=extract
    #CMD_OPT="force-enable"
    CMD_OPT=
    CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/etc/pki/ca-trust/source/anchors/}
elif [ $OS_TYPE -eq 3 ]; then
    # -- Alpine --
    # https://hackernoon.com/alpine-docker-image-with-secured-communication-ssl-tls-go-restful-api-128eb6b54f1f
    CERT_COMMAND=`which update-ca-certificates`
    #CERT_COMMAND=/usr/sbin/update-ca-certificates
    CMD_OPT=
    CERTITICATES_INSTALL_DIR=${CERTITICATES_INSTALL_DIR:-/usr/local/share/ca-certificates/}
    if [ -s /usr/local/share/ca-certificates ]; then
        CERTITICATES_INSTALL_DIR=/usr/local/share/ca-certificates
    fi
    #CERTIFICATES_FILE=${CERTIFICATES_FILE:-mitre-chain.txt}
    # wget -O mitre-chain.crt --no-check-certificate https://gitlab.mitre.org/mitre-scripts/mitre-pki/raw/master/normalized/mitre-chain.txt
    #wget -O ${CERTIFICATES_FILE} --no-check-certificate https://gitlab.mitre.org/mitre-scripts/mitre-pki/raw/master/normalized/${CERTIFICATES_FILE}
    apk update && apk add ca-certificates && rm -rf /var/cache/apk/* 
    #cp ${CERTIFICATES_FILE} /usr/local/share/ca-certificates/
    #update-ca-certificates
else
    echo "OS_TYPE Unknown! Can't do! Abort!"
    exit 1
fi

function setupSystemCertificates() {
    echo "================= Setup System Certificates ===================="
    if [ ! -s ${CERTITICATES_INSTALL_DIR} ]; then
        echo -e "*** CERTITICATES_INSTALL_DIR: ${CERTITICATES_INSTALL_DIR}: Not Found!"
        $sudo mkdir -p ${CERTITICATES_INSTALL_DIR}
    fi
    if [ -s /etc/ca-certificates/update.d/docker-openjdk ]; then
        sudo cat /etc/ca-certificates/update.d/docker-openjdk
        echo ">> JAVA PATH=`which java`"
        $sudo sed -i "s#\$JAVA_HOME#$JAVA_HOME#g" /etc/ca-certificates/update.d/docker-openjdk
        env | grep -i java
        sudo cat /etc/ca-certificates/update.d/docker-openjdk
    fi
    ls -al  ${SOURCE_CERTIFICATES_DIR}/*
    echo -e ">>> ------------------------------"
    CERT_FILES=`ls ${SOURCE_CERTIFICATES_DIR}/* | grep 'pem\|crt' | grep -v dummy`
    echo -e ">>> ------------------------------"
    echo -e ">>> /certificates: ${CERT_FILES}"
    echo -e ">>> ------------------------------"
    #for certificate in `$sudo ls ${SOURCE_CERTIFICATES_DIR}/* | grep '*.pem\|*.crt' | grep -v dummy`; do
    for cert_file in ${CERT_FILES}; do
        filename=$(basename -- "$certificate")
        extension="${filename##*.}"
        ## -- Converting from PEM to CRT: -- ##
        ## openssl x509 -ouform der -in Some-Certificate.pem -out Some-Certificate.crt
        #if [[ "${cert_file}" == *"pem" ]]; then
        if [ "${extension}" == "pem" ]; then
            $sudo openssl x509 -ouform der -in ${cert_file} -out ${SOURCE_CERTIFICATES_DIR}/${filename//pem/crt}
        fi
        #if [[ "${cert_file}" == *"crt" ]]; then
        if [ "${extension}" == "crt" ]; then
            #$sudo cp root.cert.pem /usr/local/share/ca-certificates/root.cert.crt
            # $sudo cp ${SOURCE_CERTIFICATES_DIR}/${cert} ${CERTITICATES_INSTALL_DIR}/${filename}
            $sudo cp ${cert_file} ${CERTITICATES_INSTALL_DIR}/
        else
            echo "... ignore non-certificate file: $cert"
        fi
    done
    $sudo ${CERT_COMMAND} ${CMD_OPT}
}
setupSystemCertificates 

#### --------------------------------------------------------------------------------------------
#### ---- Browsers (Firefox, Chromium, etc.) Root Certificates Setup
#### ---- (ref: https://thomas-leister.de/en/how-to-import-ca-root-certificate/)
#### --------------------------------------------------------------------------------------------
function setupBrowserRootCertificates() {
    ### Script installs root.cert.pem to certificate trust store of applications using NSS
    ### (e.g. Firefox, Thunderbird, Chromium)
    ### Mozilla uses cert8, Chromium and Chrome use cert9

    ###
    ### Requirement: apt install libnss3-tools
    ###


    ###
    ### CA file to install (CUSTOMIZE!)
    ###

    certfile="root.cert.pem"
    certname="My Root CA"

    ###
    ### For cert8 (legacy - DBM)
    ###

    for certDB in $(find ~/ -name "cert8.db")
    do
        certdir=$(dirname ${certDB});
        certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d dbm:${certdir}
    done

    ###
    ### For cert9 (SQL)
    ###

    for certDB in $(find ~/ -name "cert9.db")
    do
        certdir=$(dirname ${certDB});
        certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d sql:${certdir}
    done
}

