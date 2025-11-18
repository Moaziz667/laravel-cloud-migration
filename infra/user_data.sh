#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install required packages
apt-get install -y \
    docker.io \
    docker-compose \
    curl \
    wget \
    git \
    mysql-client

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create application directory
mkdir -p /home/ubuntu/laravel-app
chown ubuntu:ubuntu /home/ubuntu/laravel-app

# Create environment file with database connection
cat > /home/ubuntu/.env << EOF
# Database Configuration from RDS
DB_CONNECTION=mysql
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_DATABASE=${db_name}
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}

# Application Configuration
APP_NAME=LaravelApp
APP_ENV=production
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=false
APP_URL=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Cache and Session
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Other configurations
LOG_CHANNEL=stack
LOG_LEVEL=debug
EOF

# Set proper permissions
chown ubuntu:ubuntu /home/ubuntu/.env
chmod 600 /home/ubuntu/.env

# Wait for RDS to be available before testing connection
sleep 60

# Test database connection
mysql -h ${db_host} -P ${db_port} -u ${db_username} -p${db_password} -e "SHOW DATABASES;" && echo "Database connection successful" || echo "Database connection test failed"

# Create a simple script to check database connectivity
cat > /home/ubuntu/check_db.sh << 'EOF'
#!/bin/bash
source /home/ubuntu/.env
echo "Testing database connection..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -e "SELECT 1;" && echo "Database connection successful" || echo "Database connection failed"
EOF

chmod +x /home/ubuntu/check_db.sh
chown ubuntu:ubuntu /home/ubuntu/check_db.sh

# Create a systemd service to ensure Docker Compose starts on boot
cat > /etc/systemd/system/laravel-app.service << EOF
[Unit]
Description=Laravel Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

systemctl enable laravel-app.service

# Log completion
echo "EC2 instance configuration completed at $(date)" >> /var/log/user-data.log
echo "Database Host: ${db_host}" >> /var/log/user-data.log
echo "Database Port: ${db_port}" >> /var/log/user-data.log
echo "Database Name: ${db_name}" >> /var/log/user-data.log

# Create a status file to indicate setup is complete
touch /home/ubuntu/setup-complete
chown ubuntu:ubuntu /home/ubuntu/setup-complete
