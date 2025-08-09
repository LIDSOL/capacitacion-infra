Playbooks ustados 
actualizaciones.yml
Se realiza la instalación de unattended-upgrades
Posteriormenre se realiza la activación de las actualizaciones automáticas
> Se configuran solo actualizaciones de seguridad 
> Finalmete se habilita y arranca todo 

firewall.yml

> Se instala nftables
> Abre puertos 22, 80,443 y bloquea el resto 

SSHD.yml

>Desactiva el login por root
>Desactiva la autenticación por contraseña

servidor.yml
>Instala Nginx
>Inicia Ngnix y el index.html.j2

index.html
Crea una página index.html personalizada donde se cada que se inicia la página en una máquina virtual diferente, la vienvenida cambia con el nombre la MV con ansible_hostname 

Todos estos playbooks se encuentran dento de playbook.yml para poder ejecutar todos de una sola vez 

Para ejecutar los playbook por separado se uso 
ansible-playbook -i inventory.ini actualizaciones.yml
ansible-playbook -i inventory.ini firewall.yml
ansible-playbook -i inventory.ini servidor.yml
ansible-playbook -i inventory.ini SSHD.yml

Para ejecutar el playbook que contiene todas se uso 
ansible-playbook -i inventory.ini playbook.yml
