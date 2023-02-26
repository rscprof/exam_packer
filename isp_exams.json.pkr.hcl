variable "deploy_to_pm_08" {
  type    = string
  default = null
}

variable "deploy_to_pm_05" {
  type    = string
  default = null
}

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
  disk_size            = "${var.disk_size}"
  guest_os_type        = "Windows10_64" #From VBoxManage list ostypes
#  guest_additions_mode = "enable"
  headless         = "true"
  shutdown_command = "${var.win_shutdown_command}"
  shutdown_timeout     = "50m"
  cpus             = 2
  memory           = "${var.memory}"
  communicator     = "${var.win_communicator}"
  winrm_username   = "${var.user_name}"
  winrm_password   = "${var.user_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  boot_command     = [""]
  boot_wait        = "6m"
  skip_export      = "false"

  vm_name              = "${var.win_vm_name}"
  iso_checksum         = "${var.iso_checksum}" #Local file for us
  iso_url              = "${var.iso_url}"
  floppy_files = ["${var.autounattend}",
    "./scripts/enable-winrm.ps1",
    "./scripts/chocolatey.bat"
  ]
  output_directory = "./output_windows_installed"
  output_filename  = "windows_installed"
}

source "virtualbox-ovf" "prog-installs" {
  skip_export          = "false"
  shutdown_command     = "${var.win_shutdown_command}"
  shutdown_timeout     = "50m"
  communicator         = "${var.win_communicator}"
  winrm_username       = "${var.user_name}"
  winrm_password       = "${var.user_password}"
  winrm_timeout        = "${var.winrm_timeout}"
  headless             = "true"
  guest_additions_mode = "disable"
  http_directory       = "./downloads"
}

build {
  name    = "win_install"
  sources = ["source.virtualbox-iso.windows"]
}

build {
  name = "programs_install"
  #  vm_name="win_install"
  source "source.virtualbox-ovf.prog-installs" {

    vm_name = "windows_installed"
    output_filename      = "programs_installed"
    output_directory     = "./output_programs_installed"
    source_path          = "./output_windows_installed/windows_installed.ovf"

  }

  provisioner "shell-local" {
    inline = ["if [ ! -f \"./downloads/laragon-wamp.exe\" ] ; then wget -nc https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe -O ./downloads/laragon-wamp.exe ; fi "]
  }

  provisioner "powershell" {
    #    debug_mode=1
    inline = ["(New-Object System.Net.WebClient).DownloadFile(\"http://\"+($ENV:PACKER_HTTP_ADDR)+\"/laragon-wamp.exe\", 'C:\\Windows\\Temp\\laragon-wamp.exe')"]
  }

  provisioner "windows-shell" {
    inline = ["C:\\Windows\\temp\\laragon-wamp.exe /SILENT"]
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
    inline = ["choco install /y 7zip"]
  }
  
  #Addition installs from PM.08 for non-laragon nodejs and python
  provisioner "windows-shell" {
    inline = ["choco install /y yarn"]
  }
  
  provisioner "windows-shell" {
    inline = ["choco install /y git"]
  }
  
  provisioner "windows-shell" {
    inline = ["choco install /y nodejs-lts"]
  }
  
  provisioner "windows-shell" {
    inline = ["choco install /y curl"]
  }
  
  provisioner "windows-shell" {
    inline = ["choco install /y python"]
  }

}

build {
  name = "packages_install"
  source "source.virtualbox-ovf.prog-installs" {

    vm_name = "programs_installed"
    vboxmanage_post = [
      ["modifyvm", "{{.Name}}", "--nic1", "none"]
    ]
    output_filename      = "packages_installed"
    source_path          = "./output_programs_installed/programs_installed.ovf"
    output_directory     = "./output-prog-installs-packages"
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\nodejs\\node-v18\\npm install -g npm@latest"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\nodejs\\node-v18\\npm update -g"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\nodejs\\node-v18\\npm uninstall -g sourcemap-codec"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\nodejs\\node-v18\\npm install -g @jridgewell/sourcemap-codec"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\nodejs\\node-v18\\npm install -g express prettier eslint vue@next vue-router@4 react @reduxjs/toolkit react-redux react-router-dom formik react-content-loader mysql cors"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\python\\python-3.10\\python -m pip install --upgrade pip"]
  }


  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\python\\python-3.10\\python -m pip install flask flask-sqlalchemy jinja2 flask-mysql pyOpenSSL"]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\python\\python-3.10\\python -m pip install python-secrets flask-marshmallow flask-login Werkzeug"]
  }

  provisioner "shell-local" {
    inline = ["if [ ! -f \"./downloads/latest.tar.gz\" ] ; then wget -nc https://wordpress.org/latest.tar.gz -O ./downloads/latest.tar.gz ; fi "]
  }

  provisioner "windows-shell" {
    inline = ["mkdir c:\\laragon\\tmp\\cached",
    "c:\\laragon\\bin\\git\\mingw64\\bin\\curl http://%PACKER_HTTP_ADDR%/latest.tar.gz --output C:\\laragon\\tmp\\cached\\wordpress.latest.tar.gz"]

  }

  provisioner "shell-local" {
    inline = ["if [ ! -f \"./downloads/bootstrap.zip\" ] ; then wget -nc https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip -O ./downloads/bootstrap.zip ; fi "]
  }

  provisioner "windows-shell" {
    inline = ["c:\\laragon\\bin\\git\\mingw64\\bin\\curl http://%PACKER_HTTP_ADDR%/bootstrap.zip --output C:\\Users\\Student\\Desktop\\bootstrap.zip"]

  }

  
  #Addition installs from PM.08 for non-laragon nodejs and python
 provisioner "windows-shell" {
    inline = ["yarn global upgrade"]
 }

  provisioner "windows-shell" {
    inline = ["yarn global add typescript"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add @vue/cli"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add create-react"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add create-vue"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add @angular/cli"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add prettier eslint"]
  }

  #Create simple react application
  provisioner "windows-shell" {
    inline = ["cd c:\\users\\student\\desktop",
    "yarn create react-app react-student-app",
    "cd react-student-app",
    "yarn add  @reduxjs/toolkit react-redux react-dom react-router-dom formik react-content-loader rxjs zone.js"    
    ]
  }
  
  #Create simple vue application
  provisioner "windows-shell" {
    inline = ["cd c:\\users\\student\\desktop",
    "yarn create vue vue-student-app --ts --jsx --router --pinia --eslint-with-prettier  --force",
    "cd vue-student-app",
    "yarn add vue-router"
    ]
  }
  
  #Create simple angular application
  provisioner "windows-shell" {
    inline = ["cd c:\\users\\student\\desktop",
#    "ng set --global packageManager=yarn",
    "ng new --defaults angular-student-app"
    ]
  }
  
  provisioner "windows-shell" {
    inline = ["python -m pip install --upgrade pip"]
  }


  provisioner "windows-shell" {
    inline = ["python -m pip install flask flask-sqlalchemy jinja2 flask-mysql pyOpenSSL"]
  }

  provisioner "windows-shell" {
    inline = ["python -m pip install python-secrets flask-marshmallow flask-login Werkzeug"]
  }
  
  provisioner "windows-shell" {
    inline = ["cd c:\\users\\student\\desktop",
    "mkdir nodejs-app",
    "cd nodejs-app",
    "yarn init -yp",
    "yarn add express prettier eslint mysql cors"
    ]
  }

  post-processor "shell-local" { 
      inline = [ "rclone copy -P output-prog-installs-packages ${var.deploy_to_pm_05}" ]
  }

}



#builds for exam PM.08
build {
  name = "programs_install_pm08"
  source "source.virtualbox-ovf.prog-installs" {

    output_filename      = "programs_installed_pm08"
    output_directory     = "./output_programs_installed_pm08"
    source_path          = "./output_windows_installed/windows_installed.ovf"

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
    inline = ["choco install /y yarn"]
  }

  provisioner "windows-shell" {
    inline = ["choco install /y git"]
  }
  
  provisioner "windows-shell" {
    inline = ["choco install /y nodejs-lts"]
  }
  
  provisioner "windows-shell" {
    inline = ["choco install /y curl"]
  }
  
  

}

build {
  name = "packages_install_pm08"
  source "source.virtualbox-ovf.prog-installs" {

    vboxmanage_post = [
      ["modifyvm", "{{.Name}}", "--nic1", "none"]
    ]
    output_filename      = "packages_installed_pm08"
    source_path          = "./output_programs_installed_pm08/programs_installed_pm08.ovf"
    output_directory     = "./output_packages_installed_pm08"

  }
  
  


 
 provisioner "windows-shell" {
    inline = ["yarn global upgrade"]
 }

  provisioner "windows-shell" {
    inline = ["yarn global add typescript"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add @vue/cli"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add create-react"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add create-vue"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add @angular/cli"]
  }
  provisioner "windows-shell" {
    inline = ["yarn global add prettier eslint"]
  }

  #Create simple react application
  provisioner "windows-shell" {
    inline = ["cd c:\\users\\student\\desktop",
    "yarn create react-app react-student-app",
    "cd react-student-app",
    "yarn add  @reduxjs/toolkit react-redux react-dom react-router-dom formik react-content-loader rxjs zone.js"    
    ]
  }
  
  #Create simple vue application
  provisioner "windows-shell" {
    inline = ["cd c:\\users\\student\\desktop",
    "yarn create vue vue-student-app --ts --jsx --router --pinia --eslint-with-prettier  --force",
    "cd vue-student-app",
    "yarn add vue-router"
    ]
  }
  
  #Create simple angular application
  provisioner "windows-shell" {
    inline = ["cd c:\\users\\student\\desktop",
#    "ng set --global packageManager=yarn",
    "ng new --defaults angular-student-app"
    ]
  }
  
  


  provisioner "shell-local" {
    inline = ["if [ ! -f \"./downloads/bootstrap.zip\" ] ; then wget -nc https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip -O ./downloads/bootstrap.zip ; fi "]
  }

  provisioner "windows-shell" {
    inline = ["curl http://%PACKER_HTTP_ADDR%/bootstrap.zip --output C:\\Users\\Student\\Desktop\\bootstrap.zip"]
  }


  post-processor "shell-local" { 
      inline = [ "rclone copy -P output_packages_installed_pm08 ${var.deploy_to_pm_08}" ]
  }

}
