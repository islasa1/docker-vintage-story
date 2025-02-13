#!/usr/bin/sh

help()
{
  echo "./start_container.sh [options]"
  echo "  -d [path]           Path to place the server"
  echo "  -m [mod dir]        Load mods from this directory"
  echo "  -c [config]         Load from user server config"
  echo "  -p [port]           default 42420        Port to forward, MAKE SURE THIS MATCHES YOUR CONFIG IF PROVIDED"
  echo "  -n [name]           default vintagestory Name of container to run"
  echo "  -h                  Print this message"
  echo "-- <docker commands>  Directly pass everything after this to the docker command"
  echo ""
  echo "THIS SCRIPT USES SUDO!"
}
port=42420
name=vintagestory
while getopts "hd:c:m:p:n:" opt; do
  case ${opt} in
    d)
      serverDir=$OPTARG
    ;;
    c)
      config=$OPTARG
    ;;
    m)
      modDir=$OPTARG
    ;;
    p)
      port=$OPTARG
    ;;
    n)
      container=$OPTARG
    ;;
    h)  help; exit 0 ;;
    *)  help; exit 1 ;;
    :)  help; exit 1 ;;
    \?) help; exit 1 ;;
  esac
done
shift "$((OPTIND - 1))"
if [ -z $serverDir ]; then
  echo "Server directory required!"
fi

extraOps=
if [ ! -z $config ]; then
  extraOps="$extraOps --volume ${config}:/opt/config/serverconfig_custom.json --env 'CONFIG=/opt/config/serverconfig_custom.json'"
fi
if [ ! -z $modDir ]; then
  extraOps="$extraOps --volume ${modDir}:/opt/mods/"
fi

sudo docker run --name $container -d -p $port:$port --volume $serverDir:/vintagestory ${extraOps} $*
