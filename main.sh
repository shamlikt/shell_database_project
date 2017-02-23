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
     expect  "Password:"
     send    "g\n"
     expect  "URL:"
     send    "id=$category_id\n"
     expect  "*(end multi-line input with a single "." on a line)*"
     send    "None.\n"
     expect  "*[y/N]"
     send    "y\n"
     expect  "kpcli:/Category>"
     send    "cd .."
     expect  "kpcli:/>"
DONE
 }
#function_validate_user
#echo $?

function_add_category goo 10
