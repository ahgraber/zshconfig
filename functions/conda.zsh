#!/usr/bin/env zsh

conda_env_create () {

  show_help () {
    cat << EOF
usage: conda_env_create [-h] [-n ENVIRONMENT] [-f FILE | package1, package2, ...]

Create an environment based on an environment file or list of packages

Options:
required arguments:
  -n ENVIRONMENT, --name ENVIRONMENT
                        Name of environment.

positional arguments:
  packages to install

optional arguments:
  -h, --help            Show this help message and exit.
  -f FILE, --file FILE  environment definition file (default: environment.yml)
EOF
  }

  ### ref: http://mywiki.wooledge.org/BashFAQ/035
  # Initialize all the option variables.
  # This ensures we are not contaminated by variables from the environment.
  env_name=
  file=
  package_list=()

  # parse options
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|-\?|--help)
          # Display a usage synopsis.
          show_help
          return
          ;;
      -n|--name)
          # Require option argument has been specified.
          if [ "$2" ]; then
              env_name=$2
              shift
          else
              echo 'ERROR: "--name" requires a non-empty option argument.'
              return 1
          fi
          ;;
      --name=?*)
          # Delete everything up to & including "=" and assign the remainder.
          env_name=${1#*=}
          ;;
      --name=)
          # Handle the case of an empty --name=
          echo 'ERROR: "--name" requires a non-empty option argument.'
          return 1
          ;;
      -f|--file)
          # Require option argument has been specified.
          if [ "$2" ]; then
              file=$2
              shift
          else
              echo 'ERROR: "--file" requires a non-empty option argument.'
              return 1
          fi
          ;;
      --file=?*)
          # Delete everything up to & including "=" and assign the remainder.
          file=${1#*=}
          ;;
      --file=)
          # Handle the case of an empty --file=
          echo 'ERROR: "--file" requires a non-empty option argument.'
          return 1
          ;;
      -?*)
          # Detect dash and warn of unknown option
          echo 'WARN: Unknown option (ignored): %s\n' "$1"
          ;;
      *)
          # Default case: No more options detected, any thing else are packages
          package_list+=("$1")
    esac

    shift
  done

  # echo "env_name: $env_name"
  # echo "file: $file"
  # echo "package_list: $package_list"
  # unset env_name
  # unset file
  # unset package_list

  # check architecture
  if [[ "$(uname -p)" = "i386" ]]; then
    echo "Running x86/Rosetta install"
    conda_arch="osx-64"

    # ensure env starts with "x86"
    if [[ ! "$env_name" =~ "^x86_" ]]; then
      env_name="x86_$env_name"
      echo "--- NOTE: Prepending 'x86_' to environment name ---"
    fi
  fi

  echo "Creating new conda env: '$env_name' ..."
  # [[ -z $file ]] || echo "from file $file "
  # [[ -z $package_list ]] || echo "with specified packages: $package_list"

  # run conda commands for setup
  if [[ "$(uname -p)" = "i386" ]]; then
    CONDA_SUBDIR="$conda_arch" conda create --name "$env_name" --quiet --yes && conda activate "$env_name"
    conda env config vars set CONDA_SUBDIR="$conda_arch" --name "$env_name"
    unset conda_arch
  else
    conda create --name "$env_name" --quiet --yes
  fi

  conda deactivate && conda activate "$env_name"  # not technically needed, but can prevent env overwrites
  conda config --prepend channels conda-forge

  # update env using specified packages
  if [[ ${#package_list[@]} -gt 0 ]]; then
    echo "... with specified packages: $package_list"
    mamba install --force-reinstall --name "$env_name" "${package_list[@]}" --quiet --yes
  fi

  # update env using file
  if [[ ! -z $file ]]; then
    if [[ ! -f $file ]]; then
      echo "ERROR: $file not found."
      return 1
    else
      echo "... from file $file "
      mamba env update --name "$env_name" --file "$file" --quiet
    fi
  fi

  # conda config --prepend channels conda-forge > /dev/null 2>&1
  echo "Environment ${env_name} created for $(conda config --env --show | grep 'subdir:') architecture"
  unset env_name
  unset file
  unset package_list

  # return
}
