#!/bin/bash
while inotifywait -r -e modify,create,delete .; do
  rsync -davz . nixos@192.168.122.169:/home/nixos/nix-config/
done
