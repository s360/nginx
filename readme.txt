# Setup Instruction

Please follow the following steps:

* Install Nginx from repository.
~~~~
sudo -s
nginx=stable # use nginx=development for latest development version
echo "deb http://ppa.launchpad.net/nginx/$nginx/ubuntu lucid main" > /etc/apt/sources.list.d/nginx-$nginx-lucid.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
apt-get update
apt-get install nginx
~~~~

* Create /var/log/nginx/domains
~~~~
mkdir -p /var/log/nginx/domains
~~~~

* Remove /etc/nginx and replace it with this repository.

* Update snippets/nginx-realip.conf if the server sits behind a proxy/load balancer. If it doesn’t then comment out the include line in nginx.conf

* IF NEEDED, Update snippets/nginx-cache.conf with appropriate FastCGI cache config, you can set multiple zones (per domain) if needed. IF none of the sites are using FastCGI cache, then comment out the include line in nginx.conf.

* Update snippets/locations-wellknown.conf for LetsEncrypt support

* Copy sites-available/example.com to the domain name you want to serve, this would be referred as domain_config.

* Edit domain_config:
  * replace all occurrences of example.com with the domain name.
  * change root directive to the domain public_html root.
  * change set $phpsock directive to point to the php-fpm socket.
  * Update the dhparam and ssl certificate. You can generate it as follow:
  ~~~~
  # DHParams creation:
  openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
  # SSL Certificate self-signed creation:
  openssl genrsa -out www.example.com.key 2048
  openssl req -new -x509 -key www.example.com.key -out www.example.com.cert -days 3650 -subj /CN=www.example.com 
  ~~~~
  * By default, the domain_config is going to redirect all http request to https, and then serve the site using FastCGI in memory cache. For regular Wordpress setup, this won’t need adjustment.

* Test Nginx
~~~~
Nginx -t
~~~~

* If there are any error, troubleshoot the error, when all clear, restart Nginx
~~~~
Systemctl restart nginx
~~~~

* Setup a cronjob to periodically, update blockips.conf and blacklist.conf, after update, always reload nginx config with this command:
~~~~
systemctl reload nginx
~~~~
