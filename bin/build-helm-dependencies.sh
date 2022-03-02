#!/bin/sh

PRG=`basename $0`

DIR=$(dirname $0)
HOME=${DIR-.}/..

DO_CLEAN=false
DO_BUILD=true
EXECUTE=true

#####################################################################
##                              print_usage
#####################################################################
print_usage(){
cat <<EOF 1>&2
usage: $PRG [-hE] 

Options:
    E: Don't execute, only log commands. Dry run.
    b: Build subcharts. Default for build is $DO_BUILD
    B: Don't build subcharts.
    c: Clean (remove) Chart.lock and charts directory. Default is $DO_CLEAN
    h: This help

Function:
    Builds dependencies for Helm-Charts in $HOME and subdirectories

EOF
}

#####################################################################
##                              execute
#####################################################################
execute(){
  test $EXECUTE = true
}

#####################################################################
##                              do_clean
#####################################################################
do_clean(){
  echo rm $chart/Chart.lock
  execute && rm $chart/Chart.lock
  echo rm -r $chart/charts
  execute && rm -r $chart/charts
}

#####################################################################
##                              do_build
#####################################################################
do_build(){
  echo helm dependency build $chart
  execute && helm dependency build $chart
}

######################   handle options ###################

while getopts "hEbBc" option
do
    case $option in
      E) EXECUTE=false;;
      b) DO_BUILD=true;;
      B) DO_BUILD=false;;
      c) DO_CLEAN=true;;
      *)
        print_usage
        exit 1
        ;;
    esac
done

shift `expr $OPTIND - 1`

######################   MAIN ####################

for f in $(find $HOME -name Chart.yaml); do
  if grep -q 'dependencies:' $f; then
    chart=$(dirname $f)
    if [ $DO_CLEAN = true ]; then
      do_clean
    fi
    if [ $DO_BUILD = true ]; then
      do_build
    fi
  fi
done
