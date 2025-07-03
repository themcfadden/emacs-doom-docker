#!/bin/bash

xhost +si:localuser:mattmc

docker run -it --rm \
       -e DISPLAY="$DISPLAY" \
       -w `pwd` \
       -v `pwd`:`pwd` \
       -v /tmp/.X11-unix:/tmp/.X11-unix \
       --net=host \
       emacs-docker $1

xhost -local:
