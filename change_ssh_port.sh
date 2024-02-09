#!/bin/bash

# input port
read -rp "input ssh port>" PORT

# validate
if [ ${#PORT} -eq 0 ];then
  echo "error: not input port."
  exit
fi

# deploy key file
read -rp "setting key only login. [true,false]>" KEY_ONLY
if [ "${KEY_ONLY}" = "true" ]; then
  if [ ! -e "/root/.ssh/authorized_keys" ]; then
    cp ./authorized_keys /root/.ssh/
  fi
  chmod 600 /root/.ssh/authorized_keys
  echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/PasswordAuthentication.conf
  echo "setting key only login success!!"
fi

# modify ssh and selinux
echo "Port ${PORT}" > /etc/ssh/sshd_config.d/port.conf
semanage port -a -t ssh_port_t -p tcp "${PORT}"

# modify firewall service
\cp -r /lib/firewalld/services/ssh.xml /etc/firewalld/services/
sed -ri "s/22/${PORT}/g" /etc/firewalld/services/ssh.xml

# reload services
systemctl restart firewalld
systemctl restart sshd

echo "compleated!!"