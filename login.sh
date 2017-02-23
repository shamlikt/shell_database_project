#!/bin/sh

PASS=$1
TIME=$2
DATABASE=$3
function_check_user(){
  expect <<- DONE
     set timeout $TIME
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
