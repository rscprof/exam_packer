#!/bin/bash
packer build --force -on-error=ask -only='programs_install_pm08.virtualbox-ovf.prog-installs' .
if [ "$?" -eq 0 ] 
then
sh ./build_third_part_pm_08.sh
fi
