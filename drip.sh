#!/bin/sh

finally() {
    RET=$?
    echo "return code: $RET"
    if [ $RET -ne 0 ]; then
        # chatch block
        echo "stop"

    else
        echo "no error (OK!)"
    fi
    # try block
    echo "sass_id"
    echo $sass_id
    kill -9 $coffee_id
    kill -9 $sass_id
    echo "good bye"

    exit $RET
}

compile_haml(){
    haml $1 `echo $1 | sed -e s%$HAML_SRC/%% | sed -e s/.haml/.html/`
}

get_time_stamp(){
    echo `ls -l -T $1 | awk '{print $6$7$8}' | sed -e s/://g`
}

set -e
trap finally EXIT

# try block

HAML_SRC=haml

coffee -w -o js/ -c coffee/*.coffee &
coffee_id=$!

sass --watch sass:css &
sass_id=$!

INTERVAL=1 #監視間隔, 秒で指定
last=`get_time_stamp haml/index.haml`

files=${HAML_SRC}/*
for file in ${files}
do
    echo $last
done

while true; do
    sleep $INTERVAL
    files=${HAML_SRC}/*
    for file in ${files}
    do
        echo $last
    done
    current=`get_time_stamp haml/index.haml`
    if [ $last -lt $current ] ; then
        echo "updated: $current"
        last=$current
        compile_haml "haml/index.haml"
    fi
done
