#!/bin/sh

DIR="none"
TIME="0.8"

for I in 1 2
do
    CONF="$(echo $QUERY_STRING | cut -d'&' -f$I | cut -d'=' -f1)"
    VAL="$(echo $QUERY_STRING | cut -d'&' -f$I | cut -d'=' -f2)"

    if [ "$CONF" == "dir" ] ; then
        DIR="-m $VAL"
    elif [ "$CONF" == "time" ] ; then
        TIME="$VAL"
    fi
done

if [ "$DIR" != "none" ] ; then
    TOKEN=$RANDOM
    echo $TOKEN > /tmp/ptz_token
    
    ipc_cmd $DIR
    
    (
        sleep $TIME
        CURRENT_TOKEN=$(cat /tmp/ptz_token 2>/dev/null)
        if [ "$CURRENT_TOKEN" == "$TOKEN" ]; then
            ipc_cmd -m stop
        fi
    ) &
fi

printf "Content-type: application/json\r\n\r\n"
printf "{\n"
printf "}\n"
