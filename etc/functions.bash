#!/usr/bin/env bash

#  variable_is_empty VARIABLE
variable_is_empty() {
        if [ "${1}zzz" == "zzz" ] ; then
                true
        else
                false
        fi
}

check_make_directory() {
        if variable_is_empty ${1} ; then
                print_error_and_exit "You must provide a directory name to check_make_directory."
        fi
        if [ -e ${1} ] && [ ! -d ${1} ] ; then
                print_error_and_exit "check_make_directory: Non-directory entity already exists with name ${1}."
        fi
        if [ ! -d ${1} ] ; then
                mkdir -p ${1}
        fi
}

# print_error_and_exit_failure [ ${ERROR} ]
print_error_and_exit() {
        if variable_is_empty ${1} ; then
                echo "There seems to have been a problem. See the output above for details. Exiting..."
        else
                echo "${1}"
        fi
        exit 1
}

does_image_exist() {
        if [ "$( docker images --format {{.Repository}}:{{.Tag}} | grep -c ${1} )" -eq "0" ]; then
                return 1
        fi
        return 0
}
