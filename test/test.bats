#!/usr/bin/env bats
load test_helper

@test "image build" {

  run build_image
  [ "$status" -eq 0 ]

}

@test "container with uninitialized database" {

  run_image
  wait_service mysqld
  run docker exec $CONTAINER_ID mysql -u admin -padmin --skip-column-names -e "select distinct user from mysql.user where user='admin';"
  clear_container

  [ "$status" -eq 0 ]
  [ "$output" = "admin" ]

}

@test "start, stop and restart container with uninitialized database" {

  run_image
  wait_service mysqld
  docker exec $CONTAINER_ID mysql -u admin -padmin --skip-column-names -e "CREATE USER 'hello'@'%' IDENTIFIED BY 'password' ;"
  stop_container
  start_container
  wait_service mysqld
  run docker exec $CONTAINER_ID mysql -u admin -padmin --skip-column-names -e "select distinct user from mysql.user where user='hello';"
  clear_container

  [ "$status" -eq 0 ]
  [ "$output" = "hello" ]

}

@test "container with initialized database" {

  run_image -v $BATS_TEST_DIRNAME/database:/var/lib/mysql
  wait_service mysqld
  run docker exec $CONTAINER_ID mysql -u admin -padmin --skip-column-names -e "select distinct user from mysql.user where user='existing-hello';"
  clear_container
  UNAME=$(sed -e 's#.*/\(\)#\1#' <<< "$HOME") || true
  chown -R $UNAME:$UNAME $BATS_TEST_DIRNAME/database || true

  [ "$status" -eq 0 ]
  [ "$output" = "existing-hello" ]

}
