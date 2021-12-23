# pennlinc_rstudio

Use this script to set up and run a simple RStudio instance on the cluser. 

Usage:

0. Log in to the cluster with a port forwarding number. This number must be unique and not shared with anyone (especially important if there are multiple users on a project user).

```shell
ssh -L localhost:<PORTNUMBER>:localhost:<PORTNUMBER> username@clusterip
```

If you're on PMACS, please make sure to log in *twice*; once onto `sciget` (as above), and then once more onto the singularity enabled node:

```shell
ssh -L localhost:<PORTNUMBER>:localhost:<PORTNUMBER> singularity01
```

1. Get a compatible singularity image with `rserver` installed

```shell
singularity pull --name singularity-rstudio.simg shub://nickjer/singularity-rstudio
```

2. Clone this repository in an appropriate location in your project

```shell
git clone https://github.com/PennLINC/pennlinc_rstudio.git
```

3. Run the script with your image and port number as input

```shell
./startup_rstudio.sh <PATH/TO/SINGULARITY/IMAGE.simg> <PORTNUMBER> 
```

4. Visit this address in a web browser:

```
localhost:<PORTNUMBER>
```

By default, it uses the `rocker:tidyverse` base image (we will install neuroimaging packages in future).

Side effects:

- The script will create an authorisation key with `uuid` in the user's `$HOME/tmp` directory if it does not exist; this also applies to the project user on CUBIC
- The Singularity instance will remain running unless explicitly stopped with `singularity instance stop`
- R package installations are made to the user's local R location unless explicitly changed.
- Be aware of login nodes on CUBIC -- if you start an RStudio instance with port X on login node 1, and are unexpectedly disconnected from the cluster, that port may be blocked until you can stop the instance on login node 1
