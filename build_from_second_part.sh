#!/bin/bash
packer build --force -on-error=ask -only='programs_install.virtualbox-ovf.prog-installs' .
if [ "$?" -eq 0 ] 
then
sh ./build_third_part.sh
fi
