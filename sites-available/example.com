### This example is for a HTTPS/SSL included site.
### Visitors will be redirected to https.

server {
  listen 80;
  listen [::]:80;
  server_name www.example.com example.com;

  # root /home/example/domains/example.com/public_html;
  # index index.php index.html;
  # set $phpsock unix:/run/php/examplecom-active.sock;

  ### Cross Origin Request Support (CORS).
  ### By default we let the application handle CORS, this can be handled by nginx by
  ### enabling it below.
  # set $cors '';
  ### You can specify to allow cross origin requests from specific domains, with if clause below
  ### or just uncomment the set $cors 'true'; line.
  # if ($http_origin ~ '^https?://(localhost|www\.yourdomain\.com|www\.yourotherdomain\.com)') {
  #        set $cors 'true';
  # }
  include snippets/client-security.conf;

  ## Start: Logs ##
  # access_log /var/log/nginx/domains/example.com.log main;
  # access_log /var/log/nginx/domains/example.com.bytes bytes;
  # error_log /var/log/nginx/domains/example.com.error.log;
  access_log off;
  error_log off;
  ## End: Logs ##

  # include snippets/paranoid.conf;

  include snippets/domain-redirect.conf;
  # include snippets/domain-cache.conf;
  # include snippets/domain-nocache.conf;

  # set $cache_plugin cache-enabler;
  # include snippets/domain-wpcache.conf;

  # include snippets/locations-wp.conf;

  # include snippets/locations-wellknown.conf;
  # include snippets/locations.conf;
  # include snippets/locations-status.conf;
  # include snippets/webaps.conf;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name www.example.com example.com;

  # root /home/example/domains/example.com/private_html;
  root /home/doyon/domains/example.com/public_html;
  index index.php index.html;
  set $phpsock unix:/run/php/examplecom-active.sock;

  ### Cross Origin Request Support (CORS).
  ### By default we let the application handle CORS, this can be handled by nginx by
  ### enabling it below.
  set $cors '';
  ### You can specify to allow cross origin requests from specific domains, with if clause below
  ### or just uncomment the set $cors 'true'; line.
  # if ($http_origin ~ '^https?://(localhost|www\.yourdomain\.com|www\.yourotherdomain\.com)') {
  #        set $cors 'true';
  # }
  include snippets/client-security.conf;

  ## Start: Logs ##
  access_log /var/log/nginx/domains/example.com.log main;
  access_log /var/log/nginx/domains/example.com.bytes bytes;
  error_log /var/log/nginx/domains/example.com.error.log;
  ## End: Logs ##

  ## Start: SSL Config ##
  ssl on;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_stapling on;
  ssl_stapling_verify on;
  resolver 8.8.8.8 8.8.4.4 valid=300s;
  resolver_timeout 10s;
  add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; ";

  ssl_dhparam ssl/dhparam.pem;
  ssl_certificate ssl/certs/not-available.crt;
  ssl_certificate_key ssl/certs/not-available.key;
  # ssl_certificate /etc/letsencrypt/live/www.example.com/fullchain.pem;
  # ssl_certificate_key /etc/letsencrypt/live/www.example.com/privkey.pem;
  ## End: SSL Config ##

  include snippets/paranoid.conf;

  include snippets/domain-cache.conf;
  # include snippets/domain-nocache.conf;

  # set $cache_plugin cache-enabler;
  # include snippets/domain-wpcache.conf;

  include snippets/locations-wp.conf;

  # include snippets/locations-wellknown.conf;
  include snippets/locations.conf;
  include snippets/locations-status.conf;
  # include snippets/webaps.conf;
}
