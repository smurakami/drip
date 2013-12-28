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

set -e
trap finally EXIT

# try block

coffee -w -o js/ -c coffee/*.coffee &
coffee_id=$!

sass --watch sass:css &
sass_id=$!

echo "監視対象 haml/index.haml"
echo "実行コマンド  haml haml/index.haml"
INTERVAL=1 #監視間隔, 秒で指定
last=`ls -l -T haml/index.haml | awk '{print $6"-"$7"-"$8}'`
while true; do
    sleep $INTERVAL
    current=`ls -l -T haml/index.haml | awk '{print $6"-"$7"-"$8}'`
    if [ $last != $current ] ; then
        echo "updated: $current"
        last=$current
        eval haml haml/index.haml index.html
    fi
done
