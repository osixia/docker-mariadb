load test_start_helper


@test "uninitialized database" {
  run echo 0
  [ "$status" -eq 0 ]
  [ "$output" = "foo: no such file 'nonexistent_filename'" ]
}


