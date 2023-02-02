#! usr/bin/bash
ABIS=(
  # Add greps to export here 
  *Component
  *System
  # World     # do we need this?
  # LibQuery  # Q(jb): Where do we find this??
)

EXCLUDE=(
  # Add files not to export here 
  Component   # only include this if *Component is uncommented above 
  IComponent  # only include this if *Component is uncommented above 
  System      # only include this if *System is uncommented above 
  ISystem     # only include this if *System is uncommented above 
)

for file in ${ABIS[@]}; do
  cp out/$file.sol/*.json ../client/abi/;
done

for file in ${EXCLUDE[@]}; do
  if [ -f abi/$file.json ]; then
    rm abi/$file.json;
  fi
done