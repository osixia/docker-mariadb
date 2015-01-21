start_helper() {
  IMAGE_NAME='test-image'

  sudo docker build -t $IMAGE_NAME ../image
  CONTAINER_ID=`sudo docker run -d $IMAGE_NAME`
}
