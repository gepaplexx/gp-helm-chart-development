#!/bin/bash

# set -x 

# DEBUG=true

debug(){
  test X$DEBUG = Xtrue
}

if ! [ -x "$(command -v yq)" ]; then
  debug && echo "Error: please install yq." >&2
  exit 1
fi

 # read the `kind: ResourceList` from stdin
resourceList=$(cat)
items=$(echo "$resourceList" | yq '.items' )
replacements=$(echo "$resourceList" | yq '.functionConfig.spec.replacements' )
DEBUG=$(echo "$resourceList" | yq '.functionConfig.spec.debug' )

debug && echo replacements=\'$replacements\' >&2

for i in `seq 0 $(expr $(echo "$items" | yq ". | length" ) - 1)`; do
    item=$(echo "$items" | yq ".[$i]" )
    debug && echo item=\'$item\' >&2
    for key in $(echo "$replacements" | yq ". | keys" | yq ".[]" ); do
        debug && echo key=\'$key\' >&2
        debug && echo value=\'$(echo "$replacements" | yq ".$key" )\' >&2
        item=$(echo "$item" | sed -e "s/$key/"$(echo "$replacements" | yq ".$key" )"/g")
    done
    echo "$item"
    echo "---"
done
