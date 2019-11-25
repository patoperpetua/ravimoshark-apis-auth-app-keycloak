# RAVIMOSHARK LOCAL API AUTH

## HOW TO RUN

Just run **./scripts/run.sh** and access keycloak server in browser [http://localhost:9090](http://localhost:9090). User and password are *admin*.

You can pass port number as first parameter of run script, like following:

```bash
./scripts/run.sh ${OTHER_PORT_THAN_9090}
```

## SETUP

The easiest way to interact with keycloak is throw its cli tool. It is provided inside keycloak docker image.

```bash
docker run --name=kcadm.sh --network="host" --rm -it \
  --entrypoint /bin/bash jboss/keycloak
```

Inside the container create the following alias:

```bash
alias kcadm.sh=/opt/jboss/keycloak/bin/kcadm.sh
```

Login to the server:

```bash
kcadm.sh config credentials \
  --server http://localhost:8080/auth \
  --realm master \
  --user keycloak\_admin
```

Then you can execute the setup script contained in *scripts* folder:

```bash
./scripts/keycloak_setup.sh
```

### TESTING SETUP

You can ho ahead and import a test environment configuration directly by using the file under the path *conf/realm-test*.

After that, create a user using *mockuser* as username and password. Be aware that password must not be temporal and user must be enabled.

Finally, get Access token by executing:

```bash
curl -s -X POST \
-H 'Content-Type: application/x-www-form-urlencoded' \
-d 'username=mockuser&grant_type=password&client_id=frontend-office&password=mockuser' \
http://localhost:9090/auth/realms/SAV/protocol/openid-connect/token
```

## DOCS

- [KeyCloak Docker Compose](https://github.com/keycloak/keycloak-containers/tree/master/docker-compose-examples).
- [KeyCloak Docker Hub](https://hub.docker.com/r/jboss/keycloak/dockerfile).
- [KeyCloak Setup Tutorial](https://blog.jdriven.com/2018/10/securing-spring-microservices-with-keycloak-part-1/)

## TODO

- [ ] Finish scripts.
- [ ] Test scripts.
- [ ] Added ci/cd.
- [ ] Export a mssql volume folder.

----------------------
© [Singleton SD](http://singletonsd.com), France, 2019.
