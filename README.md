# RAVIMOSHARK AUTHENTIFICATION SERVER

## HOW TO RUN

### LOCAL

Just run **./scripts/server_run_local.sh** and access keycloak server in browser [http://localhost:9090](http://localhost:9090). User and password are *admin*.

You can change the http port and the port of the mssql server by editing the file *.env*, the parameter names are:

```bash
PORT_KEYCLOAK=
PORT_DB=
```

After running, you'll have a keycloak server fully configurated to connect to ravimo frontends and APIs.

#### DEBUG / DEVELOPMENT

If you need to have access to the database server (port to connect to and volume data), you can pass any argument to the run server script and it will attach the database server port to localhost and attach database volumes.

### PRODUCTION

If you want to interact with a production server or configurate a new production server, you have to create a new file in the root folder, called *.keycloak.env*. The following variables must be set:

```bash
KEYCLOAK_SERVER_ADDR=
KEYCLOAK_SERVER_USER=
KEYCLOAK_SERVER_PASSWORD=
KEYCLOAK_SERVER_REALM=
KEYCLOAK_SERVER_CONF=#use the latests version of the file under /conf/realms folder.
```

## SETUP

The easiest way to interact with keycloak is throw its cli tool. It is provided inside keycloak docker image.

Go and execute an interactive shell using the keycloak container:

```bash
docker exec -it RAVIMO_AUTH_KC /bin/bash
```

Inside the container create the following alias:

```bash
alias kcadm.sh=/opt/jboss/keycloak/bin/kcadm.sh
```

Login to the server by executing the script under *./opt/scripts/keycloak_login.sh* or use the following:

```bash
kcadm.sh config credentials \
  --server http://localhost:8080/auth \
  --realm master \
  --user admin
```

Then you can execute the setup script contained in *scripts* folder:

```bash
./opt/scripts/keycloak_setup.sh #Setup a unconfigurated container.
./opt/scripts/keycloak_export.sh #Export the current configuration to a json file under /volumes/exportations
./opt/scripts/keycloak_import.sh #Import a realm defined in a json file under /conf/realms/ (Setup the KEYCLOAK_SERVER_CONF with the desired name)
```

## VERSION GUIDE

Once you have a new keycloak configuration, you need to export the configuration in a json file and also create a backup of the database from the running db container.

To do so, just run the following scripts:

```bash
./scripts/keycloak_export.sh
./scripts/mssql/mssql_export.sh
```

After, you will have two new files one file called *keycloak.bak* and the other *realm-SAV-###.json*, both under *volumes/exportations* path. Copy the first file and put it inside *conf/db/mssql* and the other one in *conf/realms*. Place change their names to add the version number, as the other version files are named. Finally, edit the REALM_VERSION variable inside *.env* file with the new value.

## DATABASE USERS

In order to improve security, there is an sql script in the path *scripts/mssql/mssql_create_users.sql* which explains and contains basic statement of how to create users and asing to them specific roles.

## GIT HOOK

You can setup shellcheck to be run before a commit. To do that just execute the following script under your git repository:

```bash
curl -s https://singletonsd.gitlab.io/scripts/common/latest/bash_script_common_hook_installer.sh | bash /dev/stdin
```

## DOCS

- [KeyCloak Docker Compose](https://github.com/keycloak/keycloak-containers/tree/master/docker-compose-examples).
- [KeyCloak Docker Hub](https://hub.docker.com/r/jboss/keycloak/dockerfile).
- [KeyCloak Setup Tutorial](https://blog.jdriven.com/2018/10/securing-spring-microservices-with-keycloak-part-1/).
- [KeyCloak CLI Documentation](https://github.com/keycloak/keycloak-documentation/blob/master/server_admin/topics/admin-cli.adoc).

## TODO

- [X] Finish scripts.
- [X] Add git-hook documentation to run pre-commit scripts.
- [X] Add documentation about creating a production .keycloak.env file.
- [X] Add script to setup configuration to an external server.
- [X] Test scripts.
- [X] Docker images and script.
- [ ] Add Azure scripts.
- [X] Add ci/cd.
- [X] Script to persist containers data into a host folder.

- [ ] Export a mssql volume folder.

----------------------
© [Singleton SD](http://singletonsd.com), France, 2019.
