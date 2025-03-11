FROM nginx:1.27

RUN rm /etc/nginx/conf.d/default.conf

COPY ./ssl/certs/dev-rdmo.crt /etc/ssl/certs/dev-rdmo.crt
COPY ./ssl/private/dev-rdmo.key /etc/ssl/private/dev-rdmo.key
COPY nginx.conf /etc/nginx/conf.d