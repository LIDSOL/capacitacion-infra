Para lograr resolver el problema cree un playbook que con el uso de timer ejecuta un script que checka que no haya bugs cal hacer ping a las maquinas vrtuales cada 15 minutos y si hay un bug reinicia el sistema 
para ejecutar el playbook use el comando :

ansible-playbook -i inventory.ini reportes.yml
