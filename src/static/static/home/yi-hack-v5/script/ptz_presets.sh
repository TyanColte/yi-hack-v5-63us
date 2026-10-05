#!/bin/sh

ACTION="none"
NUM=-1
NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--action)
      ACTION="$2"
      shift
      shift
      ;;
    -n|--number)
      NUM="$2"
      shift
      shift
      ;;
    -m|--name)
      NAME="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      shift
      ;;
  esac
done

if [ $ACTION == "get_presets" ] ; then
    echo "0=Home"
elif [ $ACTION == "go_preset" ] ; then
    ipc_cmd -p $NUM
    echo "Movement started in background"
elif [ $ACTION == "set_home_position" ] || [ $ACTION == "add_preset" ]; then
    ipc_cmd -R all
    usleep 500000
    ipc_cmd -P
    echo "Home position saved natively"
else
    echo "Invalid action received"
    exit
fi
