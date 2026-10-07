#!/bin/bash

# Builds and runs the Melissa Property Cloud API .NET sample.
#
# This script builds PropertyDotnet with dotnet publish, then runs the resulting
# executable, passing along the license and (if supplied) the FIPS code and APN.
#
# Overall flow:
#   1. Parse the command-line options below.
#   2. Resolve the license (--license, then a prompt, then the MD_LICENSE environment variable).
#   3. Publish PropertyDotnet in Release configuration to ./PropertyDotnet/Build.
#   4. Run the built executable: one-shot mode if --fips or --apn was supplied,
#      otherwise interactive mode (the .NET program prompts for each field).
#
# Options (each takes a value):
#   --fips      FIPS (county) code of the property.
#   --apn       Assessor's Parcel Number of the property.
#   --license   License string. If omitted, the script prompts for it; if the prompt
#               is left blank, it falls back to MD_LICENSE. Running without --license
#               always prompts, even when MD_LICENSE is set.
#
# Paths are relative to the current directory, so run the script from its own folder.
#
# Examples:
#   ./PropertyDotnet.sh --license "your-license"
#   ./PropertyDotnet.sh --fips "06059" --apn "80505208" --license "your-license"

######################### Constants ##########################

RED='\033[0;31m' #RED
NC='\033[0m' # No Color

######################### Parameters ##########################

fips=""
apn=""
license=""

# Read each --flag and its value. A flag with no value, or whose value starts with "-"
# (such as another option), is an error. Unrecognized options are ignored.
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

# Build paths are relative to the current directory (not the script's location)
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
# Neither fips nor apn supplied -> run interactively; otherwise pass both through for one-shot mode.
# Bash passes empty quoted values as real empty arguments, so unsupplied fields arrive
# empty and the program prompts for them.
if [ -z "$fips" ] && [ -z "$apn" ];
then
    dotnet "$BuildPath"/PropertyDotnet.dll --license "$license"
else
    dotnet "$BuildPath"/PropertyDotnet.dll --license "$license" --fips "$fips" --apn "$apn"
fi


