#!/bin/bash

VENV=impact

# Is the reset flag set?
reset=0
while getopts r FLAG; do
  case $FLAG in
    r)
        reset=1
        
      ;;
  esac
done


# Is conda installed?
conda=$(which conda)
if [ ! "$conda" ] ; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        -O miniconda.sh;
    bash miniconda.sh -f -b -p $HOME/miniconda
    export PATH="$HOME/miniconda/bin:$PATH"
fi

# Choose OS-specific environment file, which specifies
# exact versions of all dependencies.
unamestr=`uname`
if [ "$unamestr" == 'Linux' ]; then
    env_file=environment_linux.yml
elif [ "$unamestr" == 'FreeBSD' ] || [ "$unamestr" == 'Darwin' ]; then
    env_file=environment_osx.yml
fi

# If the user has specified the -r (reset) flag, then create an
# environment based on only the named dependencies, without
# any versions of packages specified.
if [ $reset == 1 ]; then
    echo "Ignoring platform, letting conda sort out dependencies..."
    env_file=environment.yml
fi

echo "Environment file: $env_file"

# Turn off whatever other virtual environment user might be in
source deactivate

# Create a conda virtual environment
echo "Creating the $VENV virtual environment:"
conda env create -f $env_file --force


if [ $? -ne 0 ]; then
    echo "Failed to create conda environment.  Resolve any conflicts, then try again."
    exit
fi

# Activate the new environment
echo "Activating the $VENV virtual environment"
source activate $VENV

# Install OpenQuake -- note that I have pulled this out of environment.yml
# because the requirements are too narrow to work with our other dependencies,
# but the openquake.hazardlib tests pass with this environment. We need to
# remember to check this when we change the environemnt.yml file though.
conda install -y --no-deps -c conda-forge openquake.engine

# This package
echo "Installing impact-utils..."
pip install -e .

# Tell the user they have to activate this environment
echo "Type 'source activate $VENV' to use this new virtual environment."
