#!/bin/bash

DATABASE='user_data.kdb'
TIMEOUT=4

function_login(){
     function_validate_user
     case $? in
         1)
             echo "login";;
         2)
             dialog --backtitle "Information system" --title "User authentication" --msgbox  "Passowrd is incorrect" 10 30
             function_login
     esac
}


function_validate_user(){
    DIALOG=${DIALOG=dialog}
    PASSWORD=`$DIALOG --stdout --backtitle "Information system"  --passwordbox "Enter your password" 10 30`;
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

function_remove_lock_file(){
    lock_file="$DATABASE.lock"
    if [ -f $lock_file ]; then
        rm $lock_file
    fi
}
 
function_add_category() {
    function_remove_lock_file
    DIALOG=${DIALOG=dialog}
    CA_VALUES=`$DIALOG --stdout --ok-label "Submit" \
	                 --backtitle "Information system" \
	                 --title "Category add" \
	                 --form "Create a new Catogery" \
                     15 50 0 \
	                 "id:" 1 1	"$id" 	1 10 10 0 \
	                 "category:"    2 1	"$category"  	2 10 15 0 \


          `
    echo $CA_VALUES
    local category_name=$(echo "$CA_VALUES" | awk 'NR==2')
    local category_id=$(echo "$CA_VALUES" | awk 'NR==1')
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

function_get_category_id_from_number(){
    local category_number=$1
    local temp_file='.temp'
    name=$1
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
     puts [open $temp_file w] \$expect_out(buffer)
DONE
          )
    grep '\.' $temp_file > .temp_ && mv -f .temp_ $temp_file
    ct_id=$(cat .temp | head -n $category_number | tail -1 | cut -d ' ' -f 2)
    echo $ct_id
    rm -f $temp_file
}


function_get_all_category(){
    local category_name=$1
    local temp_file='.temp'
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
     puts [open $temp_file w] \$expect_out(buffer)
DONE
          )
    grep '\.' $temp_file > .temp_ && mv -f .temp_ $temp_file
    
    cat $temp_file | while  read line;do
    echo $line | cut -d '=' -f 2
    done
    rm -f $temp_file
}


function_add_customer(){
    function_remove_lock_file
    DIALOG=${DIALOG=dialog}
    VALUES=`$DIALOG --stdout --ok-label "Submit" \
	                 --backtitle "Information system" \
	                 --title "Customer add" \
	                 --form "Create a new customer" \
                     15 50 0 \
	                 "Name:" 1 1	"$c_name" 	1 10 10 0 \
	                 "Id:"    2 1	"$c_id"  	2 10 15 0 \
	                 "Phone:" 3 1	"$c_phone"  3 10 15 0 \

           `

    options=$(function_get_all_category)
    MENU_OPTIONS=
    COUNT=0
    for i in $options
    do
        COUNT=$[COUNT+1]
        MENU_OPTIONS="${MENU_OPTIONS} ${COUNT} $i off"
    done
    cmd=(dialog  --radiolist "Select options:" 22 76 16)
    options=(${MENU_OPTIONS})
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    local customer_name=$(echo "$VALUES" | awk 'NR==1')
    local customer_id=$(echo "$VALUES" | awk 'NR==2')
    local customer_phone=$(echo "$VALUES" | awk 'NR==3')

    local category_id=$(function_get_category_id_from_number $choice)
    echo $customer_name
    echo $customer_id
    echo $customer_phone
    echo $category_id
    expect <<- DONE
     set timeout $time
     spawn kpcli
     match_max 100000000
     expect  "kpcli:/>"
     send    "open $DATABASE\n"
     expect  "*Please provide the master password:*"
     send    "$PASSWORD\n"
     expect  "kpcli:/>"
     send    "cd Customer\n"
     expect  "*Customer>"
     send    "new\n"
     expect  "*Title:"
     send    "$customer_name\n"
     expect  "*Username:"
     send    "$customer_name\n"
     expect  "*interactive)"
     send    "g\n"
     expect  "URL:"
     send    "id=$customer_id\n"
     expect  "|"
     send    "category_id=$category_id\n"
     expect  "|"
     send    "phone=$customer_phone\n"
     send    ".\n"
     expect  "N]"
     send    "y\n"
     expect  "kpcli:/Customer>"
     send    "exit"
DONE

}

function_login(){
     function_validate_user
     case $? in
         1)
             function_dashboard;;
         2)
             dialog --backtitle "Information system" --title "User authentication" --msgbox  "Passowrd is incorrect" 10 30
             function_login
     esac

}


function_dashboard(){
    DIALOG=${DIALOG=dialog}
    value=`$DIALOG --stdout --title "Choose option" \
       --backtitle "Information system"\
       --menu "Please choose an option:" 15 55 3 \
       1 "Add category" \
       2 "Add Customer" \
       `
    
    case $value in
         1)
             function_add_category
             function_dashboard
             ;;
         2)
             function_add_customer
             function_dashboard
             ;;
     esac

}

function_login
    
 
