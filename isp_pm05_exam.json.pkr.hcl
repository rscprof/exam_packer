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

variable "win_shutdown_command" {
  type    = string
  default = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
}

variable "win_communicator" {
  type    = string
  default = "winrm"
}

variable "win_vm_name" {
  type    = string
  default = "isp_pm05"
}



#From https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso
source "virtualbox-iso" "windows" {
  vm_name              = "${var.win_vm_name}"
  disk_size            = "${var.disk_size}"
  guest_os_type        = "Windows10_64" #From VBoxManage list ostypes
  guest_additions_mode = "disable"
  iso_checksum         = "${var.iso_checksum}" #Local file for us
  iso_url              = "${var.iso_url}"
  floppy_files = ["${var.autounattend}",
    "./scripts/enable-winrm.ps1",
    "./scripts/chocolatey.bat"
    #                          ,"./scripts/install_pm5.bat", 
    #                          "./scripts/bootstrap.bat"
  ]
  headless         = "true"
  shutdown_command = "${var.win_shutdown_command}"
  cpus             = 2
  memory           = "${var.memory}"
  communicator     = "${var.win_communicator}"
  winrm_username   = "${var.user_name}"
  winrm_password   = "${var.user_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  boot_command     = [""]
  boot_wait        = "6m"
  skip_export      = "false"
  output_directory = "./output_windows_installed"
  output_filename  = "windows_installed"
}

source "virtualbox-ovf" "prog-installs-pm05" {
  vm_name = "windows_installed"
  #  target_snapshot="prog_installed"
  skip_export      = "false"
  shutdown_command = "${var.win_shutdown_command}"
  communicator     = "${var.win_communicator}"
  winrm_username   = "${var.user_name}"
  winrm_password   = "${var.user_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  headless         = "true"
  output_filename  = "programs_installed"
  output_directory = "./output_programs_installed"
  source_path = "./output_windows_installed/windows_installed.ovf"
  guest_additions_mode = "disable"
  http_directory="./downloads"
}

source "virtualbox-ovf" "prog-installs-packages" {
  vm_name = "programs_installed"
  #  attach_snapshot="prog_installed"
  #  target_snapshot="packages_installed"
  skip_export      = "false"
  shutdown_command = "${var.win_shutdown_command}"
  communicator     = "${var.win_communicator}"
  winrm_username   = "${var.user_name}"
  winrm_password   = "${var.user_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  headless         = "${var.headless}"
  output_filename  = "packages_installed"
  source_path = "./output_programs_installed/programs_installed.ovf"
  guest_additions_mode = "disable"
  http_directory="./downloads"
}



build {
  name    = "win_install"
  sources = ["source.virtualbox-iso.windows"]
}

build {
  name = "programs_install"
  #  vm_name="win_install"
  sources = ["source.virtualbox-ovf.prog-installs-pm05"]
  
  provisioner "shell-local" {
    inline = ["wget -N https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe -O ./downloads/laragon-wamp.exe"]
  }

  provisioner "windows-shell" {
    inline = ["powershell -Command \"(New-Object System.Net.WebClient).DownloadFile('http://{{ .HTTPIP }}:{{ .HTTPPort }}/laragon-wamp.exe', 'C:\\Windows\\Temp\\laragon-wamp.exe')\" <NUL",
    "C:\\Windows\\temp\\laragon-wamp.exe /SILENT"
    ]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y vscode"]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y gimp"]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y libreoffice-fresh"]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y postman"]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y pycharm-community"]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y openssl"]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y 7-Zip"]
  }

}

build {
  name = "packages_install"
  #  vm_name="${var.vm_name}"
  sources = ["source.virtualbox-ovf.prog-installs-packages"]


  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\nodejs\\node-v18\\npm install -g express prettier eslint vue@next vue-router@4 react @reduxjs/toolkit react-redux react-router-dom formik react-content-loader"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\python\\python-3.10\\python -m pip install --upgrade pip"]
  }


  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\python\\python-3.10\\python -m pip install flask flask-sqlalchemy jinja2 flask-mysql pyOpenSSL secrets flask-marshmallow flask-login Werkzeug"]
  }

  provisioner "shell-local" {
    inline = ["wget -N https://wordpress.org/latest.tar.gz -O ./downloads/latest.tar.gz"]
  }

  provisioner "windows-shell" {
    inline = ["mkdir c:\\laragon\\tmp\\cached",
    "c:\\laragon\\bin\\git\\mingw64\\bin\\curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/latest.tar.gz --output C:\\laragon\\tmp\\cached\\wordpress.latest.tar.gz"]

  }
  
  provisioner "shell-local" {
    inline = ["wget -N https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip -O ./downloads/bootstrap.zip"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\git\\mingw64\\bin\\curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/bootstrap.zip --output C:\\User\\Student\\Desktop\\bootstrap.zip"]
  }

}

