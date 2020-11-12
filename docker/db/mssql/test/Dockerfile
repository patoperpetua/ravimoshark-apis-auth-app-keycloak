ARG BASE_IMAGE_TAG=2017-latest-ubuntu

FROM mcr.microsoft.com/mssql/server:${BASE_IMAGE_TAG}

ARG REALM_VERSION=0.0.1

LABEL mainteiner="Patricio Perpetua <patoperpetua@singletonsd.com>" \
    name="ravimosharksas/apis/auth/db/mssql-test" \
    architecture="x86_64" \
    vendor="SINGLETON_SD" \
    vcs-type="git" \
    vcs-url="https://gitlab.com/ravimosharksas/apis/auth/app.git" \
    distribution-scope="private" \
    Summary="Image to run Ravimoshark Auth API DB using MSSQL engine. It contains a test configuration."

ENV ACCEPT_EULA=Y
ENV REALM_VERSION=${REALM_VERSION}

COPY conf/db/mssql/realm-sav-v${REALM_VERSION}.bak /opt/backup/keycloak.bak
COPY scripts/mssql /opt/scripts

RUN chmod +x /opt/scripts/mssql_import_data.sh

EXPOSE 1433

CMD [ "/bin/bash", "-c", "/opt/scripts/mssql_entrypoint.sh" ]