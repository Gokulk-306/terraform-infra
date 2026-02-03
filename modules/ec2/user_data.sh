#!/bin/bash
# Update system
yum update -y

# Install nginx
yum install -y nginx

# Enable and start nginx
systemctl enable nginx
systemctl start nginx

# Create custom nginx webpage
cat <<EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>My Nginx Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #0f172a;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        h1 {
            font-size: 40px;
            letter-spacing: 1px;
        }
    </style>
</head>
<body>
    <h1>This is my nginx webpage</h1>
</body>
</html>
EOF

# Restart nginx to apply changes
systemctl restart nginx

# Ensure nginx is running
systemctl status nginx


