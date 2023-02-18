#!/bin/bash
packer build -only='win_install.virtualbox-iso.windows' . 
if [ "$?" -eq 0 ]
then
sh ./build_from_second_part.sh
fi