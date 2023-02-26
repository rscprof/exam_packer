Проект содержит скрипты для автомаизации развёртывания программного обеспечения
для проведения экзаменов по модулям ПМ.05 и ПМ.08 студентов специальности 09.02.07 Информационные системы
и программирование.

Список программного обеспечения для ПМ.05:
+ laragon (bundle для простой веб-разработки)
+ vscode
+ express (npm)
+ flask (pip)
+ gimp 
+ LibreOffice
+ postman
+ pycharm (community edition)
+ prettier (npm)
+ eslint (npm)
+ redux/toolkit
+ react-redux
+ react-router-dom
+ formik
+ react-content-loader
+ flask-sqlalchemy (pip)
+ jinja2 (pip)
+ flask-mysql (pip)
+ secrets (pip)
+ https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip
+ wordpress в кеш laragon
+ vuejs
+ vuejs-router
+ reactjs
+ flask-mashmallow (pip)
+ flask-login (pip)
+ Werkzeug (pip)

Список программного обеспечения для ПМ.08:
+ vscode
+ gimp 
+ LibreOffice
+ postman
+ prettier 
+ eslint 
+ redux/toolkit
+ react-redux
+ react-router-dom
+ formik
+ react-content-loader
+ https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip
+ vuejs
+ vuejs-router
+ angular
+ reactjs

Для развёртывания проекта необходимо установить следующее программное обеспечение:
- packer
- VirtualBox

Установку следует проводить в Linux по причине того, что под Windows установочные файлы нельзя скачать с сайта 
разработчиков (packer).

Инструкция по установке:
- скачайте ISO-образ Windows 10
- запишите его в каталог ./image
- создайте файл deploy.auto.pkrvars.hcl, измените переменные для себя (переменные указывают, 
куда производить копирование результата, и контрольную сумму ISO)
- возможно измените сумму в файле deploy.auto.pkrvars.hcl
- запустите packer init .
- запустите ./build_05.sh (для ПМ.05)
- запустите ./build_08.sh (для ПМ.08)

