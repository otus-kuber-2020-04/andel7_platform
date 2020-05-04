FROM bitnami/nginx:1.18.0
ADD ./app/homework.html /opt/bitnami/nginx/html
ENV    NGINX_ENABLE_CUSTOM_PORTS="yes" 
ENV    NGINX_HTTP_PORT_NUMBER="8000" 

EXPOSE 8000
