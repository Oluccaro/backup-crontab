#!/bin/bash
#Programa parar deixar mais intuitivo o uso de crontab para o usuário
#
clear
echo "+----------------------------------------------------------------+"
echo "|                   Bem vindo ao crontab fácil                   |"
echo "+----------------------------------------------------------------+"
# Aqui temos que a origem e o destino são passados como argumentos via
# chamada da função execrontab.sh
#variáveis contendo argumentos

origem=$1
destino=$2

#Nesse passo confirmamos se os endereços estão corretos
echo
echo "origem =  $origem"
echo "destino = $destino"
echo
echo -n "Você confirma os endereços de origem e destino? (y/n) "
read confirma
echo

if [ $confirma != "y" ]; then
	echo "Erro nos endereços"
	echo "Saindo..."
	exit
fi
echo
echo "Endereço correto, continuando..."
echo "Agora vocẽ pode escolher uma opção de agendamento periódico do crontab"

# Agora iremos verificar qual da opções de intervalo de execução o usuário
# prefere. Será oferecidas o backup de minuto a minuto, hora em hora,
# diariamente, ou semanalmente com o usuário escolhendo a hora e o dia da semana

frequencia(){
	echo
	echo "+---------------------------------------------------+"
	echo "|                Escolha uma opção                  |"
	echo "+---------------------------------------------------+"
	echo
	echo "opção 1) Agendamento do crontab em intervalo de minutos"
	echo "opção 2) Agendamento do crontab de hora em hora"
	echo "opção 3) Agendamento do crontab diariamente"
	echo "opção 4) Agendamento crontab mensalmente"
	echo "opção 5) Realizar um backup único agora"
	echo "opção 6) Sair"
	echo
	echo -n "Digite o número da opção: "
	read opt
	echo
	case $opt in
		1) echo "opção 1"; minuto;;
		2) echo "opção 2"; hora;;
		3) echo "opção 3"; dia;;
		4) echo "opção 4"; mes;;
		5) echo "opção 5"; backupagora;;
		6) echo "opção 6"; exit;;
		*) echo "opção inválida"; frequencia;;
	esac
}

minuto(){
	echo
	echo "De quantos em quantos minutos gostaria de executar seu backup?"
	echo -n "Digite um valor de 1 a 59: "
	read mm
	echo
	clock="*/$mm * * * *"
	if  (($mm < 1)) || (($mm > 59));then
		minuto
	fi
}

hora(){
	echo
	echo "Escolha de quantas em quantas horas quer realizar o backup"
	echo -n "Digite um valor de de 1 a 23 horas: "
	read hh
	echo
	echo "E o minuto em que o backup se repete "
	echo -n "Digite um valor de 0 a 59: "
	read mm
	echo
	clock="$mm */$hh * * *"
	if (($hh < 0)) || (($hh > 23)) || (($mm < 1)) || (($mm > 59)); then
		hora
	fi
}

dia(){
	echo
	echo "Digite o minuto em que gostaria de realizar o backup diário"
	echo -n "Digite um valor de 0 a 59: "
	read mm
	echo "Digite a hora em que gostaria de realizar o backup diário"
	echo -n "Digite um valor de 0 a 23: "
	read hh
	echo
	clock="$mm $hh * * *"
	if (($mm < 0)) || (($mm > 59)) || (($hh < 0)) || (($mm > 23)); then
		dia
	fi
}

mes(){
	echo
	echo "Digite o minuto em que gostaria de realizar o backup diário"
	echo -n "Digite um valor de 0 a 59: "
	read mm
	echo
	echo "Digite a hora em que gostaria de realizar o backup diário"
	echo -n "Digite um valor de 0 a 23: "
	read hh
	echo
	echo "Digite o dia em que gostaria de realizar o backup"
	echo -n "Digite um valor de 1 a 30: "
	read dd
	echo
	echo "Digite de quantos em quantos meses você gostaria de realizar esse backup"
	echo -n "Digite um valor de 1 a 12: "
	read MM
	echo
	clock="$mm $hh $dd */$MM *"
	if (($hh < 0)) || (($hh > 23)) || (($mm < 0)) || (($mm > 23)) || (($dd < 1)) || (($dd > 29)); then
		dia
	fi
}

backupagora(){
	echo
	echo "+------------------------------------------------------------------+"
	echo "|              Escolha agora as opções de backup                   |"
	echo "+------------------------------------------------------------------+"
	echo
	options="-"
	echo -n "Deseja manter os metadados dos arquivos? (y/n) "
	read yn
	echo
	if [[ $yn == 'y' ]]; then
		options+="a"
	fi
	echo -n "Deseja sincronizar somente se o arquivo da pasta origem for mais novo? (y/n) "
	read yn
	echo
	if [[ $yn == 'y' ]]; then
		options+="u"
	fi
	echo
	echo  "Deseja que arquivos inexistentes na origem, mas existentes no destino "
	echo -n "sejam excluídos? (y/n) "
	read yn
	echo
	delete=""
	if [[ $yn == 'y' ]]; then
		delete="--delete"
	fi
	echo -n "Tem algum arquivo ou diretório que você não gostaria que fosse sincronizado? (y/n) "
	read yn
	echo
	echo "exlist.txt" > $origem/exlist.txt
	if [[ $yn == "y" ]]; then
		run=true
		while [[ $run == true ]]; do
			echo "Digite o nome do arquivo ou diretório que você não deseja sincronizar: "
			read name
			echo
			echo -n "Deseja mesmo que o '$name' não seja sincronizado? (y/n) "
			read yn
			echo
			if [[ $yn == 'y' ]]; then
				echo "$name" >> $origem/exlist.txt
			fi
			echo
			echo -n "Deseja inserir mais um arquivo? (y/n) "
			read yn
			echo
			if [[ $yn != 'y' ]]; then
				run=false
			fi
		done
	fi
	echo -n "Deseja que arquivos não sincronizados sejam excluídos caso encontrados no destino? (y/n) "
	read yn
	echo
	excluded=""
	if [[ $yn == 'y' ]]; then
		excluded="--delete-excluded"
	fi
	echo -n "Deseja criar um arquivo do tipo log (que vai conter informações do backup)? (y/n) "
	read yn
	echo
	logfile=""
	if [[ $yn == 'y' ]]; then
		options+="vr"
		logfile="--log-file=$destino/logsync.txt"
		echo "Teu arquivo log poderá ser encontrado em $destino/logsync.txt"
	fi
	mydir="$(dirname "$(realpath "$0")")"
	echo $mydir
	echo "O formato do comando nsync vai ficou: "
	echo
	echo "rsync $options $delete $exclude $excluded $logfile $origem $destino"
	echo
	if [[ $options == "-" ]]; then
		options+="r"
	fi
	exclude="--exclude-from=$origem/exlist.txt"
	if (($opt == 5)); then
		echo "Executando o Backup..."
		echo "Você pode checar seu arquivo log para mais informações se assim desejar"
		echo
		rsync $options $delete "$exclude" $excluded $logfile $origem $destino
		exit
	else
		echo "Backup Agendado com sucesso"
		crontab -l | { cat; echo "$clock rsync $options $delete $exclude $excluded $logfile $origem $destino"; } | crontab -
	fi
}

frequencia

backupagora

