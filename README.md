# singularity-docker-autoarch

A dockerfile that creates a docker image of singularity based on the CPU architecture that is running on the host machine. This has been tested working on arm64 and amd64 processors.

## Creating the image

Currently there a 2 ways to build this container based on what approach will work for you. If you are having issues building the file I suggest that you use the build_automated.sh script as it is based on **Docker Build** rather than the build_automated_build.sh as it is based on **Docker Buildx**. 

The ideal way of creating this image is to execute the script build_automated.sh or build_automated_buildx.sh, this script by default will execute with the following options enabled if no arguments are provided:

* User directory: /home/ubuntu
* Singularity version: 3.8.3
* GO version: 1.16.4

If you need to change these options you can use the flags available with the script, an example of this would be:

* sh build_automated.sh -u /home/user -s 3.8.3 -g 1.16.4

If your user directory is **NOT /home/ubuntu** you will need to use the -u flag to specifiy the user directory.
