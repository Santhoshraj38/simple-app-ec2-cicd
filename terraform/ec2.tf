# Lookup latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name             = var.key_name

  # Attach IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # Provisioning script (User Data)
  user_data = <<-EOF
              #!/bin/bash
              # Update packages
              apt-get update -y
              apt-get upgrade -y

              # Install Node.js, npm, git, and nginx
              curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
              apt-get install -y nodejs git nginx

              # Install PM2 globally to manage node application
              npm install -g pm2

              # Create app directory and set ownership
              mkdir -p /var/www/app
              chown -R ubuntu:ubuntu /var/www/app

              # Create a placeholder Express app
              cat <<'INNER_EOF' > /var/www/app/index.js
              const express = require('express');
              const app = express();
              app.get('/', (req, res) => {
                res.json({ 
                  status: "success", 
                  message: "Server is online! Awaiting deployment from GitHub Actions...", 
                  version: "0.1.0" 
                });
              });
              app.get('/health', (req, res) => { res.sendStatus(200); });
              app.listen(3000, () => { console.log('App running on port 3000'); });
              INNER_EOF

              # Install Express for placeholder app
              cd /var/www/app
              npm init -y
              npm install express
              chown -R ubuntu:ubuntu /var/www/app

              # Run the application using PM2 under ubuntu user
              runuser -l ubuntu -c 'cd /var/www/app && pm2 start index.js --name "node-app"'
              runuser -l ubuntu -c 'pm2 startup systemd | tail -n 1 | sudo bash'
              runuser -l ubuntu -c 'pm2 save'

              # Configure Nginx reverse proxy (Port 80 -> Port 3000)
              cat <<'INNER_EOF' > /etc/nginx/sites-available/default
              server {
                  listen 80 default_server;
                  listen [::]:80 default_server;

                  server_name _;

                  location / {
                      proxy_pass http://127.0.0.1:3000;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade $http_upgrade;
                      proxy_set_header Connection 'upgrade';
                      proxy_set_header Host $host;
                      proxy_cache_bypass $http_upgrade;
                  }
              }
              INNER_EOF

              # Restart Nginx to apply changes
              systemctl restart nginx
              EOF

  tags = {
    Name = "${var.environment}-web-server"
  }
}
