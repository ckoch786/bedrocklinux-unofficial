#!/bin/sh

# Copyright (C) 2012  Cory Koch

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


# source settings and functions
. /opt/bedrock/lib/brfunctions
. /etc/profile


CLIENT_NAME=$1
CURRENT_CLIENT=$(brw)
#UPDATE= TODO default for clients in list else ask user for update info

FSTAB=/var/chroot/$CURRENT_CLIENT/etc/fstab
BRCLIENTS=/var/chroot/$CURRENT_CLIENT/opt/bedrock/etc/brclients.conf
CAPCHROOT=/var/chroot/$CURRENT_CLIENT/opt/bedrock/etc/capchroot.allow

write_fstab()
{
(
cat <<EOF

# $CLIENT_NAME-------------------------------------------------------------------------------------------------------- 
/proc     /var/chroot/$CLIENT_NAME/proc     proc    noauto,user,exec,nosuid           0  0
/dev      /var/chroot/$CLIENT_NAME/dev      bind    noauto,user,exec,dev,bind,nosuid  0  0
/dev/pts  /var/chroot/$CLIENT_NAME/dev/pts  devpts  noauto,user,exec,dev,nosuid       0  0
/dev/shm  /var/chroot/$CLIENT_NAME/dev/shm  bind    noauto,user,exec,dev,bind,nosuid  0  0
/sys      /var/chroot/$CLIENT_NAME/sys      sysfs   noauto,user,exec,dev,nosuid       0  0

# Ensures client can itself prepare other clients:
/etc/fstab           /var/chroot/$CLIENT_NAME/etc/fstab            bind   noauto,user,bind,nosuid           0  0
/opt/bedrock         /var/chroot/$CLIENT_NAME/opt/bedrock          bind   noauto,user,bind,exec,suid        0  0
/var/chroot          /var/chroot/$CLIENT_NAME/var/chroot           bind   noauto,user,bind,exec,suid        0  0
/var/chroot/bedrock  /var/chroot/$CLIENT_NAME/var/chroot/bedrock   bind   noauto,user,bind,exec,suid        0  0

# Ensures clients properly integrate users:
/etc/group           /var/chroot/$CLIENT_NAME/etc/group            bind   noauto,user,bind,nosuid           0  0
/etc/passwd          /var/chroot/$CLIENT_NAME/etc/passwd           bind   noauto,user,bind,nosuid           0  0
/etc/shadow          /var/chroot/$CLIENT_NAME/etc/shadow           bind   noauto,user,bind,nosuid           0  0
/etc/profile         /var/chroot/$CLIENT_NAME/etc/profile          bind   noauto,user,bind,nosuid           0  0
/home                /var/chroot/$CLIENT_NAME/home                 bind   noauto,user,bind,exec,nosuid      0  0
/root                /var/chroot/$CLIENT_NAME/root                 bind   noauto,user,bind,exec,nosuid      0  0

# Kernel modules 
/lib/modules/3.5.7-gentoo /var/chroot/$CLIENT_NAME/lib/modules/3.5.7-gentoo bind noauto,user,bind,exec,nosuid 0 0

# Needed for many applications:
/etc/hostname        /var/chroot/$CLIENT_NAME/etc/hostname         bind   noauto,user,bind,nosuid           0  0
/etc/hosts           /var/chroot/$CLIENT_NAME/etc/hosts            bind   noauto,user,bind,nosuid           0  0
/etc/resolv.conf     /var/chroot/$CLIENT_NAME/etc/resolv.conf      bind   noauto,user,bind,nosuid           0  0

# Not overly much reason to keep these unique per client:
#/etc/sudoers         /var/chroot/$CLIENT_NAME/etc/sudoers          bind   noauto,user,bind,nosuid           0  0
/tmp                 /var/chroot/$CLIENT_NAME/tmp                  bind   noauto,user,bind,exec,nosuid      0  0
#/usr/src             /var/chroot/$CLIENT_NAME/usr/src              bind   noauto,user,bind,exec,nosuid      0  0
/boot                /var/chroot/$CLIENT_NAME/boot                 bind   noauto,user,bind,exec,nosuid      0  0

#------------------------------------------------------------------------------------------------------------------

EOF
) >> $FSTAB
}

write_brclients()
{
(
cat <<EOF

[$CLIENT_NAME]
path /var/chroot/$CLIENT_NAME
$UPDATE
mount /boot
mount /dev
mount /dev/pts
mount /dev/shm
mount /etc/fstab
mount /etc/group
mount /etc/hostname
mount /etc/hosts
mount /etc/passwd
mount /etc/profile
mount /etc/resolv.conf
mount /etc/shadow
#mount /etc/sudoers
mount /home
mount /opt/bedrock
mount /proc
mount /root
mount /sys
mount /tmp
#mount /usr/src
mount /var/chroot
mount /var/chroot/bedrock

EOF
) >> $BRCLIENTS
}

write_capchroot()
{
    printf "/var/chroot/$CLIENT_NAME\n" >> $CAPCHROOT
}


# Check if user has root privleges
if [[ $EUID -ne 0 ]]
then
    abort "This script must be run as root" 1>&2
    exit 1
else

    # TODO maybe use help2man to make man pages?
    # check for need to print help
    if [ -z "$CLIENT_NAME" ] || [ "$CLIENT_NAME" = "-h" ] || [ "$CLIENT_NAME" = "--help" ]
    then
	echo "Usage: brcadd CLIENT_NAME"
	echo "Add new client to configuration file"
	echo "Arguments:"
	echo "   -h|--help   show this help dialog"
	exit 0    
    else
        # Get list of clients
	ls /var/chroot >> /tmp/chroot.list

        # Create clients location
	mkdir -p /var/chroot/$CLIENT_NAME
	mkdir -p /var/chroot/$CLIENT_NAME/var/chroot/$CLIENT_NAME	
	for i in $(cat /tmp/chroot.list);
	do
	    mkdir -p /var/chroot/$CLIENT_NAME/var/chroot/$i
	done

        # Add entries to fstab TODO add flag for sharing /usr/src
	write_fstab
    
        # Add new client to brclient.conf
	write_brclients

        # Add new client to capchroot.allow
	write_capchroot
    fi
fi 



