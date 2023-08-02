#!/bin/bash

######################### Constants ##########################

RED='\033[0;31m' #RED
NC='\033[0m' # No Color

######################### Parameters ##########################

fips=""
apn=""
license=""

while [ $# -gt 0 ] ; do
  case $1 in
    --fips) 
        if [ -z "$2" ] || [[ $2 == -* ]];
        then
            printf "${RED}Error: Missing an argument for parameter \'fips\'.${NC}\n"  
            exit 1
        fi 

        fips="$2"
        shift
        ;;
    --apn) 
        if [ -z "$2" ] || [[ $2 == -* ]];
        then
            printf "${RED}Error: Missing an argument for parameter \'apn\'.${NC}\n"  
            exit 1
        fi 

        apn="$2"
        shift
        ;;
    --license) 
        if [ -z "$2" ] || [[ $2 == -* ]];
        then
            printf "${RED}Error: Missing an argument for parameter \'license\'.${NC}\n"  
            exit 1
        fi 

        license="$2"
        shift 
        ;;
  esac
  shift
done

# Use the location of the .sh file
# Modify this if you want to use
CurrentPath="$(pwd)"
ProjectPath="$CurrentPath/PropertyDotnet"
BuildPath="$ProjectPath/Build"

if [ ! -d "$BuildPath" ];
then
    mkdir "$BuildPath"
fi

########################## Main ############################
printf "\n======================== Melissa Property Cloud Api ===========================\n"

# Get license (either from parameters or user input)
if [ -z "$license" ];
then
  printf "Please enter your license string: "
  read license
fi

# Check for License from Environment Variables 
if [ -z "$license" ];
then
  license=`echo $MD_LICENSE` 
fi

if [ -z "$license" ];
then
  printf "\nLicense String is invalid!\n"
  exit 1
fi

# Start program
# Build project
printf "\n================================ BUILD PROJECT ================================\n"

dotnet publish -f="net7.0" -c Release -o "$BuildPath" PropertyDotnet/PropertyDotnet.csproj

# Run project
if [ -z "$fips" ] && [ -z "$apn" ];
then
    dotnet "$BuildPath"/PropertyDotnet.dll --license $license 
else
    dotnet "$BuildPath"/PropertyDotnet.dll --license $license --fips "$fips" --apn "$apn"
fi


