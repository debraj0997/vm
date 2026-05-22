#!/bin/bash
# ==================================================
# PTERODACTYL PANEL AUTO INSTALLER
# Ubuntu / Debian • PHP 8.3 Fixed • 502 Fixed
# ==================================================

set -e

# ---------------- UI THEME ----------------
C_RESET="\e[0m"
C_RED="\e[1;31m"
C_GREEN="\e[1;32m"
C_YELLOW="\e[1;33m"
C_BLUE="\e[1;34m"
C_PURPLE="\e[1;35m"
C_CYAN="\e[1;36m"
C_WHITE="\e[1;37m"
C_GRAY="\e[1;90m"

line(){ echo -e "${C_GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"; }
step(){ echo -e "${C_BLUE}➜ $1${C_RESET}"; }
ok(){ echo -e "${C_GREEN}✔ $1${C_RESET}"; }
warn(){ echo -e "${C_YELLOW}⚠ $1${C_RESET}"; }

banner(){
clear
echo -e "${C_CYAN}"
cat << "EOF"
██████╗ ███████╗████████╗███████╗██████╗  ██████╗
██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔═══██╗
██████╔╝█████╗     ██║   █████╗  ██████╔╝██║   ██║
██╔═══╝ ██╔══╝     ██║   ██╔══╝  ██╔══██╗██║   ██║
██║     ███████╗   ██║   ███████╗██║  ██║╚██████╔╝
╚═╝     ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝

        PTERODACTYL PANEL INSTALLER
EOF
echo -e "${C_RESET}"
line
echo -e "${C_GREEN}⚡ Fast • Stable • Production Ready${C_RESET}"
echo -e "${C_PURPLE}🧠 B1 — 2026 Installer${C_RESET}"
line
}

banner

read -p "🌐 Enter Domain (panel.example.com): " DOMAIN

PHP_VERSION="8.3"

# ---------------- UPDATE ----------------
step "Updating packages..."
apt update -y

# ---------------- DEPENDENCIES ----------------
step "Installing dependencies..."
apt install -y software-properties-common curl apt-transport-https \
ca-certificates gnupg unzip git tar sudo lsb-release redis-server \
nginx mariadb-server cron

# ---------------- PHP REPO ----------------
OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "ubuntu" ]]; then
    add-apt-repository -y ppa:ondrej/php
elif [[ "$OS" == "debian" ]]; then
    curl -fsSL https://packages.sury.org/php/apt.gpg | \
    gpg --dearmor -o /usr/share/keyrings/sury-php.gpg

    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] \
    https://packages.sury.org/php/ $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/sury-php.list
fi

apt update -y

# ---------------- INSTALL PHP ----------------
step "Installing PHP ${PHP_VERSION}..."

apt install -y \
php${PHP_VERSION} \
php${PHP_VERSION}-cli \
php${PHP_VERSION}-fpm \
php${PHP_VERSION}-common \
php${PHP_VERSION}-mysql \
php${PHP_VERSION}-mbstring \
php${PHP_VERSION}-xml \
php${PHP_VERSION}-curl \
php${PHP_VERSION}-zip \
php${PHP_VERSION}-gd \
php${PHP_VERSION}-bcmath \
php${PHP_VERSION}-intl \
php${PHP_VERSION}-tokenizer

# ---------------- COMPOSER ----------------
step "Installing Composer..."

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# ---------------- DOWNLOAD PANEL ----------------
step "Downloading Pterodactyl Panel..."

mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

curl -Lo panel.tar.gz \
https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz

tar -xzf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# ---------------- DATABASE ----------------
step "Creating database..."

DB_NAME="panel"
DB_USER="pterodactyl"
DB_PASS=$(openssl rand -base64 12)

mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

ok "Database ready"

# ---------------- ENV ----------------
step "Configuring environment..."

cp .env.example .env

sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env

echo "APP_ENVIRONMENT_ONLY=false" >> .env

# ---------------- COMPOSER INSTALL ----------------
step "Installing panel dependencies..."

COMPOSER_ALLOW_SUPERUSER=1 composer install \
--no-dev \
--optimize-autoloader

# ---------------- ARTISAN ----------------
step "Generating app key..."

php artisan key:generate --force

step "Running migrations..."

php artisan migrate --seed --force

# ---------------- PERMISSIONS ----------------
step "Setting permissions..."

chown -R www-data:www-data /var/www/pterodactyl

# ---------------- CRON ----------------
step "Configuring cron..."

systemctl enable --now cron

(crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -

# ---------------- SSL ----------------
step "Generating SSL..."

mkdir -p /etc/certs/panel
cd /etc/certs/panel

openssl req -x509 -nodes -days 3650 \
-newkey rsa:4096 \
-keyout privkey.pem \
-out fullchain.pem \
-subj "/C=US/ST=State/L=City/O=Pterodactyl/CN=${DOMAIN}"

# ---------------- NGINX ----------------
step "Creating Nginx config..."

cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    ssl_certificate /etc/certs/panel/fullchain.pem;
    ssl_certificate_key /etc/certs/panel/privkey.pem;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;

        fastcgi_pass unix:/run/php/php8.3-fpm.sock;

        fastcgi_index index.php;
        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default

ln -sf /etc/nginx/sites-available/pterodactyl.conf \
/etc/nginx/sites-enabled/pterodactyl.conf

# ---------------- FIX 502 ----------------
step "Fixing PHP socket..."

sed -i 's|php-fpm.sock|php8.3-fpm.sock|g' /etc/nginx/sites-enabled/* || true

# ---------------- SERVICES ----------------
step "Restarting services..."

systemctl enable php${PHP_VERSION}-fpm
systemctl enable nginx
systemctl enable mariadb
systemctl enable redis-server

systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx
systemctl restart mariadb
systemctl restart redis-server

# ---------------- QUEUE ----------------
step "Creating queue worker..."

cat > /etc/systemd/system/pteroq.service <<EOF
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now pteroq.service

# ---------------- TEST ----------------
nginx -t

# ---------------- ADMIN ----------------
clear
step "Create Admin User"

cd /var/www/pterodactyl
php artisan p:user:make

# ---------------- DONE ----------------
clear
line
echo -e "${C_GREEN}🎉 INSTALLATION COMPLETED${C_RESET}"
line

echo -e "${C_CYAN}🌐 PANEL URL:${C_RESET} https://${DOMAIN}"
echo -e "${C_CYAN}🗄 DATABASE:${C_RESET} ${DB_NAME}"
echo -e "${C_CYAN}👤 DB USER:${C_RESET} ${DB_USER}"
echo -e "${C_CYAN}🔑 DB PASS:${C_RESET} ${DB_PASS}"

line

echo -e "${C_GREEN}✔ PHP SOCKET FIXED${C_RESET}"
echo -e "${C_GREEN}✔ NGINX ONLINE${C_RESET}"
echo -e "${C_GREEN}✔ PANEL READY${C_RESET}"

lineecho -e "${C_GREEN}⚡ Fast • Stable • Production Ready${C_RESET}"
echo -e "${C_PURPLE}🧠 B1 — 2026 Installer${C_RESET}"
line
}

# ---------------- START ----------------
banner
read -p "🌐 Enter domain (panel.example.com): " DOMAIN

# --- Dependencies ---
apt update && apt install -y curl apt-transport-https ca-certificates gnupg unzip git tar sudo lsb-release

# Detect OS
OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "ubuntu" ]]; then
    echo "✅ Detected Ubuntu. Adding PPA for PHP..."
    apt install -y software-properties-common
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
elif [[ "$OS" == "debian" ]]; then
    echo "✅ Detected Debian. Skipping PPA and adding PHP repo manually..."
    # Add SURY PHP repo for Debian
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/sury-php.list
fi

# Add Redis GPG key and repo
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

apt update

# --- Install PHP + extensions ---
apt install -y php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom} mariadb-server nginx redis-server

# --- Install Composer ---
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# --- Download Pterodactyl Panel ---
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# --- MariaDB Setup ---
DB_NAME=panel
DB_USER=pterodactyl
DB_PASS=yourPassword
mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"
mariadb -e "CREATE DATABASE ${DB_NAME};"
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;"
mariadb -e "FLUSH PRIVILEGES;"

# --- .env Setup ---
if [ ! -f ".env.example" ]; then
    curl -Lo .env.example https://raw.githubusercontent.com/pterodactyl/panel/develop/.env.example
fi
cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env
if ! grep -q "^APP_ENVIRONMENT_ONLY=" .env; then
    echo "APP_ENVIRONMENT_ONLY=false" >> .env
fi

# --- Install PHP dependencies ---
echo "✅ Installing PHP dependencies..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

# --- Generate Application Key ---
echo "✅ Generating application key..."
php artisan key:generate --force

# --- Run Migrations ---
php artisan migrate --seed --force

# --- Permissions ---
chown -R www-data:www-data /var/www/pterodactyl/*
apt install -y cron
systemctl enable --now cron
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -
# --- Nginx Setup ---
mkdir -p /etc/certs/panel
cd /etc/certs/panel
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate" \
-keyout privkey.pem -out fullchain.pem

tee /etc/nginx/sites-available/pterodactyl.conf > /dev/null << EOF
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

    ssl_certificate /etc/certs/panel/fullchain.pem;
    ssl_certificate_key /etc/certs/panel/privkey.pem;

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
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf || true
nginx -t && systemctl restart nginx
ok "Nginx online"

# --- Queue Worker ---
tee /etc/systemd/system/pteroq.service > /dev/null << 'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now redis-server
systemctl enable --now pteroq.service
ok "Queue running"
clear
step "Create admin user"
# --- Admin User ---
cd /var/www/pterodactyl
sed -i '/^APP_ENVIRONMENT_ONLY=/d' .env
echo "APP_ENVIRONMENT_ONLY=false" >> .env
php artisan p:user:make

# ---------------- DONE ----------------
line
echo -e "${C_GREEN}🎉 INSTALLATION COMPLETED SUCCESSFULLY${C_RESET}"
line
echo -e "${C_CYAN}🌐 Panel URL    : ${C_WHITE}https://${DOMAIN}${C_RESET}"
echo -e "${C_CYAN}🗄 DB User      : ${C_WHITE}${DB_USER}${C_RESET}"
echo -e "${C_CYAN}🔑 DB Password  : ${C_WHITE}${DB_PASS}${C_RESET}"
line
echo -e "${C_PURPLE}🚀 Panel live. Control the servers.${C_RESET}"
line
