#FROM continuumio/miniconda3
#FROM conda/miniconda3
FROM python:3.8

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

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

RUN apt-get update && apt-get install -y sudo && \
    useradd -ms /bin/bash ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p /home/${USER} && \
    mkdir -p /home/${USER}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown ${USER}:${USER} -R /home/${USER}

################################ 
#### ---- Entrypoint setup ----#
################################
#### --- Copy Entrypoint script in the container ---- ####
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

############################### 
#### ---- Workspace setup ----#
###############################
VOLUME "${HOME}/data"
VOLUME "${HOME}/workspace"

#### ------------------------------------------------------------------------
#### ---- Change to user mode ----
#### ------------------------------------------------------------------------
USER ${USER}
WORKDIR ${HOME}

#CMD ["/bin/bash"]
CMD ["python", "-V"]

