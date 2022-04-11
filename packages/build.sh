#!/bin/bash
##
# Compile xtee-misp2-* debian packages and add them to repo.
# 
# Script has to be run by a normal user (e.g. misp2) while being inside the packages directory.
# 
# Examples:
#
### Before running the script, change directory to 'misp2-web-app/packages' and make the script executable
#
# cd ~/git/misp2-web-app/packages
# chmod u+x build.sh
#
### To build all the xtee-misp2 packages and add them to /repo directory, 
### run build.sh without arguments.
#
# ./build.sh
#
### To build selected packages, add respective package suffixes (E.g. postgresql, base, orbeon, application)
### as command line arguments. The following example only builds xtee-misp2-application package.
#
# ./build.sh application
#
### To build packages for specific Ubuntu distro, add distro codename as argument (E.g xenial or bionic).
#
# ./build.sh xenial
#
## During the build, relevant packages are added to /repo.
## To clean project directory from intermediary generated package files, run
#
# ./build.sh -clean
#
## To build without pulling changes from Git (-nogit)
## and without (re)building webapps (-nobuild)
## and without signing debian packages (-nosign), run:
#
# ./build.sh -nosign -nogit -nobuild
#
## To pull updates and build webapps, but not create debian packages, run:
#
# ./build.sh -nodebian
#
##

# Fail on error
set -e

# Do not allow to run as root
if [ "$EUID" == "0" ]
then
  echo "This build script should not be run as root, otherwise various issues will occur."
  echo "For instance, updated files will have root as owner."
  exit 1
fi

# Change working directory to the location of currently run script
cd "$(dirname "$0")"

# Import functions
. resources/functions-build.sh

# Variable declarations
git_branch_misp2_webapp=master

prefix=xtee-misp2
repo_name="repo"
distros=$(get_distros "$*")
packages=$(get_packages "$*" "$prefix")
default_distro="bionic"

if (gpg --list-secret-keys | grep -q sec) && ! contains_word "$*" "-nosign" 
then
	echo "Packages are going to be signed."
	add_to_repo=true
else
	echo "Packages are NOT going to be signed."
	add_to_repo=false

fi

if contains_word "$packages" "$prefix-application" && ! contains_word "$*" "-nobuild"
then
	build_webapp=true
fi

if contains_word "$packages" "$prefix-orbeon" && ! contains_word "$*" "-nobuild"
then
	build_orbeon=true
fi

if contains_word "$*" "-clean"
then
	echo "Clean up build directory and restore package sources to default state."
	# Clean up of previously generated packages (*.deb files only)
	clean_up "$prefix"
	# Restore default state of repository source
	adjust_to_distro "$default_distro" "$repo_name" "$prefix" "$packages" "$add_to_repo"
	exit 0
fi

if ! contains_word "$*" "-nogit"
then
	# Cache Git credentials for 60 s to avoid inserting them multiple times
	git config --global credential.helper 'cache --timeout=60'
	# Update project
  cd ../
	git pull origin "$git_branch_misp2_webapp"
  cd packages
fi

if [ "$build_webapp" == true ] || [ "$build_orbeon" == true ]
then
  cd ../ # To the root of the project

  echo "$(pwd): Running cleanup for MISP2"
  ./gradlew clean
    
  # Build webapp WAR-s and copy them to Debian package build directories
  if [ "$build_webapp" == true ]
  then
    # Build webapp
    echo "$(pwd): Building MISP2 webapp"
    ./gradlew :web-app:war
    # Copy webapp to 'war' directory in xtee-misp2-application project
    cp web-app/build/libs/misp2.war packages/$prefix-application/war/misp2.war

  fi

  # If application package is being built, check WAR version
  if contains_word "$packages" "$prefix-application" 
  then
    cd packages/$prefix-application/war

    # Check WAR version if it matches application package version
    echo "$(pwd): Checking MISP webapp version"
    check_war_version misp2.war $prefix-application "$*"

    cd ../../.. # Back to the root
  fi

  if [ "$build_orbeon" == true ]
  then
    # Build Orbeon webapp WAR
    echo "$(pwd) Building Orbeon webapp"
    ./gradlew :orbeon-war:war
    # Copy webapp WAR file to 'war' directory in xtee-misp2-orbeon project
    cp orbeon-war/build/dist/orbeon.war packages/$prefix-orbeon/war/orbeon.war
  fi

  cd packages # Back to packages
fi


# Optional exit when '-nodebian' argument is given; in order to avoid time-consuming debian package build process
if contains_word "$*" "-nodebian"
then
	echo "Exiting before package building (command line argument '-nodebian' received)."
	exit 0
fi


# Loop through all Ubuntu distributions that packages are created for
for distro_codename in $distros 
do
	# Perform modifications in package source for specific target distribution
	adjust_to_distro "$distro_codename" "$repo_name" "$prefix" "$packages" "$add_to_repo"

	if [ "$add_to_repo" == "true" ]
	then
		# Clean up of previously generated packages (*.deb files only)
		clean_up "$prefix"
	fi
	# Compile user-specified packages to *.deb files
	compile_packages "$packages" "$add_to_repo" "$distro_codename"
	# Package compilation done

	if [ "$add_to_repo" == "true" ]
	then
		echo "Adding packages to $repo_name.."

		# Copy packages to repo and build repo
		cd "$repo_name"
		# To remove old packages from repo, comment in the following line:
		#rm dists/*/main/binary-amd64/$prefix-* || true
		chmod u+x make-ee-repo.sh
		./make-ee-repo.sh
		cd ..
	else
		echo "Skipping adding packages to repo because of the '-nosign' argument"
	fi

	# Display build summary for built distribution
	build_summary=$(display_build_summary "$distro_codename" "$compiled_packages" "$repo_name" "$add_to_repo")
	echo $build_summary
	summary="$summary\n$build_summary"
done

# Delete temporary build files in current directory
clean_up "$prefix"
# Recover source to initial state
adjust_to_distro "$default_distro" "$repo_name" "$prefix" "$packages" "$add_to_repo"

# Show summary (all distributions)
if [ "$add_to_repo" == "true" ]
then
	echo -e "\nSummary:$summary"
else
	echo -e "\nSummary:\nNB! Repo not signed. Added packages to different directory: '$target_repo_dir'.$summary"
fi

