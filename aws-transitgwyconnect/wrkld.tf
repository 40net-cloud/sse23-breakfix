data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_network_interface" "front_az1" {
    subnet_id = aws_subnet.csprivatesubnetaz1.id
    private_ips = ["10.200.200.200"]
    security_groups = [aws_security_group.allow_all_vpc1.id]
}
resource "aws_instance" "front_az1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.keyname

  network_interface {
      network_interface_id = aws_network_interface.front_az1.id
      device_index = 0
  }

  tags = {
    Name     = "front-az1"
    az       = var.az1
  }

  user_data = <<-EOL
#!/bin/bash
apt update
apt install nginx -y
echo "server { \
listen 80; \
proxy_connect_timeout 7; \
location / { \
  proxy_pass http://10.201.201.10; \
}\
}" > /etc/nginx/sites-available/proxy
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/proxy /etc/nginx/sites-enabled/
systemctl restart nginx
EOL
}

resource "aws_network_interface" "back_az1" {
    subnet_id = aws_subnet.cs2privatesubnetaz1.id
    private_ips = ["10.201.201.10"]
}
resource "aws_instance" "back_az1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.keyname

  network_interface {
      network_interface_id = aws_network_interface.back_az1.id
      device_index = 0
  }

  tags = {
    Name     = "back-az1"
    az       = var.az1
  }

  user_data = <<-EOL
#!/bin/bash
apt update
apt install nginx -y
cd /var/www/html
wget https://github.com/bartekmo/play2/raw/master/web-itworks.tar.gz
tar zxf web-itworks.tar.gz
wget -O eicar.com "https://www.eicar.com/download/eicar-com/?wpdmdl=8840&refresh=647458a2195dd1685346466"
EOL
}