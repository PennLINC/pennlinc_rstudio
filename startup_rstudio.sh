
DEBUG=true
INPUTIMAGE=$1
PORT=$2
CURRENTIMAGE=docker://rocker/tidyverse:3.6.1



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
  
  singularity pull $CURRENTIMAGE

"
  exit 1
fi

## start the instance
export SINGULARITYENV_USER=$USER
read -s -p "Enter a password to use with your RStudio instance: " rstudio_pw
export SINGULARITYENV_PASSWORD=$rstudio_pw
echo

#debug
if [ "$DEBUG" = true ] ; then
    echo
    echo Username: $SINGULARITYENV_USER
    echo Password: $SINGULARITYENV_PASSWORD
    echo
fi

# ready to run

# this command starts an rserver in the background
singularity instance start -e -B $TMPDIR:/var -B $HOME:/root $INPUTIMAGE rstudio-singularity
    
    # binds are set to temp dir
    # and the home dir of the user by default

    # to add more, just add:
    # -B path/local:path/in/container


# now, launch rstudio
