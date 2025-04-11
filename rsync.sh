#!/bin/bash

HOST="192.168.1.145"

rsync -davz . "nixos@${HOST}:/home/nixos/nix-config/"
while inotifywait -r -e modify,create,delete .; do
  rsync -davz . "nixos@${HOST}:/home/nixos/nix-config/"
done
