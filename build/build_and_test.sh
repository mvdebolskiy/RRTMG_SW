#!/bin/bash


#USAGE: build platform kgsrc

platform=$1
kgsrc=$2
version=v5.00
declare -a platforms=("aix_xlf90" "linux_mimi" "linux_pgi" "OS_X_g95" "OS_X_ibm_xl" "sgi" "sun")
if [[ ${platform} == "" ]] ; then
      echo "No platform selected."
      echo "Usage: $0 <platform> <kgsrc_format>"
      exit 1
fi
if ! [[ ${platforms[*]} =~ ${platform} ]] ; then
      echo "$platform is not supported."
      echo "Available platforms are:"
      echo ${platforms[*]}
      exit 1
fi

if  [[ ${kgsrc} == "" ]]; then
      echo "no kgsrc_format selected"
      exit 1
elif ! [[ ${kgsrc} =~ "nc" || ${kgsrc} =~ "dat" ]] ; then
      echo "KGSRC format is not supported."
      echo "Available formats are:"
      echo "nc dat"
      exit 1
fi


if ! [[ -L "./makefile" ]] ; then
      ln -s ./makefiles/make_rrtmg_sw_${platform} ./makefile
fi

if [[ ${platform} == "linux_mimi" ]] ; then
      module purge
      module load netCDF-Fortran/4.6.0-gompi-2022a
fi

make PLATFORM=${platform} KGSRC=${kgsrc}

if [[ -f ./rrtmg_sw_${version}_${platform} ]] ; then

    cd  ../run_examples_std_atm/
    ln -sf ../build/rrtmg_sw_${version}_${platform} rrtmg_sw

    ./script.run_std_atm
    if [[ ${kgsrc} == "nc" ]] ; then
        cp -f ../data/rrtmg_sw.nc ./
    fi
else
    echo "build was not complete"
fi

