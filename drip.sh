#!/bin/sh

HAML_DIR=haml
SASS_DIR=sass
COFFEE_DIR=coffee
HTML_DIR="."
JS_DIR=js
CSS_DIR=css

if test $1 = init; then
    mkdir $SASS_DIR
    mkdir $COFFEE_DIR
    mkdir $HAML_DIR
    mkdir $JS_DIR
    mkdir $CSS_DIR
    if test $HTML_DIR != "."; then
        mkdir $HTML_DIR
    fi
    exit 0
fi

echo $1

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
    coffee -w -o $JS_DIR/ -c $COFFEE_DIR/*.coffee &
    coffee_id=$!
}

setup_sass(){
    sass --watch $SASS_DIR:$CSS_DIR &
    sass_id=$!
}

compile_haml(){
    {
        haml $1 $HTML_DIR/`echo $1 | sed -e s%$HAML_DIR/%% | sed -e s/.haml/.html/`
    } || {
        echo "haml: error!"
    }
}

get_time_stamp(){
    echo `ls -l -T $1 | awk '{print $6$7$8}' | sed -e s/://g`
}

set -e
trap finally EXIT

# try block


setup_coffee
setup_sass

INTERVAL=1 #監視間隔, 秒で指定
last="0"
# 最初に全てコンパイル
files=${HAML_DIR}/*
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
    files=${HAML_DIR}/*
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
