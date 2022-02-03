ARG BASE=${BASE:-python:3.9}
FROM ${BASE}

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ENV DEBIAN_FRONTEND noninteractive

#### ------------------------------------------------------------------------
#### ---- User setup so we don't use root as user ----
#### ------------------------------------------------------------------------
ARG USER_ID=${USER_ID:-1000}
ENV USER_ID=${USER_ID}

ARG GROUP_ID=${GROUP_ID:-1000}
ENV GROUP_ID=${GROUP_ID}
    
ARG USER=${USER:-developer}
ENV USER=${USER}

ENV WORKSPACE=${HOME}/workspace

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}
ENV USER=${USER:-developer}
ENV HOME=/home/${USER}

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

RUN curl -k https://pyenv.run | bash && \
    echo "export PYENV_ROOT=\$HOME/.pyenv" >> ~/.bashrc && \
    echo "export PATH=\$PYENV_ROOT/bin:\$HOME/.local/bin:\$PATH" >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv init --path)\" " >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv init -)\" " >> $HOME/.bashrc && \
    echo "eval \"\$(pyenv virtualenv-init -)\" " >> $HOME/.bashrc && \
    echo "pyenv virtualenv myvenv" >> $HOME/.bashrc && \
    echo "pyenv activate myvenv" >> $HOME/.bashrc
    
RUN echo "alias venv='pyenv virtualenv'" >> $HOME/.bashrc && \
    echo "alias activate='pyenv activate'" >> $HOME/.bashrc && \
    echo "alias deactivate='pyenv deactivate'" >> $HOME/.bashrc && \
    echo "alias venv-delete='pyenv virtualenv-delete'" >> $HOME/.bashrc
    
ENV PYENV_ROOT=${HOME}/.pyenv

RUN sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    mkdir ${HOME}/bin

########################################
#### ---- Set up NVIDIA-Docker ---- ####
########################################
## ref: https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)#usage
ENV TOKENIZERS_PARALLELISM=false
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
COPY --chown=${USER}:${USER} docker-entrypoint.sh /
COPY --chown=${USER}:${USER} scripts /scripts
COPY --chown=${USER}:${USER} certificates /certificates
RUN /scripts/setup_system_certificates.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

##################################
#### ---- start user env ---- ####
##################################
USER ${USER}
WORKDIR ${HOME}

#CMD ["/bin/bash"]
CMD ["python", "-V"]

