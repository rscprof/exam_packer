variable "disk_size" {
  type    = number
  default = 61440
}
variable "iso_checksum" {
  type    = string
  default = "sha256:f85c19a39c09b53d50386679fadcc283ccf31ad4b8d6aacde2e7237e91d59312"
}

variable "iso_url" {
  type    = string
  default = "./image/ru-ru_windows_10_22h2_x64_dvd.iso"
}

variable "memory" {
  type    = string
  default = "4096"
}
variable "autounattend" {
  type    = string
  default = "./Autounattend.xml"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "user_name" {
  type    = string
  default = "Student"
}

variable "user_password" {
  type    = string
  default = "Student"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}




#From https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso
source "virtualbox-iso" "isp-pm05-exam" {
  disk_size            = "${var.disk_size}"
  guest_os_type        = "Windows10_64"  #From VBoxManage list ostypes
  guest_additions_mode = "disable"
  iso_checksum         = "${var.iso_checksum}" #Local file for us
  iso_url              = "${var.iso_url}"
  floppy_files         = ["${var.autounattend}", 
                          "./scripts/enable-winrm.ps1", 
                          "./scripts/chocolatey.bat", 
                          "./scripts/install_pm5.bat", 
                          "./scripts/bootstrap.bat"
                          ]
  headless             = "${var.headless}"
  shutdown_command     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  cpus                 = 2
  memory               = "${var.memory}"
  communicator         = "winrm"
  winrm_username       = "${var.user_name}"
  winrm_password       = "${var.user_password}"
  winrm_timeout        = "${var.winrm_timeout}"
  boot_command         = [""]
  boot_wait            = "6m"
}

build {
  sources = ["source.virtualbox-iso.isp-pm05-exam"]

}
