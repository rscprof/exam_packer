rem download bootstrap
if not exist "C:\User\Student\Desktop\bootstrap.zip" (
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip', 'C:\User\Student\Desktop\bootstrap.zip')" <NUL
)
