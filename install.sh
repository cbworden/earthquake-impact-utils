#!/bin/bash

VENV=impact

unamestr=`uname`
if [ "$unamestr" == 'Linux' ]; then
    source ~/.bashrc
elif [ "$unamestr" == 'FreeBSD' ] || [ "$unamestr" == 'Darwin' ]; then
    source ~/.bash_profile
fi

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
conda --version
if [ $? -ne 0 ] ; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        -O miniconda.sh;
    bash miniconda.sh -f -b -p $HOME/miniconda
    # Need this to get conda into path
    . $HOME/miniconda/etc/profile.d/conda.sh
    
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
conda deactivate

# Create a conda virtual environment
echo "Creating the $VENV virtual environment:"
conda env create -f $env_file --force


if [ $? -ne 0 ]; then
    echo "Failed to create conda environment.  Resolve any conflicts, then try again."
    exit
fi

# Activate the new environment
echo "Activating the $VENV virtual environment"
conda activate $VENV

# This package
echo "Installing impact-utils..."
pip install -e .

# Tell the user they have to activate this environment
echo "Type 'conda activate $VENV' to use this new virtual environment."
