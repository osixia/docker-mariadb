#!/bin/sh

mysql -u admin -ptoor -e "create database testDB;"
mysql -u admin -ptoor -e "CREATE USER 'demo-user'@'%' IDENTIFIED BY 'password';"
mysql -u admin -ptoor -e "GRANT SELECT,UPDATE,DELETE ON testDB.* TO 'demo-user'@'%' IDENTIFIED BY 'password';"
mysql -u admin -ptoor -e "GRANT SELECT,UPDATE,DELETE ON testDB.* TO 'demo-user'@'localhost' IDENTIFIED BY 'password';"

mysql -u admin -ptoor -e 'FLUSH PRIVILEGES;'

mysql -u admin -ptoor -e "CREATE TABLE testDB.equipment ( id INT NOT NULL AUTO_INCREMENT, type VARCHAR(50), quant INT, color VARCHAR(25), PRIMARY KEY(id));"
mysql -u admin -ptoor -e "INSERT INTO testDB.equipment (type, quant, color) VALUES ('slide', 2, 'blue');"


