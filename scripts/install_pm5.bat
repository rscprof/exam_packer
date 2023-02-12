set PATH=%PATH%;C:\ProgramData\chocolatey\
if not exist "C:\Windows\Temp\laragon-wamp.exe" (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe', 'C:\Windows\Temp\laragon-wamp.exe')" <NUL
)
start /WAIT C:\Windows\temp\laragon-wamp.exe /SILENT
choco install /y vscode
choco install /y gimp
choco install /y libreoffice-fresh
choco install /y postman
choco install /y pycharm-community
choco install /y openssl
call c:\laragon\bin\nodejs\node-v18\npm install -g express prettier jslint vue@next vue-router@4 react 
c:\laragon\bin\python\python-3.10\python -m pip install flask flask-sqlalchemy jinja2 flask-mysql pyOpenSSL secrets
mkdir c:\laragon\tmp\cached
c:\laragon\bin\git\mingw64\bin\curl https://wordpress.org/latest.tar.gz --output C:\laragon\tmp\cached\wordpress.latest.tar.gz

