RED='\033[0;31m'
CLEAR='\e[0m'


cat <<a
  
 _       _                      _______           _ _         
(_)     (_)                    (_______)         | (_)  _     
 _       _ ____  _   _ _   _    _______ _   _  __| |_ _| |_   
| |     | |  _ \| | | ( \ / )  |  ___  | | | |/ _  | (_   _)  
| |_____| | | | | |_| |) X (   | |   | | |_| ( (_| | | | |_   
|_______)_|_| |_|____/(_/ \_)  |_|   |_|____/ \____|_|  \__)  
                                                              
         UBUNTU / RHEL / CENT-OS CONFIGURATION AUDIT TOOL                                   
		 By :: Kunal Mahar
	
	
a



#CHECK LINUX FLAVOUR
if [[ -f /etc/lsb-release ]]
then
RELEASE="ubuntu"
elif [[ -f /etc/redhat-release ]]
then
RELEASE="redhat"
else
echo "Release a'int Ubuntu or RedHat"
fi


#CHECK GRUB.CFG PATH
if [[ -f /boot/grub/grub.cfg ]]
then
BFP="/boot/grub/grub.cfg"
else
BFP="/boot/grub2/grub.cfg"
fi


#CHECK SEPARATE TMP PARTITION
function tmp()
{
if [[ $(grep "[[:space:]]/tmp[[:space:]]" /etc/fstab) == '' ]]
then
echo -e "► ${RED}/TMP ENTRY NOT FOUND IN FSTAB${CLEAR}"
else
nodev
nosuid
noexec
fi
}

#CHECK XORG
function xorg()
{
if [[ $RELEASE == "ubuntu" ]]
then
if [[ $(dpkg -l | grep x11) != '' ]]
then
echo -e "► ${RED}X11 installed${CLEAR}"
fi
else
if [[ $(rpm -q xorg-x11-server-common) != "package xorg-x11-server-common is not installed" ]]
then
echo -e "► ${RED}X11 installed ${CLEAR}"
fi
fi
}

#CHECK SYNCOOKIES
function syncookies()
{
if [[ $(sysctl net.ipv4.tcp_syncookies) != "net.ipv4.tcp_syncookies = 1" ]]
then
echo -e "► ${RED}TCP SYN COOKIES NOT SET${CLEAR}"
fi	
}

#CHECK HOST FILE PERMISSION
function hostfileperm()
{
if [[ $(ls -l /etc/hosts.allow | cut -d" " -f 1) != "-rw-r--r--." ]]
then
echo -e "► ${RED}DIFFERENT PERMISSION SET IN /ETC/HOSTS.ALLOW${CLEAR}"
fi
}


#CHECK NODEV IN TMP
function nodev()
{
if [[ !$(grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev) ]]
then
echo -e "► ${RED}/TMP NOT CONFIGURED TO CREATE BLOCK OR CHARACTER SPECIAL DEVICES${CLEAR}"
fi	
} 
 
#CHECK NOSUID IN TMP
function nosuid()
{
if [[ !$(grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid) ]]
then
echo -e "► ${RED}/TMP PARTITION IS SET WITHOUT NOSUID OPTION${CLEAR}"
fi 
}

#CHECK NOEXEC
function noexec()
{
if [[ !$(grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec) ]]
then
echo -e "► ${RED}/TMP WITHOUT SUID SET${CLEAR}"
fi	
}

#CHECK LOG
function log()
{
if [[ !$(grep "[[:space:]]/var/log[[:space:]]" /etc/fstab) ]]
then
echo -e "► ${RED}NO SEPARATE PARTITION FOR /VAR/LOG${CLEAR}"
fi
}


#CHECK AIDE
function aide()
{
if [[ $RELEASE == "ubuntu" ]]
then
if [[ $(dpkg -l | grep aide) == '' ]]
then
echo -e "► ${RED}AIDE not installed${CLEAR}"
fi
else
if [[ $(rpm -q xorg-x11-server-common) == "package aide is not installed" ]]
then
echo -e "► ${RED}AIDE not installed ${CLEAR}"
fi
fi
}

#CHECK GPGCHECK
function gpgcheck()
{
if [[ $RELEASE == "redhat" ]]
then
if [[ $(grep gpgcheck /etc/yum.conf) != "gpgcheck=1" ]]
then
echo -e "► ${RED}RPM PACKAGE SIGNATURE IS NOT BEING CHECKED PRIOR TO INSTALLATION.${CLEAR}"
fi
fi
}

#CHECK RSYSLOG
function rsyslog()
{
if [[ $(systemctl is-enabled rsyslog) != 'enabled' ]]
then
echo -e "► ${RED}RSYSLOG IS NOT ENABLED${CLEAR}"
fi	
}

#CHECK CORELIMIT
function corelimit()
{
if [[ $(grep "hard core" /etc/security/limits.conf) == '' ]]
then
echo -e "► ${RED}HARD LIMIT IS NOT SET ON CORE DUMPS${CLEAR}"
fi
}

#CHECK SELINUX
function selinux()
{
if [[ $( grep -e enforcing=0 -e selinux=0 $BFP) != '' ]]
then
echo -e "► ${RED}SELINUX DISABLED ON BOOT${CLEAR}"
else
echo -e "► ${RED}SELINUX STATUS: $(systemctl status selinux 2>/dev/null | grep -i Inactive) ${CLEAR}"
fi
}

#CHECK GRUB
function grub()
{
if [[ $(ls -l $BFP | grep 'root root') == '' ]]
then
echo  -e "► ${RED}GRUB.CFG NOT HAS OTHER OWNERS THAN ROOT${CLEAR}"
fi
}

#CHECK FIREWALL
function firewall
{
if [[ $RELEASE == "ubuntu" ]]
then
if [[ $(systemctl status firewalld | grep inactive) != "" ]] && [[ $(systemctl status iptables | grep inactive) != "" ]]
then
echo -e "► ${RED}FIREWALL SERVICE NOT RUNNING${CLEAR}"
fi
else
if [[ $(systemctl is-enabled firewalld | grep disabled) != '' ]]
then 
echo -e "► ${RED}FIREWALL SERVICE NOT RUNNING${CLEAR}"
fi
fi
}

#CHECK AUDITLOGS
function auditlogs
{
if [[ $RELEASE == "redhat" ]] && [[ $(grep -i max_log_file_action /etc/audit/auditd.conf) != 'max_log_file_action = keep_logs' ]]
then
echo -e "► ${RED}ALL AUDIT LOGS ARE NOT STORED${CLEAR}"
fi	
}

#CHECK USER/GROUP MODIFICATIONS
function ugmod
{
if [[ $RELEASE == "redhat" ]] &&  [[ $(grep identity /etc/audit/audit.rules) == '' ]]
then
echo -e "► ${RED}USER/GROUP MODIFICATIONS ARE NOT BEING AUDITED${CLEAR}"
fi
}

#CHECK KERNEL MODULES
function kmods
{
if [[ $RELEASE == "redhat" ]] && [[ $(grep modules /etc/audit/audit.rules) == '' ]]
then
echo -e "► ${RED}KERNEL MOMDULES ARE NOT BEING AUDITED${CLEAR}"
fi
}

#CHECK XFORWARD
function Xforward
{
if [[ -f /etc/ssh/sshd_config ]]
then
if [[ $(grep "^X11Forwarding" /etc/ssh/sshd_config | cut -d" " -f 2) == "yes" ]]
then
echo -e "► ${RED}SSH HAS X11 FORWARDING ENABLED${CLEAR}"
fi
fi
}

#CHECK PASSWORD POLICY
function ppol
{
echo -e "► ${RED}PASSWORD POLICIES${CLEAR}"
for a in `cat /etc/passwd | grep /bin/bash | cut -d":" -f 1`
do
if [[ $(chage -l $a | grep 99999 | cut -d':' -f 2) == " 99999" ]]
then
echo "⌇⎺ ⎻ ⎼ Password Policy For $a Not Set"
fi
done
}

#CHECK SHELLSHOCK
function shellshock
{ 
x='() { :;}; echo -e "► ${RED}SHELLSHOCK:: VULNERABLE${CLEAR}"' bash -c "echo -e  '► ${RED}SHELLSHOCK:: NOT VULNERABLE${CLEAR}'"
}


#CHECK UNWANTED FS
function unwantfs
{
        echo -e "► ${RED}UNWANTED FILE SYSTEM SUPPORT${CLEAR}"
        for a in cramfs freevxfs jffs2 hfs hfsplus udf
        do
	if [[ $(ls /lib/modules/$(uname -r)/kernel/fs | grep $a) ]]
        then
	echo -e "⌇⎺ ⎻ ⎼ $a"
        fi
	done
}

#CHECK AUTHENTICATION FAIL
function authfail
{
if [[ -f /var/log/secure ]]
then
echo -e "► ${RED}PRINTING FAILED AUTH ATTEMPTS${CLEAR}"
grep 'authentication failure' /var/log/secure
fi
}

#CHECK LOCKOUT POLICY
function lockout
{
if [[ $RELEASE == "redhat" ]] && [[ $(grep -w 'deny=' /etc/pam.d/system-auth) == '' ]]
then
echo -e "► ${RED}ACCOUNT LOCKOUT POLICY IS NOT SET${CLEAR}"
fi
}

#CHECK ICMP_REDIRECT
function icmpred
{
if [[ $(sysctl net.ipv4.conf.all.accept_redirects) == "net.ipv4.conf.all.accept_redirects = 1" ]] || [[ $(sysctl net.ipv4.conf.default.accept_redirects)=="net.ipv4.conf.default.accept_redirects = 1" ]]
then
echo -e "► ${RED}ICMP REDIRECTS ARE ON${CLEAR}"
fi
}


#SCRIPT EXECUTES FROM HERE
if [ "$EUID" != 0 ]
then
echo "Run the script by su root"
exit
else 
tmp
xorg
syncookies
hostfileperm
log
aide
gpgcheck
corelimit
selinux
grub
firewall
auditlogs
ppol
ugmod
kmods
Xforward
shellshock
unwantfs
authfail
lockout
fi


