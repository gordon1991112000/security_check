#!/bin/bash

##################
# Functions
##################

####### Send messgae to specific telegram group #######
function notification(){
   #curl -s –max-time 10 -d "chat_id=-342387488&disable_web_page_preview=1&text=`echo -e '\U0001F198'`$1" https://api.telegram.org/bot731592033:AAGyaKK_bxK-mDtJgijwWE5Ldz16WN0pSKE/sendMessage
   curl -s –max-time 10 -d "chat_id=-656722013&disable_web_page_preview=1&text=`echo -e '\U0001F198'`$1" https://api.telegram.org/bot5323535871:AAH3Q0rLrNg6GMwJDXgj83izEVhKf81S5rY/sendMessage | jq '.'
}

####### Check any SSH login not using office gateway IP #######
function check_ssh_ip(){
   SUBJECT="Abnormal IP try to login server : `date --date='yesterday' '+%b %e'`"
   MESSAGE="/tmp/check-ssh-ip-logs.txt"
   login_ip="$(echo $SSH_CONNECTION | cut -d " " -f 1)"
   login_name="$(whoami)"

   if [ $login_ip != 210.3.244.178 ] || [ $login_ip != 203.80.242.177 ]
   then
      echo  "$SUBJECT" >> $MESSAGE
      echo  "Hostname: `hostname`" >> $MESSAGE
      echo -e "\n" >> $MESSAGE
      echo -e "IP address: $login_ip tried login with user $login_name" >> $MESSAGE
      telegram=`cat $MESSAGE`
      notification "$telegram"
   else
      echo "Okay" >> $MESSAGE
   fi
   rm $MESSAGE
}

####### Check any new user added ####### 
function check_useradd(){
   prev_count=0
   count=$(grep -i "`date --date='yesterday' '+%b %e'`" /var/log/secure | egrep -wi 'useradd' | wc -l)
   
   if [ "$prev_count" -lt "$count" ] ; then
      SUBJECT="New User Account is created on server : `date --date='yesterday' '+%b %e'`"
      MESSAGE="/tmp/new-user-logs.txt"

      echo  "$SUBJECT" >> $MESSAGE
      echo  "Hostname: `hostname`" >> $MESSAGE
      echo -e "\n" >> $MESSAGE
      echo "The New User Details are below." >> $MESSAGE
      echo "+------------------------------+" >> $MESSAGE
      grep -i "`date --date='yesterday' '+%b %e'`" /var/log/secure | egrep -wi 'useradd' | grep -v 'failed adding'| awk '{print $4,$8}' | uniq | sed 's/,/ /' >>  $MESSAGE
      echo "+------------------------------+" >> $MESSAGE
      telegram=`cat $MESSAGE`
      notification "$telegram"
      rm $MESSAGE
   fi
}

####### Check any user login except root/eclass/junior #######
function check_user_login(){
   prev_count=0
   count=$(grep -i "`date --date='yesterday' '+%b %e'`" /var/log/secure | egrep -wi 'pam_unix' | grep -oP '(?<=user )[^ ]*' | grep -v root | grep -v eclass | wc -l)
   
   if [ "$prev_count" -lt "$count" ] ; then
      SUBJECT="Abnormal user Account login server : `date --date='yesterday' '+%b %e'`"
      MESSAGE="/tmp/abnormal-user--login-logs.txt"

      echo  "$SUBJECT" >> $MESSAGE
      echo  "Hostname: `hostname`" >> $MESSAGE
      echo -e "\n" >> $MESSAGE
      echo "The User Details are below." >> $MESSAGE
      echo "+------------------------------+" >> $MESSAGE
      grep -i "`date --date='yesterday' '+%b %e'`" /var/log/secure | egrep -wi 'pam_unix\(sshd' | grep -oP '(?<=user )[^ ]*' | grep -v root | grep -v eclass | grep -v junior | uniq >>  $MESSAGE
      echo "+------------------------------+" >> $MESSAGE
      telegram=`cat $MESSAGE`
      notification "$telegram"
      rm $MESSAGE
   fi
}

####### Check /usr/local/x-ui exist or not #######
function check_x-ui(){
   SUBJECT="x-ui directory FOUND : `date --date='yesterday' '+%b %e'`"
   MESSAGE="/tmp/check-x-ui-logs.txt"
   last_log="/tmp/check_last_log.txt"

   if [ -d /usr/local/x-ui ]
   then
      echo  "$SUBJECT" >> $MESSAGE
      echo  "Hostname: `hostname`" >> $MESSAGE
      echo -e "\n" >> $MESSAGE
      echo "/usr/local/x-ui is found Please check." >> $MESSAGE
      telegram=`cat $MESSAGE`
      notification "$telegram"
      last | grep pts >> $last_log
      /home/telegram/tgsend.sh sendf $last_log
      rm $last_log
   else
      echo "Okay" >> $MESSAGE
   fi
   rm $MESSAGE
}

function Check_Privilege(){
  if [ `id -u` -ne 0 ]; then
        echo "You need root privileges to run this script."
        exit 0
  fi
}

#################
#Main
#################
Check_Privilege
while getopts "iulx" opt; do
   case ${opt} in
      i) check_ssh_ip
            ;;
      u) check_useradd
            ;;
      l) check_user_login
            ;;
      x) check_x-ui
            ;; 
   esac
done


