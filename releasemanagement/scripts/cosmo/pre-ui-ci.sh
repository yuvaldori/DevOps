#!/bin/bash -x

source generic_functions.sh
source params.sh
pre_git_pull cosmo-ui https://opencm:${GIT_PWD}@github.com/CloudifySource/cosmo-ui.git
