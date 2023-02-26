#!/bin/bash
rm -f downloads/laragon*
packer build --force -on-error=ask -only='win_install.virtualbox-iso.windows' . 
if [ "$?" -eq 0 ]
then
sh ./build_from_second_part_pm_08.sh
fi