FROM nginx:1.27

RUN rm /etc/nginx/conf.d/default.conf

COPY ./ssl/certs/nginx-selfsigned.crt /etc/ssl/certs/nginx-selfsigned.crt
COPY ./ssl/private/nginx-selfsigned.key /etc/ssl/private/nginx-selfsigned.key
COPY nginx.conf /etc/nginx/conf.d