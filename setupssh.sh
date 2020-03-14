#!/bin/bash
# Script to setup ssh keys for use with gamesgit!
# set -x

# Only add to known hosts if not already added
ssh-keygen -F gamesgit.falmouth.ac.uk
result="$?"
if [ "$result" -ne 0 ]; then
  ssh-keyscan gamesgit.falmouth.ac.uk >> ~/.ssh/known_hosts
fi

# Generate ssh key if not found
if [ ! -f ~/.ssh/gamesgit ]; then
  # gamesgit gamesgit.pub
  ssh-keygen -f ~/.ssh/gamesgit -t rsa -N ''
fi

# If not in .ssh/config - add
grep 'Host gamesgit.falmouth.ac.uk' ~/.ssh/config
result="$?"
if [ "$result" -ne 0 ]; then
  echo "Host gamesgit.falmouth.ac.uk
  IdentityFile ~/.ssh/gamesgit
  User $1@falmouth.ac.uk" >> ~/.ssh/config
fi

# Return public SSH key for python script
pub="$(cat ~/.ssh/gamesgit.pub)"
echo "$pub"