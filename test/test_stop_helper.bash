start_helper() {
  sudo docker stop $CONTAINER_ID
  sudo docker rm $CONTAINER_ID

  sudo docker rmi $IMAGE_NAME
}
