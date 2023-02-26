#!/bin/bash
packer build --force -on-error=ask -only='packages_install_pm08.virtualbox-ovf.prog-installs' .
