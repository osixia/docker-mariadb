setup() {
  IMAGE_NAME="$NAME:$VERSION"
}
  
build_image() {
  #disable outputs
  docker build -t $IMAGE_NAME $BATS_TEST_DIRNAME/../image &> /dev/null
}

run_image() {
  CONTAINER_ID=$(docker run $@ -d $IMAGE_NAME)
}

start_container() {
  #disable outputs
  docker start $CONTAINER_ID &> /dev/null
}

stop_container() {
  #disable outputs
  docker stop $CONTAINER_ID &> /dev/null
}

remove_container() {
  #disable outputs
 docker rm $CONTAINER_ID &> /dev/null
}

clear_container() {
  stop_container
  remove_container
}

is_service_running() {
  docker exec $CONTAINER_ID ps cax | grep $1  > /dev/null
}

wait_service() {
  
  # first wait image init end
  while ! is_service_running syslog-ng
  do
    sleep 1
  done

  # wait service
  while ! is_service_running $1
  do
    sleep 1
  done

  sleep 5
}

