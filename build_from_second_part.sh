#!/bin/bash
packer build -on-error=ask -only='programs_install.virtualbox-ovf.prog-installs-pm05' .
if [ "$?" -eq 0 ] 
then
sh ./build_third_part.sh
fi
