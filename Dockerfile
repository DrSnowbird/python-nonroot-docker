ARG BASE=${BASE:-python:3.8}
#ARG BASE=${BASE:-python:3.10}
FROM ${BASE}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ENV DEBIAN_FRONTEND noninteractive

##################################
#### ---- Tools: setup   ---- ####
##################################
ENV LANG C.UTF-8
ARG LIB_DEV_LIST="apt-utils"
ARG LIB_BASIC_LIST="curl wget unzip ca-certificates"
ARG LIB_COMMON_LIST="sudo bzip2 git xz-utils unzip vim net-tools"
ARG LIB_TOOL_LIST="graphviz"

RUN set -eux; \
    apt-get update -y && \
    apt-get install -y --no-install-recommends ${LIB_DEV_LIST}  ${LIB_BASIC_LIST}  ${LIB_COMMON_LIST} ${LIB_TOOL_LIST} && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
    
##############################################
#### ---- Installation Directories   ---- ####
##############################################
ENV INSTALL_DIR=${INSTALL_DIR:-/usr}
ENV SCRIPT_DIR=${SCRIPT_DIR:-$INSTALL_DIR/scripts}

############################################
##### ---- System: certificates : ---- #####
##### ---- Corporate Proxy      : ---- #####
############################################
COPY ./scripts ${SCRIPT_DIR}
COPY certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh
RUN ${SCRIPT_DIR}/setup_system_proxy.sh

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}
ENV WORKSPACE=${HOME}/workspace

ENV LANG C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends sudo curl vim git ack wget unzip ca-certificates && \
    useradd -ms /bin/bash ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p /home/${USER} && \
    mkdir -p /home/${USER}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown -R ${USER}:${USER} /home/${USER} && \
    apt-get autoremove; \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

################################################### 
#### ---- python3: pyenv                    ----  #
###################################################
#### ref: https://github.com/pyenv/pyenv
#### ref: https://github.com/pyenv/pyenv-virtualenv
#### Notes:
#### 1. There is a venv module available for CPython 3.3 and newer. 
####    It provides an executable module venv which is 
####    the successor of virtualenv and distributed by default. 
####    and distributed by default.
#### 2. If conda is available, 
####       pyenv virtualenv will use it to create environment by conda create
#### ----------------------------------------------
#### ---- python3: pyenv      ----
#### ---- plugin: virtualenv  ----
#### ----------------------------------------------
#### ---- Version:
####      >> pyenv version
#### ---- Create: virtualenv from current version
####      >> pyenv virutalenv myvenv
#### ---- Create: virtualenv new version
####      >> pyenv virutalenv 3.9.0 myvenv-3.9.0
#### ---- Activate: virtualenv:
####      >> pyenv activate myvenv
####      >> pyenv activate myvenv-3.9.0
#### ---- DeActivate: virtualenv:
####      >> pyenv deactivate
#### ---- Uninstall: virutalenv:
####      >> pyenv uninstall myvenv-3.9.0
####      >> pyenv virtualenv-delete my-virtual-env
#### ---- List: virtualenvs:
####      >> pyenv virtualenvs
#### ---- List All Python Versions:
####      >> pyenv install --list
#### ----------------------------------------------
USER ${USER}
WORKDIR ${HOME}

ENV SETUP_PYENV=${SETUP_PYENV:-0}
RUN if [ ${SETUP_PYENV} -gt 0 ]; then ${SCRIPT_DIR}/setup_system_proxy.sh; fi

RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    mkdir ${HOME}/bin
    
ENV PATH=${HOME}/.local/bin:${PATH}

########################################
#### ---- Set up NVIDIA-Docker ---- ####
########################################
## ref: https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)#usage
## set both NVIDIA_VISIBLE_DEVICES and NVIDIA_VISIBLE_DEVICES with GPU-IDs to control the GPUs available inside the container
ENV TOKENIZERS_PARALLELISM=${TOKENIZERS_PARALLELISM:-true}
ENV NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
ENV CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-compute,video,utility}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-/usr/local/cudnn/lib64:/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}}

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
COPY --chown=${USER}:${USER} docker-entrypoint.sh /
#COPY --chown=${USER}:${USER} scripts /scripts
ENTRYPOINT ["/docker-entrypoint.sh"]

##################################
#### ---- start user env ---- ####
##################################
USER ${USER}
WORKDIR ${HOME}

#CMD ["/bin/bash"]
CMD ["python", "-V"]

