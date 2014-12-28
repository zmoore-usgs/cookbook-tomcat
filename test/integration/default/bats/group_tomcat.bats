#!/usr/bin/env bats

@test "Group 'tomcat' created" {
  run egrep -i "^tomcat" /etc/group
  [ "$status" -eq 0 ]
}
