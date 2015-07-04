#!/bin/bash    
#description    : create ldap user 
#author         :darkhex
#version        :0.1
#usage          : -
#notes          : This is structured for creating user of ldap (for several servers) 
#============================================================================
if [ "$(whoami)" != 'root' ]
then
  echo $(date): Need to be root >> /tmp/error
  exit 1
fi

echo 'Вы выбрали "Создание нового пользователя"'

echo 'Введите полностью ФИО пользователя'
read FIO
echo -e "\nВведенные данные верны [y/n]? \n$FIO"
read yn
if [ $yn != "y" ]
    then echo "Введите правильные данные"
    exit
fi

echo """К какому офису относится пользователь?
    OTH
    REG"""
read EMPTYPE

# Создаем из ФИО массив
FIO=($FIO)

# Переменные для создания uid 
SURNAME=$(echo ${FIO[0]} | uniconv -encode Russian-Translit | sed "s/'//" | tr '[A-Z]' '[a-z]')
NAME=$(/bin/echo  ${FIO[1]} | uniconv -encode Russian-Translit | cut -c 1 | tr '[A-Z]' '[a-z]')
SNAME=$(/bin/echo ${FIO[2]} | uniconv -encode Russian-Translit | cut -c 1 | tr '[A-Z]' '[a-z]')
MAIL="${SURNAME}.${NAME}@domen.ru"

echo "Учетная запись нового пользователя: $USRNAME"

# Определяем uidNumber пользователя (берем значения с трех серверов, находим большее и увеличиваем на единицу)
UIDNMB=$[$(echo """`ldapsearch -H ldap://10.0.10.1/ -LLL -y '/etc/ldap.secret' -D 'cn=ldapadmin,dc=darkhex,dc=net' "(uidNumber=*)" uidNumber`
`ldapsearch -H ldap://10.0.11.1/ -LLL -y '/etc/ldap.secret' -D 'cn=ldapadmin,dc=darkhex,dc=net' "(uidNumber=*)" uidNumber`
`ldapsearch -H ldap://10.0.9.1/ -LLL -y '/etc/ldap.secret' -D 'cn=ldapadmin,dc=darkhex,dc=net' "(uidNumber=*)" uidNumber`""" |grep uidNumber | sed 's/uidNumber:\ //' |sort -nu |tail -1)+1]

# Ниже 1000 gid имеют только системные группы, потому вывод можно отсеять от мусора. Так же тут учитывается офис пользователя
echo "Выберите идентификатор группы из списка"
getent group | grep $EMPTYPE | awk -F":" '{if ($3 > 1000) {print $3 " - "  $1}}'|sort
echo "идентификатор группы:"
read GIDNMB


# Расположение пользователя в адресной книге. 
echo "Выберете расположения пользователя в адресной книге:"
echo -e """1\tОтдел бухгалтерии
2\tОтдел транспорта
3\tОтдел персонала
4\tАутсорсинг
5\tРегиональный отдел
6\tСекретариат
7\tОтдел маркетинга
8\tКоммерческий отдел
9\tАдминистрация
10\tОтдел развития
11\tIT"""
read OU
if [[ $OU = 1 ]]
then DPTCYR=$(echo -n "Отдел бухгалтерии" | base64 -i)
elif [[ $OU = 2 ]]
then DPTCYR=$(echo -n "Отдел транспорта" | base64 -i)
elif [[ $OU = 3 ]]
then DPTCYR=$(echo -n "Отдел персонала" | base64 -i)
elif [[ $OU = 4 ]]
then DPTCYR=$(echo -n "Аутсорсинг" | base64 -i)
elif [[ $OU = 5 ]]
then DPTCYR=$(echo -n "Региональный отдел" | base64 -i)
elif [[ $OU = 6 ]]
then DPTCYR=$(echo -n "Секретариат" | base64 -i)
elif [[ $OU = 7 ]]
then DPTCYR=$(echo -n "Отдел маркетинга" | base64 -i)
elif [[ $OU = 8 ]]
then DPTCYR=$(echo -n "Коммерческий отдел" | base64 -i)
elif [[ $OU = 9 ]]
then DPTCYR=$(echo -n "Администрация" | base64 -i)
elif [[ $OU = 10 ]]
then DPTCYR=$(echo -n "Отдел развития" | base64 -i)
elif [[ $OU = 11 ]]
then DPTCYR=$(echo -n "IT" | base64 -i)
fi


# Создаем временный файл с шаблоном пользователя для LDAP /tmp/new-user
echo """
dn: uid=${USRNAME},ou=Users,dc=darkhex,dc=net
changetype: modify
replace: sn
sn: ${FIO[0]}
-
replace: givenName
givenName: ${FIO[1]} ${FIO[2]}
-
replace: cn
cn: ${FIO[*]}
-
replace: displayName
displayName: ${FIO[*]}
-
add: mail
mail: ${MAIL}
-
add: ou
ou: ${EMPTYPE} ${DPTCYR}
-
add: sambaMungedDial
sambaMungedDial: your
-
add: sambaPasswordHistory
sambaPasswordHistory: 0000000000000000000000000000000000000000000000000000000000000000
-
replace: shadowMax
shadowMax: 99999
-
add: shadowExpire
shadowExpire: 99999
-
add: shadowInactive
shadowInactive: -1
-
add: shadowWarning
shadowWarning: 7
-
add: shadowFlag
shadowFlag: 134538308
-
add: shadowMin
shadowMin: -1""" > /tmp/new-user

# Создаем пользователя и накладываем поверх него наш шаблон
echo ${GIDNMB} ${USRNAME}
smbldap-useradd -a -G "Domain Users" -g ${GIDNMB} -m ${USRNAME}
smbldap-passwd ${USRNAME}
ldapmodify -H ldap://127.0.0.1:389/ -f /tmp/new-user -x -D "cn=ldapadmin,dc=darkhex,dc=net" -y '/etc/ldap.secret'

## сброс нужных значений переменных в файл /home/domain/shares/update/rstr/credentials
echo "Введите пароль ещё раз"
read PASSWD
OUTFILE=/mnt/pass
# Перед именем пользователя ставим его офис
echo -e """${EMPTYPE} ${FIO[*]}:
login:\t${USRNAME}\t${PASSWD}
почта:\t${MAIL}
########################################""" >> ${OUTFILE}


# Репликация пользователя на другие сервера
ldapsearch -H ldap://127.0.0.1:389/ -b dc=darkhex,dc=net -D cn=ldapadmin,dc=darkhex,dc=net -x -y '/etc/ldap.secret' uid=${USRNAME} > /tmp/user.ldif
# Добавляем пользователя в группу Domain Users на целевом сервере
echo """
dn:cn=Domain Users,ou=Groups,dc=darkhex,dc=net
changetype: modify
add: memberUid
memberUid: ${USRNAME}""" >> /tmp/user.ldif
# Импорт на сервера
ldapadd -H ldap://10.0.11.1:389/ -D cn=ldapadmin,dc=darkhex,dc=net -x -y '/etc/ldap.secret' -f /tmp/user.ldif
