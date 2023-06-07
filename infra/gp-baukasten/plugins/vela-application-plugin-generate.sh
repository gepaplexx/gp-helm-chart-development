#!/bin/sh

while IFS= read -r line || [[ -n "$line" ]]
do
  vela dry-run -f "$line"
done < .baukasten