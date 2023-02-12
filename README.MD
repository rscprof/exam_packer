Проект содержит скрипты для автомаизации развёртывания программного обеспечения
для проведения экзамена по модулю ПМ.05 студентов специальности 09.02.07 Информационные системы
и программирование.

Задание предполагает создание клиента и сервера, соответственно необходимо ПО для развертывания локального 
сервера и редакторы.

Список программного обеспечения:
+ laragon (bundle для простой веб-разработки)
+ vscode
+ express (npm)
+ flask (pip)
+ gimp 
+ impress
+ postman
+ pycharm (community edition)
+ prettier (npm)
+ jslint (npm)
+ flask-sqlalchemy (pip)
+ jinja2 (pip)
+ flask-mysql (pip)
- secrets (python)
+ https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip


Для развёртывания проекта необходимо установить следующее программное обеспечение:
- packer
- vagrant
- VirtualBox
Установку следует проводить в Linux по причине того, что под Windows установочные файлы нельзя скачать с сайта 
разработчиков (packer, vagrant).

Инструкция по установке:
- скачайте ISO-образ Windows 10
- запишите его в каталог ./ms-windows/iso
- в build.sh исправьте имя образа
- запустите build.sh