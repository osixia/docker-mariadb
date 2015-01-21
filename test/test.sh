#!/bin/bash

IMAGE_NAME=''

. test_helper.bash

sudo docker build -t $IMAGE_NAME ../image
clear

bats test.bats
