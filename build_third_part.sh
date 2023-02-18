#!/bin/bash
packer build --force -on-error=ask -only='packages_install.virtualbox-ovf.prog-installs-packages' .
