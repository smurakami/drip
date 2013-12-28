#!/bin/sh

finally() {
    RET=$?
    echo "return code: $RET"
    if [ $RET -ne 0 ]; then
        # chatch block
        echo "error occured"
    else
        echo "finished with no error"
    fi
    # try block
    kill -9 $coffee_id
    kill -9 $sass_id
    echo "good bye"

    exit $RET
}

setup_coffee(){
    coffee -w -o js/ -c coffee/*.coffee &
    coffee_id=$!
}

setup_sass(){
    sass --watch sass:css &
    sass_id=$!
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


setup_coffee
setup_sass

HAML_SRC=haml
INTERVAL=1 #監視間隔, 秒で指定
last="0"
# 最初に全てコンパイル
files=${HAML_SRC}/*
for file in ${files}
do
    compile_haml $file
    time_stamp=`get_time_stamp $file`
    if test $last -lt $time_stamp ; then
        last=$time_stamp
    fi
done

while true; do
    sleep $INTERVAL
    files=${HAML_SRC}/*
    current_last="0"
    for file in ${files}
    do
        time_stamp=`get_time_stamp $file`
        if test $last -lt $time_stamp ; then
            echo "updated: $file"
            compile_haml $file
            last=$time_stamp
            if test $current_last -lt $time_stamp ; then
                current_last=$time_stamp
            fi
        fi
    done

    if test $last -lt $current_last ; then
        last=$current_last
    fi
done
