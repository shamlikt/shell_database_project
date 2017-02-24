#!/bin/sh 

DATABASE='user_data.kdb'
PASSWORD='testtest'
TIMEOUT=4

function_validate_user(){
    START=$(date +%s)
    ./login.sh $PASSWORD $TIMEOUT $DATABASE > /dev/null
    END=$(date +%s)
    DIFF=$(( $END - $START ))
    if [ $TIMEOUT -eq $DIFF ]; then
        return 1
    else
        return 2
    fi
}

function_add_category() {
    local category_name=$1
    local category_id=$2
    expect <<- DONE
     set timeout $time
     spawn kpcli
     match_max 100000000
     expect  "kpcli:/>"
     send    "open $DATABASE\n"
     expect  "*Please provide the master password:*"
     send    "$PASSWORD\n"
     expect  "kpcli:/>"
     send    "cd Category\n"
     expect  "*Category>"
     send    "new\n"
     expect  "*Title:"
     send    "$category_name\n"
     expect  "*Username:"
     send    "$category_name\n"
     expect  "*interactive)"
     send    "g\n"
     expect  "URL:"
     send    "id=$category_id\n"
     expect  "|"
     send    ".\n"
     expect  "N]"
     send    "y\n"
     expect  "kpcli:/Category>"
     DONE
 }
#function_validate_user
#echo $?

# function_add_category shoo 10
# echo foo

function_get_all_category(){
    local category_name=$1
    output=$(
     expect <<- DONE
     set timeout $time
     spawn kpcli
     match_max 100000000
     expect  "kpcli:/>"
     send    "open $DATABASE\n"
     expect  "*Please provide the master password:*"
     send    "$PASSWORD\n"
     expect  "kpcli:/>"
     send    "cd Category\n"
     expect  "*Category>"
     send    "ls\n"
     expect  "/Category>"
      puts  $expect_out(buffer)
     DONE
     )
     echo $output
}

