set PATH=%PATH%;C:\ProgramData\chocolatey\
if not exist "C:\Windows\Temp\laragon-wamp.exe" (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/leokhoa/laragon/releases/download/6.0.0/laragon-wamp.exe', 'C:\Windows\Temp\laragon-wamp.exe')" <NUL
)
start C:\Windows\temp\laragon-wamp.exe /SILENT
choco install /y vscode
choco install /y gimp
choco install /y impress
choco install /y postman
choco install /y pycharm
start c:\laragon\bin\nodejs\node-v18\npm install -g express prettier jslint
start c:\laragon\bin\python\python-3.10\python -m pip install flask flask-sqlalchemy jinja2 flask-mysql secrets
if not exist "C:\laragon\tmp\cached\wordpress.latest.tar.g" (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://wordpress.org/latest.tar.gz', 'C:\laragon\tmp\cached\wordpress.latest.tar.gz')" <NUL
)
