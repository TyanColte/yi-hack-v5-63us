#!/bin/sh

YI_HACK_PREFIX="/tmp/sd/yi-hack-v5"
PTZ_SCRIPT=$YI_HACK_PREFIX/script/ptz_presets.sh

ACTION="none"
NUM=-1
NAME=""

for I in 1 2 3 4
do
    CONF="$(echo $QUERY_STRING | cut -d'&' -f$I | cut -d'=' -f1)"
    VAL="$(echo $QUERY_STRING | cut -d'&' -f$I | cut -d'=' -f2)"

    if [ "$CONF" == "action" ] ; then
        ACTION="$VAL"
    elif [ "$CONF" == "num" ] ; then
        NUM="$VAL"
    elif [ "$CONF" == "name" ] ; then
        NAME="$VAL"
    fi
done

if [ "$NUM" == "-1" ] && [ -n "$NAME" ]; then
    # Map common named presets (like Frigate return_preset: Home)
    case $(echo "$NAME" | tr '[:upper:]' '[:lower:]') in
        "home") NUM=0 ;;
        "bed"|"dogbed") NUM=1 ;;
        "door") NUM=2 ;;
        *) NUM=0 ;;
    esac
fi

if [ "$NUM" != "-1" ]; then
    NUM="-n $NUM"
else
    NUM=""
fi

# Call our custom script
if [ "$ACTION" == "go_preset" ]; then
    killall ptz_presets.sh 2>/dev/null
    $PTZ_SCRIPT -a $ACTION $NUM > /dev/null 2>&1 &
    RES="Movement started in background"
else
    RES=$($PTZ_SCRIPT -a $ACTION $NUM)
fi

# Output success JSON for Home Assistant / Frigate
printf "Content-type: application/json\r\n\r\n"
printf "{\n"
printf "\"%s\":\"%s\",\n" "error" "false"
printf "\"%s\":\"%s\"\n" "output" "$RES"
printf "}\n"
