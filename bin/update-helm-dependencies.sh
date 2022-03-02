#!/bin/sh

PRG=`basename $0`

DIR=$(dirname $0)
HOME=${DIR-.}/..

DO_CLEAN=false
DO_UPDATE=true
EXECUTE=true

#####################################################################
##                              print_usage
#####################################################################
print_usage(){
cat <<EOF 1>&2
usage: $PRG [-hE] 

Options:
    E: Don't execute, only log commands. Dry run.
    u: Update subcharts. Default for build is $DO_UPDATE
    U: Don't update subcharts.
    c: Clean (remove) Chart.lock and charts directory. Default is $DO_CLEAN
    h: This help

Function:
    Updates dependencies for Helm-Charts in $HOME and subdirectories

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
##                              do_update
#####################################################################
do_update(){
  echo helm dependency update $chart
  execute && helm dependency update $chart
}

######################   handle options ###################

while getopts "hEuUc" option
do
    case $option in
      E) EXECUTE=false;;
      u) DO_UPDATE=true;;
      U) DO_UPDATE=false;;
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
    if [ $DO_UPDATE = true ]; then
      do_update
    fi
  fi
done
