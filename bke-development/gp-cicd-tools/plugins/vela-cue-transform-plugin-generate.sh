#!/bin/sh

CUE_FILES=$(ls *.cue)
for file in $CUE_FILES; do
   vela def apply "$file" --dry-run -n {{ .Release.Namespace }};
   echo "---"
done;