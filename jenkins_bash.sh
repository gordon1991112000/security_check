#!/bin/bash
echo ${domain_name}
echo ${Flag}
Flag="$(sed 's/\,/ /g' <<<$Flag)"
echo ${Flag}
array=${domain_name}

for Domain in ${array[@]};do
skm use ${Domain}
cd /home/telegram
scp -p check_useradd.sh check_user_login.sh check_x-ui.sh ECSE.sh tgsend.sh tgtoken.ini ${Domain}:/tmp
sshpass ssh -p 22 -o StrictHostKeyChecking=no -o ConnectTimeout=60 -o ServerAliveInterval=60  root@${Domain}  -T << EOF
cd /tmp
./ECSE.sh ${Flag}
rm -f check_useradd.sh check_user_login.sh check_x-ui.sh ECSE.sh tgsend.sh tgtoken.ini
EOF
done

