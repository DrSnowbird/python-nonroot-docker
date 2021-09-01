# Python 3 Base Container with Non-Root User setup
# * (**NEW**) `Auto detect & enable GPU/CUDA`

## Python 3 with no root access 
* A Python 3 base Container with `no root access` (except using `sudo ...` and you can remove it using `sudo apt-get remove sudo` to protect your Container). 
```
If [ you are looking for such a common requirement for a base Container ]:
   Then [ this one may be for you ]
```

# Components:
* Python 3 base image
* Auto detect HOST's GPU/CUDA to enable Container accessing GPU
* No root setup: using /home/developer 
  * It has sudo for dev phase usage. You can "sudo apt-get remove sudo" to finalize the product image.
  * Note, you should consult Docker security experts in how to secure your Container for your production use!)

# Build (`Do this first!`)
Due to Docker Hub not allowing free host of pre-built images, you have to make local build to use!
```
./build.sh
```

# Run (GPU/Nvidia - Auto Enable)
* To run GPU/Nvidia, you need to install the `Nvidia Driver` in your `HOST machine` first and then install `nvidia-docker2`.
* Please refer to [`Nvidia Container Toolkit`](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker) documentation for how to install properly
* You also need to setup environment variables once you have successfully install `Nvidia driver` and `Nvidia-docker2` Container Toolkit `before you run Docker` (trying to use nvidia-docker2). 
It's recommended to setup in your HOST VM or Machine's user account's `.bashrc` profile.
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
