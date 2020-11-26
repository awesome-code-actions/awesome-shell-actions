#!/bin/bash

# sudo apt install mongo-tools
# sudo apt install mongo-client

# drop(uri:string,col:string)
function drop {
    local uri=$1
    local col=$2
    mongo $uri --eval "db.$col.drop()"
}

# dump(uri:string,col:string)
function dump {
    local uri=$1
    local col=$2
    local out=$3

    mongodump --forceTableScan  --uri=$uri  -c $col --out $out
}

# load(uri:string,dir:string)
function load {
    local uri=$1
    local dir=$2
    mongorestore --drop --uri=$uri $dir
}

# list_col(uri:string,filter:string)
function list_col {
   local res=`echo show collections |mongo $1 --quiet |grep $2` 
   echo $res
}

# dump(uri:string,list:space_split_string,out:string)
function dump_by_list {
    local uri=$1
    local list=$2
    local out=$3
    echo $list
    for col in ${list[@]}; do
        dump $uri $col $out
        echo dump $col to $out
    done
}

function drop_by_filter {
    local uri=$1
    local filter=$2
    local cols=$(list_col $uri $filter)
    for col in $cols; do
        drop $uri $col 
        echo drop $col
    done
}

# dump(uri:string,filter:string,out:string)
function dump_by_filter {
    local uri=$1
    local filter=$2
    local out=$3

    local cols=$(list_col $uri $filter)
    for col in $cols; do
        dump $uri $col $out
        echo dump $col to $out
    done
}


FROM_URL="mongodb://127.0.0.1:27017/a"
TO_URL="mongodb://127.0.0.1:27017/b"

DIR="./out"


# dump_by_list $FROM_URL "teams users jobs" $DIR
# dump_by_filter $FROM_URL goals $DIR
# load $TO_URL $DIR
# drop_by_filter $FROM_URL goals
# drop $FROM_URL goals_key_results

