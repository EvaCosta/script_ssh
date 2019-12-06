#!/bin/bash


ip_maquina_virtual=$1
ip_maquina_real=$2

senha_maquina_virtual="123456"
senha_maquina_real="aluno"

diretorio_destino_maquina_virtual="/root/"
diretorio_destino_maquina_real=" /home/aluno/Desktop/"

diretorio_maquina_virtual="/root/sources.list"
diretorio_maquina_real="/home/aluno/Desktop/yum.conf"

diretorio_origem_maquina_virtual="/etc/yum.conf"
diretorio_origem_maquina_real="/etc/apt/sources.list"

nota=`expr 0`

ping -c 2 "$ip_maquina_virtual" &> /dev/null

if [ $? -eq 0 ]
then
    ping -c 2 "$ip_maquina_real" &> /dev/null
    
    if [ $? -eq 0 ]
    then

        sshpass -p "$senha_maquina_virtual" ssh -o StrictHostKeyChecking=no root@$ip_maquina_virtual 'systemctl status sshd | grep "active (running)"'

        if [ $? -eq 0 ]
        then
            echo -e "\nSSH está em execução.\n"
            
            cat ~/.bash_history | egrep "^\s*[0-9]*\s*scp "$diretorio_origem_maquina_real" root@"$ip_maquina_virtual":"$diretorio_destino_maquina_virtual&>/dev/null
            
            md5file1=$(md5sum $diretorio_origem_maquina_real | awk -F " " '{print $1}')

            md5copyfile1=$(sshpass -p "$senha_maquina_virtual" ssh -o StrictHostKeyChecking=no root@$ip_maquina_virtual "md5sum $diretorio_maquina_virtual" |  awk -F " " '{print $1}')

            if [ "$md5file1" != "$md5copyfile1" ]
            then 
                echo -e "Arquivos não correspondem.\n"
            else   
                
                echo -e "Cópia do primeiro arquivo realizada corretamente.\n"
                nota=`expr $nota + 3`
            fi

            if [ $? -eq 0 ]
            then 
                cat ~/.bash_history | egrep "^\s*[0-9]*\s*scp root@10.3.1.56:/etc/yum.conf /home/aluno/Desktop" &>/dev/null
             
                if [ $? -eq 0 ]
                then
                    md5file2=$(sshpass -p "$senha_maquina_virtual" ssh -o StrictHostKeyChecking=no root@$ip_maquina_virtual "md5sum -b $diretorio_origem_maquina_virtual" | awk -F " " '{print $1}')
                    md5copyfile2=$(md5sum -b $diretorio_maquina_real | awk -F " " '{print $1}')
                        
                    if [ "$md5file2" != "$md5copyfile2" ]
                    then 
                        echo -e "Arquivos não correspondem.\n"
                    else   
                        echo -e "Cópia do segundo arquivo realizada corretamente.\n"
                        nota=`expr $nota + 3`
                    fi
                else
                    echo -e "Cópia referente ao segundo arquivo não foi encontrada no historico.\n"
                fi
            else
                echo -e "Cópia referente ao primeiro arquivo não foi encontrada no historico.\n"
            fi
            
        else
            echo -e "SSH não está executando\n"
        fi
    else
        echo -e "Ip da máquina real incorreto.\n"
    fi    
else
    echo -e "A máquina virtual está desligada.\n"
fi
echo "Pontuação:  $nota"