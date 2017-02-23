#!/bin/sh

DATABASE='user_data.kdb'
PASS=$1
time=4
function_check_user(){
  expect <<- DONE
     set timeout $time
     spawn kpcli
     match_max 100000000
     expect  "kpcli:/>"
     send    "open $DATABASE\n"
     expect  "*Please provide the master password:*"
     send    "$PASS\n"
     expect  "Couldn't load*"
DONE

    }

function_check_user
