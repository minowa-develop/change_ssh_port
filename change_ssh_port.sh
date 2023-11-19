# input port
read -p "input ssh port>" PORT

# constant
SSH_CONFIG_PATH="/etc/ssh/sshd_config"

# validate
if [ ${#PORT} -eq 0 ];then
  echo "error: not input port."
  exit
fi

read -p "setting key only login. [true,false]>" KEY_ONLY
if [ $KEY_ONLY = "true" ]; then
  find /* -name "authorized_keys" | xargs -i{arg} chmod 600 {arg}
  sed -ri "s/#?PasswordAuthentication .*/PasswordAuthentication no/" $SSH_CONFIG_PATH
  echo "setting key only login success!!"
fi

# modify ssh and selinux
sed -ri "s/#?Port .*/Port ${PORT}/g" $SSH_CONFIG_PATH
semanage port -a -t ssh_port_t -p tcp $PORT

# modify firewall service
\cp -r /lib/firewalld/services/ssh.xml /etc/firewalld/services/
sed -ri "s/22/${PORT}/g" /etc/firewalld/services/ssh.xml

# reload services
systemctl restart firewalld
systemctl restart sshd

echo "compleated!!"