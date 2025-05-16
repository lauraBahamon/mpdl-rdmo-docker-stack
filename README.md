# mpdl-rdmo-docker-stack
docker configuration to develop and deploy rdmo

# 1. Dev instance deployment

## 1.0 Folder structure, env, settings file and certificate

### rdmorganiser/

Create rdmorganiser/. It contains at least rdmo-app/ with the configuration files for rdmo. Every complementary app directory is located as a sibling or child directory of rdmo-app/.

### env
```
# RDMO
SECRET_KEY = asdf
ALLOWED_HOSTS_STR = 'asdf ghjk qwer'
DEFAULT_URI_PREFIX = https://bla.com/terms/
STATIC_URL = /bla/

# DB
POSTGRES_PASSWORD = asdf
POSTGRES_USER = asdf

# TRAEFIK
DASHBOARD_USER = asdf
DASHBOARD_PASSWORD = hashed-password

# GITHUB
GITHUB_APP_NAME = asdf
GITHUB_APP_NAME_OAUTH_APP = asdf
GITHUB_CLIENT_ID = asdf
GITHUB_CLIENT_ID_OAUTH_APP = asdf
GITHUB_CLIENT_SECRET = asdf
GITHUB_CLIENT_SECRET_OAUTH_APP = asdf
```

### Save settings file (check Dockerfile* for file name or change it) in config_files/ and follow configuration steps -> https://rdmo.readthedocs.io/en/latest/configuration/index.html

### Save certificate in *nginx/ssl/certs/ and its key in *nginx/ssl/private/. Check Dockerfile* for file names or change them

## 1.1 Nginx test dev stack (local test for dev instance)
1.1.0 Checkout to dev branch and merge all changes to deploy

1.1.1 In dev stack, go to rdmo/ and create production front-end files
```shell  (as root user of **local dev web container** -> docker exec -it --user root {container id} /bin/bash)
npm install
npm run build:prod
```

1.1.2 In dev stack, go to rdmo/ and {plugin_name}/ and create whl files, then echo file path 
```(shell as container user of **local dev web container**)
python3 -m build --wheel --outdir wheels
RDMO_WHEEL=$(ls ./wheels/*.whl | sort -V | tail -n 1) && echo "$RDMO_WHEEL"
```

1.1.3 Deploy
```
RDMO_WHEEL from last step
RDMO_GITHUB_WHEEL from last step
RDMO_GITLAB_WHEEL from last step
docker-compose -p rdmo-nginx-test-stack -f docker-compose.nginx.test.dev.yml build --build-arg RDMO_WHEEL=RDMO_WHEEL --build-arg RDMO_GITHUB_WHEEL=RDMO_GITHUB_WHEEL --build-arg RDMO_GITLAB_WHEEL=RDMO_GITLAB_WHEEL
docker-compose -p rdmo-nginx-test-stack -f docker-compose.nginx.test.dev.yml up
docker-compose -p rdmo-nginx-test-stack -f docker-compose.nginx.test.dev.yml down -v
```

1.1.4 !!!! Discard changes of js app !!!!

1.1.5 Create super user
```(shell as container user of web container - first time)
python manage.py createsuperuser
```

## 1.2 Nginx dev stack (dev instance)
Follow steps as in 1.1 but use these docker commands instead of those in 1.1.3

```
docker context create rdmo-dev-instance (first time)
docker context use rdmo-dev-instance 
docker-compose -p rdmo-nginx-stack -f docker-compose.nginx.dev.yml build --build-arg RDMO_WHEEL=RDMO_WHEEL --build-arg RDMO_GITHUB_WHEEL=RDMO_GITHUB_WHEEL --build-arg RDMO_GITLAB_WHEEL=RDMO_GITLAB_WHEEL
docker-compose -p rdmo-nginx-stack -f docker-compose.nginx.dev.yml up -d
docker-compose -p rdmo-nginx-stack -f docker-compose.nginx.dev.yml down -v
```

## 1.3 Traefik Production (dev instance -> not working yet - local test works (docker-compose.traefik.test.dev.yml))
Follow steps as in 1.1 but use these docker commands instead of those in 1.1.3

```
docker context create rdmo-dev-instance (first time)
docker context use rdmo-dev-instance 
docker-compose -p rdmo-traefik-stack -f docker-compose.traefik.dev.yml up --build
docker-compose -p rdmo-traefik-stack -f docker-compose.traefik.dev.yml down -v
```

# 2. Postgres DB backup and restoration

## dump
```(shell as container user of db container)
mkdir /var/lib/postgresql/backup
```

```(shell in server)
# filename= ${POSTGRES_USER}_$(date +%Y%m%d)
docker exec -it <id> sh -c 'pg_dump -U ${POSTGRES_USER} -Fc ${POSTGRES_USER} > /var/lib/postgresql/backup/<filename>.dump'
mkdir backup_pgdata
docker cp <id>:/var/lib/postgresql/backup/<filename>.dump ./backup_pgdata/<filename>.dump
```

## restore
```(shell as container user of db container)
mkdir /var/lib/postgresql/backup
```

```(shell in server)
# filename= ${POSTGRES_USER}_$(date +%Y%m%d)
docker cp ./backup_pgdata/<filename>.dump <id>:/var/lib/postgresql/backup/<filename>.dump
docker exec -it <id> sh -c 'dropdb -U ${POSTGRES_USER} ${POSTGRES_USER}'
docker exec -it <id> sh -c 'createdb -U ${POSTGRES_USER} ${POSTGRES_USER}'
docker exec -it <id> sh -c 'pg_restore -U ${POSTGRES_USER} -d ${POSTGRES_USER} /var/lib/postgresql/backup/<filename>.dump'
```

# 3. Local development

## 3.0 Folder structure and env

### rdmorganiser/

Create rdmorganiser/. It contains at least rdmo-app/ with the configuration files for rdmo. Every complementary app directory is located as a sibling or child directory of rdmo-app/.

### local_dev.env
```
# RDMO
SECRET_KEY = asdf
DEFAULT_URI_PREFIX = https://bla.com/terms/

# DB
POSTGRES_PASSWORD = asdf
POSTGRES_USER = asdf

# TRAEFIK
DASHBOARD_USER = asdf
DASHBOARD_PASSWORD = hashed-password

# GITHUB
GITHUB_APP_NAME = asdf
GITHUB_APP_NAME_OAUTH_APP = asdf
GITHUB_CLIENT_ID = asdf
GITHUB_CLIENT_ID_OAUTH_APP = asdf
GITHUB_CLIENT_SECRET = asdf
GITHUB_CLIENT_SECRET_OAUTH_APP = asdf
```



## 3.1 Start stack
```
docker-compose -p rdmo-local-dev-stack -f docker-compose.local-dev.yml up --build
docker-compose -p rdmo-local-dev-stack -f docker-compose.local-dev.yml down -v
```

## 3.2 RDMO (in editable mode)

### After container is built and started

Follow basic setup docs -> https://rdmo.readthedocs.io/en/latest/installation/setup.html

Go to rdmo-app/ and:

```shell (as container user)
>> pip install -e ../"rdmo[allauth,postgres]"
>> python3 manage.py download_vendor_files
>> python3 manage.py migrate
>> python3 manage.py createsuperuser
```
 
Then, follow detailed setup docs -> https://rdmo.readthedocs.io/en/latest/development/setup.html#install-prerequisites

### Add pandoc with pypandoc installer
https://pypi.org/project/pypandoc/

Go to rdmo-app/, open the interactive shell and install pandoc:

```shell (as container user)
>> python3 manage.py shell
>> from pypandoc.pandoc_download import download_pandoc
>> download_pandoc() # The default install location is included in the search path for pandoc, so you don't need to add it to the PATH
```

### Add node dependencies and build front-end

Go to rdmo/, install dependencies and build frontend:
```shell  (as root user -> docker exec -it --user root {container id} /bin/bash)
npm install    # to install the many, many javascript dependencies
npm run watch  # to build the front-end and rebuild it when changing the source
```

### Start dev server:
Go to rdmo-app/ and run:
```shell (as container user)
>> python3 manage.py runserver 0.0.0.0:8000
```

## 3.3 RDMO-PLUGINS (in editable mode)

Follow setup docs -> https://rdmo.readthedocs.io/en/latest/development/setup.html#setup-plugins

### Add the plugins to rdmo-app

Go to rdmo-app/ and install them:

```shell (as container user)
>> pip install -e ../rdmo-plugins-*
```

Follow Plugin docs -> https://rdmo.readthedocs.io/en/latest/plugins/index.html

Then update settings in rdmo-app/config/settings/local.py -> https://rdmo.readthedocs.io/en/latest/plugins/index.html


### RDMO-PLUGINS-GITHUB

Follow setup docs -> https://github.com/rdmorganiser/rdmo-plugins-github

Plus:

- add the github plugin to the PROJECT_IMPORTS_LIST in rdmo-app/config/settings/local.py, \
otherwise it won't show on the side bar:
```
PROJECT_IMPORTS_LIST += ['github']
```

# 4. RDMO-CATALOGS

https://rdmo.readthedocs.io/en/latest/management/user-interface.html

# 5. Custom Translations

Follow internationalisation docs -> https://rdmo.readthedocs.io/en/latest/development/i18n.html

- Create locale/ directory on the app's top level (the folder added to INSTALLED_APPS)

- Create the .po files for the translations with 
```shell (in app's top level) 
django-admin makemessages -l de 
```

- Compile .mo files
```shell (in app's top level) 
django-admin compilemessages -l de
```

# 6. Secure Copy with PuTTY
```(local shell (eingabeaufforderung))
src-path-to-file -> file-name for files in root directory, /directory-name/file-name for files in subdirectories
dest-path-to-file -> directory-name\file-name  mind back slashes for Windows paths!!!
pscp -load {putty session name} bahamon@{server}:{src-path-to-file} {dest-path-to-file}
```

