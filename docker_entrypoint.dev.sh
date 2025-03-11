#!/bin/bash

# Vendor files
if [ -z "$( ls -A '/home/rdmo/rdmo-app/vendor' )" ]; then
   echo "Download third party vendor files"
   python manage.py download_vendor_files
else
   echo "Third party vendor files already exist"
fi
# echo "Download third party vendor files"
# python manage.py download_vendor_files

# Static assets
echo "Collect static assets"
python manage.py collectstatic --clear --no-input

# Apply database migrations
echo "Apply database migrations"
python manage.py migrate

# Start server
echo "Starting server"
gunicorn config.wsgi:application --bind 0.0.0.0:8000