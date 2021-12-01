#!/bin/bash

DEBUG=true
INPUTIMAGE=$1
PORT=$2
CURRENTIMAGE=shub://nickjer/singularity-rstudio


if [ $# -eq 0 ]
    then
      echo "No arguments supplied -- please pass your SINGULARITY IMAGE and PORT NUMBER as arguments"
      exit 1
fi

echo "Arguments received: $*"

## check the singularity image is valid

read -r -d '' VAR << EOM
if ! command -v rserver &> /dev/null
then
    echo -e "\nrserver could not be found!"
    exit 1
fi
EOM

singularity exec $INPUTIMAGE bash -c "$VAR"

if [ ! $? -eq 0 ]; then

  printf "\nERROR:  This doesn't seem to be a singularity image with rserver installed!
Please download the current recommended singularity image with:
  
  singularity pull --name singularity-rstudio.simg $CURRENTIMAGE

"
  exit 1
fi

## check for the rstudio-cookie
echo Checking for security cookie...

if [ ! -f $HOME/tmp/rstudio-server/secure-cookie-key ]; then
    echo "Cookie not found! Generating a new cookie in $HOME/tmp/rstudio-server"

    mkdir -p $HOME/tmp/rstudio-server
    uuidgen > $HOME/tmp/rstudio-server/secure-cookie-key
    chmod 600 $HOME/tmp/rstudio-server/secure-cookie-key
fi

if [ ! -d $HOME/tmp/var ]; then
    mkdir -p $HOME/tmp/var/{lib,run}
fi

## start the instance

## this command starts an rserver in the background
singularity instance start $INPUTIMAGE rstudio-singularity
    
    # binds are set to temp dir
    # and the home dir of the user by default

    # to add more, just add:
    # -B path/local:path/in/container


if [ $? -eq 255 ]; then

  printf "\nWARNING: Instance is probably already running! Check with:
  
  singularity instance --all

You can probably still access rstudio  
"
  #exit 1
fi

## now, launch rstudio service
singularity run \
  -B $HOME/tmp/var/lib:/var/lib/rstudio-server \
  -B $HOME/tmp/var/run/:/var/run/rstudio-server \
  -B $HOME/tmp:/tmp \
  --app rserver $INPUTIMAGE --www-port=$PORT &
    # binds are set to temp dir
    # and the home dir of the user by default

    # to add more, just add:
    # -B path/local:path/in/container

if [ $? -eq 0 ]; then

  echo "RStudio set up successfully; please visit localhost:$PORT in your browser."
  echo "If RStudio is not available, ensure you logged into the cluster with the correct port bindings:"
  echo
  echo "    ssh -L localhost:<PORTNUMBER>:localhost:<PORTNUMBER> myusername@cluster"
  echo
  echo "To kill your RStudio session, simply do:"
  echo
  echo "    singularity instance stop rstudio-singularity"
  #exit 1
fi

