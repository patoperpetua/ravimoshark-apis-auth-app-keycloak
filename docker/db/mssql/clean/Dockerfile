ARG BASE_IMAGE_TAG=2017-latest-ubuntu

FROM mcr.microsoft.com/mssql/server:${BASE_IMAGE_TAG}

LABEL mainteiner="Patricio Perpetua <patoperpetua@singletonsd.com>" \
    name="ravimosharksas/apis/auth/db/mssql-clean" \
    architecture="x86_64" \
    vendor="SINGLETON_SD" \
    vcs-type="git" \
    vcs-url="https://gitlab.com/ravimosharksas/apis/auth/app.git" \
    distribution-scope="private" \
    Summary="Image to run Ravimoshark Auth API DB using MSSQL engine. It only contains a Keycloak empty database."

ENV ACCEPT_EULA=Y

COPY scripts/mssql /opt/scripts

EXPOSE 1433

CMD [ "/bin/bash", "-c", "/opt/scripts/mssql_entrypoint_clean.sh" ]