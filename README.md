# singularity-docker-autoarch

A dockerfile that creates a docker image of singularity based on the CPU architecture that is running on the host machine. This has been tested working on arm64 and amd64 processors.

## Creating the image

The ideal way of creating this image is to execute the script build_automated.sh, this script by default will execute with the following options enabled if no arguments are provided:

* User directory: /home/ubuntu
* Singularity version: 3.8.3
* GO version: 1.16.4

If you need to change these options you can use the flags available with the script, an example of this would be:

* sh build_automated.sh -u /home/user -s 3.8.3 -g 1.16.4

If your user directory is **NOT /home/ubuntu** you will need to use the -u flag to specifiy the directory your user directory.
