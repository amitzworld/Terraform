#! /bin/bash
sudo yum install -y httpd
sudo systemctl restart httpd
echo "<h1>The page you're looking for is under construction!!</h1>" | sudo tee /var/www/html/index.html
