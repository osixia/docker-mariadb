#!/usr/bin/env bats
load test_helper

setup() {
  CONTAINER_ID=`sudo docker run -d $IMAGE_NAME`
}

teardown() {
  sudo docker stop $CONTAINER_ID
  sudo docker rm $CONTAINER_ID
}

@test "uninitialized database" {
  run echo $CONTAINER_ID
  [ "$status" -eq 0 ]
  [ "$output" = "$CONTAINER_ID" ]
}


