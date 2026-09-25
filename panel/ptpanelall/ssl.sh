#!/bin/bash

# --- SEMA NEON THEME ---
CYAN='\033[38;5;51m'
PURPLE='\033[38;5;141m'
GRAY='\033[38;5;242m'
WHITE='\033[38;5;255m'
GREEN='\033[38;5;82m'
RED='\033[38;5;196m'
GOLD='\033[38;5;214m'
NC='\033[0m'
HEADER_LINE="${GRAY}────────────────────────────────────────────────────────────${NC}"
PHP_VERSION="8.3"

# --- UI HELPERS ---
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ██████╗ ██╗   ██╗██████╗ ████████╗
    ██╔══██╗██║   ██║██╔══██╗╚══██╔══╝
    ██████╔╝██║   ██║██████╔╝   ██║   
    ██╔═══╝ ██║   ██║██╔═══╝    ██║   
    ██║     ╚██████╔╝██║        ██║   
    ╚═╝      ╚═════╝ ╚═╝        ╚═╝   
EOF
    echo -e "         ${WHITE}PTERODACTYL NGINX CONFIGURATOR${NC}"
    echo -e "${HEADER_LINE}"
}

show_banner

# --- 1. Selection Menu ---
echo -e "\n  ${PURPLE}::${NC} ${WHITE}Select Configuration Mode${NC}"
echo -e "  ${GRAY}1.${NC} ${GREEN}SSL / HTTPS${NC} ${GRAY}(Secure manual/custom path)${NC}"
echo -e "  ${GRAY}2.${NC} ${RED}No SSL / HTTP${NC} ${GRAY}(Insecure plain text)${NC}"
echo -e "  ${GRAY}3.${NC} ${CYAN}Auto SSL / Certbot${NC} ${GRAY}(Let's Encrypt automated)${NC}"
echo -ne "\n  ${PURPLE}•${NC} ${WHITE}Select option [1-3]${NC}\n  ${GRAY}╰─>${NC} "
read OPTION

# ================= OPTION 3: AUTO SSL (CERTBOT) =================
if [ "$OPTION" == "3" ]; then
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ███████╗███████╗██████╗ ████████╗
    ██╔════╝██╔════╝██╔══██╗╚══██╔══╝
    ███████╗█████╗  ██████╔╝   ██║   
    ╚════██║██╔══╝  ██╔══██╗   ██║   
    ███████║███████╗██████╔╝   ██║   
    ╚══════╝╚══════╝╚══════╝    ╚═╝   
EOF
    echo -e "         ${WHITE}AUTO SSL GENERATOR (CERTBOT)${NC}"
    echo -e "${HEADER_LINE}"

    EMAIL="ssl$(tr -dc a-z0-9 </dev/urandom | head -c6)@b1yt.com"
    
    echo -ne "\n  ${PURPLE}•${NC} ${WHITE}Enter your Domain${NC} ${GRAY}[e.g., panel.example.com]${NC}\n  ${GRAY}╰─>${NC} "
    read DOMAIN

    echo -e "\n  ${YELLOW}[*] Updating system repositories...${NC}"
    apt update -y

    echo -e "  ${YELLOW}[*] Installing Certbot and Nginx plugin...${NC}"
    apt install certbot python3-certbot-nginx -y

    echo -e "\n  ${GREEN}[*] Requesting SSL Certificate...${NC}"
    certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL} --redirect

    if [ $? -eq 0 ]; then
        echo -e "\n${HEADER_LINE}"
        echo -e "  ${CYAN}🚀 DEPLOYMENT COMPLETE 🚀${NC}"
        echo -e "  ${GOLD}┌───────────────────────────────────────────┐${NC}"
        echo -e "  ${GOLD}│${NC}  ${GRAY}Status  :${NC} ${GREEN}✔ SSL Installed Successfully${NC}"
        echo -e "  ${GOLD}│${NC}  ${GRAY}Domain  :${NC} ${WHITE}https://${DOMAIN}${NC}"
        echo -e "  ${GOLD}└───────────────────────────────────────────┘${NC}"
        echo -e "\n  ${PURPLE}✨ Enjoy your secure B1YT Panel! ✨${NC}"
        echo -e "${HEADER_LINE}"
    else
        echo -e "\n  ${RED}[!] SSL Generation Failed.${NC}"
        echo -e "  ${YELLOW}Please check if your domain points to this server IP address.${NC}"
    fi
    exit 0
fi

# ================= OPTIONS 1 & 2 (STANDARD MANUAL SETUP) =================
echo -ne "\n  ${PURPLE}•${NC} ${WHITE}Enter your Domain${NC} ${GRAY}[e.g., panel.example.com]${NC}\n  ${GRAY}╰─>${NC} "
read DOMAIN

echo -e "\n  ${YELLOW}[*] Preparing environment...${NC}"
cd /var/www/pterodactyl || { echo -e "  ${RED}[!] Pterodactyl directory not found!${NC}"; exit 1; }

# Remove old configs
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/pterodactyl.conf

# ================= SSL CONFIGURATION =================
if [ "$OPTION" == "1" ]; then
    echo -e "\n  ${PURPLE}•${NC} ${WHITE}SSL Certificate Path Selection${NC}"
    echo -e "    ${GRAY}y${NC} = Let's Encrypt (Standard)"
    echo -e "    ${GRAY}n${NC} = Custom/Default (/etc/certs/panel)"
    echo -ne "  ${GRAY}╰─>${NC} "
    read -p "Use Let's Encrypt path? (y/n): " SSLTYPE

    if [ "$SSLTYPE" == "y" ]; then
        SETUP="letsencrypt/live/${DOMAIN}"
        FULLCHAIN="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
        PRIVKEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
    else
        SETUP="certs/panel"
        FULLCHAIN="/etc/certs/panel/fullchain.pem"
        PRIVKEY="/etc/certs/panel/privkey.pem"
    fi

    echo -e "  ${GREEN}[+] Setting APP_URL to HTTPS...${NC}"
    sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env

    # Create Nginx Config (SSL)
    cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    ssl_certificate ${FULLCHAIN};
    ssl_certificate_key ${PRIVKEY};

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# ================= NO SSL CONFIGURATION =================
elif [ "$OPTION" == "2" ]; then
    echo -e "  ${GREEN}[+] Setting APP_URL to HTTP...${NC}"
    sed -i "s|APP_URL=.*|APP_URL=http://${DOMAIN}|g" .env

    # Create Nginx Config (Non-SSL)
    cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

else
    echo -e "  ${RED}[!] Invalid Option selected. Exiting.${NC}"
    exit 1
fi

# --- Finalize ---
echo -e "\n  ${YELLOW}[*] Enabling configuration & testing Nginx...${NC}"
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
nginx -t

if [ $? -eq 0 ]; then
    systemctl restart nginx
    echo -e "${HEADER_LINE}"
    echo -e "\n  ${CYAN}🚀 DEPLOYMENT COMPLETE 🚀${NC}"
    echo -e "  ${GOLD}┌───────────────────────────────────────────┐${NC}"
    echo -e "  ${GOLD}│${NC}  ${GRAY}Status    :${NC} ${GREEN}✔ Setup Successfully Completed${NC}"
    echo -e "  ${GOLD}│${NC}  ${GRAY}Panel URL :${NC} ${WHITE}http$( [ "$OPTION" == "1" ] && echo "s" )://${DOMAIN}${NC}"
    echo -e "  ${GOLD}└───────────────────────────────────────────┘${NC}"
    echo -e "\n  ${PURPLE}✨ Enjoy your B1YT Pterodactyl Panel! ✨${NC}"
    echo -e "${HEADER_LINE}"
else
    echo -e "\n  ${RED}[!] Nginx configuration test failed. Please check errors above.${NC}"
fi
