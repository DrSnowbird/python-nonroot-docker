# Python 3 Base Container with Non-Root User setup
# * (**NEW**) `Auto detect & enable GPU/CUDA`

## Python 3 with no root access 
* A Python 3 base Container with `no root access` (except using `sudo ...` and you can remove it using `sudo apt-get remove sudo` to protect your Container). 
```
If [ you are looking for such a common requirement for a base Container ]:
   Then [ this one may be for you ]
```

# Components:
* Python 3 base image + pyenv
* Auto detect HOST's GPU/CUDA to enable Container accessing GPU
* No root setup: using /home/developer 
  * It has sudo for dev phase usage. You can "sudo apt-get remove sudo" to finalize the product image.
  * Note, you should consult Docker security experts in how to secure your Container for your production use!)

# Build (`Do this first!`)
Due to Docker Hub not allowing free host of pre-built images, you have to make local build to use!
```
./build.sh
```

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
* It will download 'yolov5s.pt' on-the-fly to use if not existing.
```
./run.sh
or, explicitly disable GPU to use CPU.
./run.sh -c
```
# Create your own image from this
```
FROM openkbs/python-non-root
```
# Quick commands
* build.sh - build local image
* logs.sh - see logs of container
* run.sh - run the container
* shell.sh - shell into the container
* stop.sh - stop the container
