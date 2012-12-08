bedrocklinux-unofficial
=======================

brcadd.sh ---------------------------------------------------------------------------

Usage: 
       brcadd CLIENT_NAME

Summary:
	Takes name of client and adds it to configuration scripts 
	      /var/chroot/bedrock/opt/bedrock/etc/brclients.conf
	      /var/chroot/bedrock/opt/bedrock/etc/capchroot.allow
      	      /etc/fstab
      	      Creates necessary directories for the shared bind mounts

TODO: 
      Add support for pulling in clients from the web:
         Gentoo	  
	 Deb/Ubuntu
	 Arch
	 Fedora
     
      Add groups and other neccessary configs for clients
      
      Add update line for client in brclient.conf
      
      Check rc.conf for BRPATH and create it in client

      Add message at end of script, tell user to double check the configuration files 

      Make help message more useful and possibly generate man page with help2man?

---------------------------------------------------------------------------------------