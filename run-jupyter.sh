#!/bin/bash -x

DOCKER_IMAGE=openkbs/python-non-root
#docker run -i -t -p 8888:8888 ${DOCKER_IMAGE} /bin/bash -c "\
./run.sh  "\
    conda install jupyter -y --quiet && \
    mkdir -p /opt/notebooks && \
    jupyter notebook \
    --notebook-dir=/opt/notebooks --ip='*' --port=8888 \
    --no-browser --allow-root"
