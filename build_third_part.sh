#!/bin/bash
packer build -only='packages_install.virtualbox-ovf.prog-installs-packages' .
