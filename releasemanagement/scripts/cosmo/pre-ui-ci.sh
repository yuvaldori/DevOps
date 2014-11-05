#!/bin/bash -x

source generic_functions.sh
source params.sh
pre_git_pull xap https://opencm:${GIT_PWD}@github.com/CloudifySource/cosmo-ui.git
