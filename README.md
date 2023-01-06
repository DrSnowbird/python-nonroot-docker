# Python 3 (default v3.8) Base Container with Non-Root User setup
* A Python 3 base Container with `no root access` (except using `sudo ...` and you can remove it using `sudo apt-get remove sudo` to protect your Container). 
```
If [ you are looking for such a common requirement for a base Container ]:
   Then [ this one may be for you ]
```

# Key Features
##### (**NEW**) `Auto detect & enable GPU/CUDA`
##### (**NEW**) `Auto Corporate Proxy/SSL Certficates setup`
##### (**NEW**) `Auto APP Container project creation`
##### (**Safety**) `Non-root access inside Container`
* For deployment, you can disable it for security with (`sudo apt-get remove -y sudo`)

# Components:
* Python 3 (default v3.8) base image + pyenv
* Auto detect HOST's GPU/CUDA to enable Container accessing GPU
* No root setup: using /home/developer 
  * It has sudo for dev phase usage. You can "sudo apt-get remove sudo" to finalize the product image.
  * Note, you should consult Docker security experts in how to secure your Container for your production use!)

# Build (`Do this first!`)
* Due to Docker Hub not allowing free hosting services of pre-built images, you have to make local build to use in your environment
    ```
    make build
    ```

# Build/Run Container Inside Corporate Proxy or Networks
`(New!)` With this automation for setup proxy and corproate certificate for allowing the 'build and run' the Container behind your corporate networks!
* Step-1-A: Setup Corporate Proxy environment variables:
    If your corporate use proxy to access internet, then you can setup your proxy (in your Host's User envrionment variable ), e.g.,
    ```
    (in your $HOME/.bashrc profile)
    export http_proxy=proxy.openkbs.org:8080
    export https_proxy=proxy.openkbs.org:8443
    ```
    
* Step-1-B: If your corporate use zero-trust VPN, e.g., ZScaler, then just find and download your ZScaler and/or additional Corproate SSL/HTTPS certificates, e.g., my-corporate.crt, and then save it in the folder './certificates/', e.g.,
    ```
    (in folder ./certificates)
    ├── certificates
    │   └── my-corporate.crt
    ```
* Step-2: That's it! (Done!) Let the automation scripts chained by Dockerfile for building and running your local version of Container instance behind your Corporate Networks.

# Network (optional)
1. Use the following command to create 'docker network' to create "my_network_01":
```
export DOCKER_NETWORK=my_network_01;
make network
bin/auto-config-all.sh
```

2. To use the above your own customized network, you need to uncomment and modify './docker-compose.yml.template' which are "#" commented out at the very bottom of the file. For example, the "dev_network_01" -- (remember to use 'DOCKER_NETWORK=my_network_01' to automation to synchronize all related files! and don't change anything else especially the 'double-brace' meta variables!):
``` (./docker_compose.yml)
    ## -----------------------------
    ## -- Network setup if needed --
    ## -----------------------------
    networks:
      {{DOCKER_NETWORK}}:
        priority: 1000

networks:
  {{DOCKER_NETWORK}}:
    external:
      name: {{DOCKER_NETWORK}}
```
      
# Run (recommended for easy-start)
```
./run.sh
or,
make up
```
# Stop Running
```
./stop.sh
or
make down
```
# Generate an APP Container project from this Base Container
You can use one-command, `bin/generate-new-project.sh`, to automatically create fully build/run-able/test APP-container in seconds:
```
bin/generate-new-project.sh <folder_for_your_APP>
e.g.
bin/generate-new-project.sh ../my-app-docker
```
That's it! It will automatically create a fully (literally!) complete APP-Container project folder with everything from build, run, Makefile (for make buil, make up, or make down, etc.)

# Create your own image from this
```
FROM openkbs/python-nonroot-docker
```

# Quick commands
* Makefile - makefile for build, run, down, etc., e.g.:
    ```
    make build
    make up
    make down
    ```
* build.sh - build local image
* logs.sh - see logs of container
* run.sh - run the container
* shell.sh - shell into the container
* stop.sh - stop the container

# Pyenv Cheatsheet
* [pyenv intro](https://realpython.com/intro-to-pyenv/)
* [pyenv GIT](https://github.com/pyenv/pyenv)
* [pyenv-virtualenv GIT](https://github.com/pyenv/pyenv-virtualenv)
```
curl https://pyenv.run | bash
This will install pyenv along with a few plugins that are useful:
- pyenv: The actual pyenv application
- pyenv-virtualenv: Plugin for pyenv and virtual environments
- pyenv-update: Plugin for updating pyenv
- pyenv-doctor: Plugin to verify that pyenv and build dependencies are installed
- pyenv-which-ext: Plugin to automatically lookup system commands

Notes:
1. There is a venv module available for CPython 3.3 and newer.  
   It provides an executable module venv which is   
   the successor of virtualenv and distributed by default.  
   and distributed by default.
2. If conda is available,  
      pyenv virtualenv will use it to create environment by conda create
------------------------------------------
python3: pyenv      ----
plugin: virtualenv  ----
------------------------------------------
- Pyenv's Version:
    > pyenv version
- Create: virtualenv from current version
    > pyenv virutalenv myvenv
- Create: virtualenv new version
    > pyenv virutalenv 3.9.0 myvenv-3.9.0
- Activate: virtualenv:
    > pyenv activate myvenv
    > pyenv activate myvenv-3.9.0
- DeActivate: virtualenv:
    > pyenv deactivate
- Uninstall: virutalenv:
    > pyenv uninstall myvenv-3.9.0
    > pyenv virtualenv-delete my-virtual-env
- List: virtualenvs:
    > pyenv virtualenvs
- List All Python Versions:
    > pyenv install --list
- Install specific version:
    > pyenv install -v 3.10.0
```
# Run (GPU/Nvidia - Auto Enable)
* For the **HOST / VM** (not Docker):
  * To run GPU/Nvidia, you need to install the `Nvidia Driver` in your `HOST machine` first and then install `nvidia-docker2`.
  * Please refer to [`Nvidia Container Toolkit`](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) documentation for how to install properly
  * You also need to setup environment variables once you have successfully install `Nvidia driver` and `Nvidia-docker2` Container Toolkit `before you run Docker` (trying to use nvidia-docker2). 
It's recommended to setup in your **HOST / VM Machine's user account's** `.bashrc` profile.
```
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

./run.sh -g
or, let it auto check and use Nvidia GPU if available:
./run.sh
```

## Run (If choose only CPU!)
```
./run.sh
or, explicitly disable GPU to use CPU.
./run.sh -c
```
# Create your own image from this
```
FROM openkbs/python-nonroot-docker
```

# Release versions for components
```
developer@192:~$ /usr/scripts/printVersions.sh 
JAVA_HOME=
java:

/usr/local/bin/python
Python 3.8.13
/usr/local/bin/python3
Python 3.8.13
/usr/local/bin/pip
pip 22.0.4 from /usr/local/lib/python3.8/site-packages/pip (python 3.8)
/usr/local/bin/pip3
pip 22.0.4 from /usr/local/lib/python3.8/site-packages/pip (python 3.8)
PRETTY_NAME="Debian GNU/Linux 11 (bullseye)"
NAME="Debian GNU/Linux"
VERSION_ID="11"
VERSION="11 (bullseye)"
VERSION_CODENAME=bullseye
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
```

