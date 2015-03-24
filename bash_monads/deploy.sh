#!/bin/bash

DEPLOY_HOST=127.0.0.1
BACKUP_NAME=backup_`date +%Y-%m-%d-%s`

function backup() {
	echo '--- BACKUP'
	ssh -p 2222 root@${DEPLOY_HOST} cp /etc/nginx/nginx.conf /etc/nginx/${BACKUP_NAME} \
		&& return 0 
	return 1
}

function restore() {
	echo '--- RESTORE'
	ssh -p 2222 root@${DEPLOY_HOST} cp /etc/nginx/${BACKUP_NAME} /etc/nginx/nginx.conf 	\
		&& ssh -p 2222 root@${DEPLOY_HOST} reboot 										\
		&& sleep 10 																	\
		&& return 0
	return 1
}

function deploy() {
	echo '--- DEPLOY'
	scp -P 2222 nginx.conf root@${DEPLOY_HOST}:/etc/nginx/nginx.conf 	\
		&& ssh -p 2222 root@${DEPLOY_HOST} reboot 						\
		&& sleep 10 													\
		&& return 0
	return 1
}

function check() {
	echo '--- CHECK'
	curl -s --connect-timeout 60 http://localhost:5005 > /dev/null 		\
	    && echo '==> OK' 												\
		&& return 0
	echo '==> ERR'
	return 1 
}

backup 						&& 	\
	(deploy					&& 	\
	check 					&&  \
	echo     '### OK'		&&  \
	exit 0) 					\
	|| (restore 			&&	\
		check 				&&  \
		echo '### FAIL'		&&  \
		exit 1)