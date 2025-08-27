# Elastic Stack Auto-Installer (Ubuntu/Unix)

Bash script to automate the full installation and configuration of the **Elastic Stack** (Elasticsearch + Kibana) with **HTTPS enabled**. The script sets up a single-node environment suitable for labs, demos, and learning security monitoring with Elastic.  

## Preview

![Elastic Stack Installation Screenshot](https://github.com/daniyyell-dev/auto_install_elastic_stack/blob/main/elastic.png)


## Core Features

- **Automatic cleanup** of any old Elasticsearch/Kibana installations.  
- Installs **Elasticsearch + Kibana** from the official Elastic repo.  
- Applies **JVM heap and kernel tuning** for reliable performance.  
- Configures Elasticsearch in **single-node mode**, bound to your system’s IP.  
- Automatically sets the **elastic superuser password**.  
- Generates and applies **Kibana encryption keys**.  
- Enables **HTTPS for Kibana** with self-signed certs.  
- Prints out **important setup info** (URLs, credentials, enrollment token).  
- Supports multiple network interfaces — script detects available `en*` IPs and asks the user to choose.  

---

## Usage

Clone this repository and run the script:

```bash
chmod +x install_elastic_stack.sh
./install_elastic_stack.sh 
```

or just copy and paste this one liner. 

```bash
sudo apt install -y git && git clone https://github.com/daniyyell-dev/auto_install_elastic_stack && cd auto_install_elastic_stack && chmod +x install_elastic_stack.sh && bash install_elastic_stack.sh
```
## After Installation

Once installation is complete:

1. Visit Kibana in your browser:
   https://<YOUR-IP>:5601
   (The <YOUR-IP> is detected and shown by the script.)

2. Login with your credentials:
   Username: elastic
   Password: ******** (El4sticSecu4ity) which can be change also

3. Paste the Enrollment Token when prompted.
   The script prints the token — it looks like a long Base64 string starting with ey...

4. If the verification code expires:
   Run the verification code tool to generate a new 6-digit code:

```bash
 /usr/share/kibana/bin/kibana-verification-code
```
   Copy the 6-digit code displayed.
   Paste it into Kibana when asked.

-----------------------------------------------------

## Access Points

- Elasticsearch:
  https://<YOUR-IP>:9200

- Kibana (HTTPS):
  https://<YOUR-IP>:5601

Certificates are self-signed and generated locally.

-----------------------------------------------------

## Notes

- This script is intended for lab/demo environments.
- Not recommended for production as-is without further security hardening.


Certificates are self-signed and generated locally.

This script is for lab/demo environments and not recommended for production as-is.

---

## References & Credits

The idea and installation logic were inspired by community work I’ve used over the years.  
I adapted and wrote my own Bash script to fully automate the Elastic Stack setup process.  

Reference: [Kali Purple Documentation](https://gitlab.com/kalilinux/kali-purple/documentation)  


