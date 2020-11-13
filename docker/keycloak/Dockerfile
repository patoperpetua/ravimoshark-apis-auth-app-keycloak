ARG BASE_IMAGE_TAG=11.0.0

FROM jboss/keycloak:${BASE_IMAGE_TAG}

ARG REALM_VERSION=0.0.1

LABEL mainteiner="Patricio Perpetua <patoperpetua@singletonsd.com>" \
    name="ravimosharksas/apis/auth/app" \
    architecture="x86_64" \
    vendor="SINGLETON_SD" \
    vcs-type="git" \
    vcs-url="https://gitlab.com/ravimosharksas/apis/auth/app.git" \
    distribution-scope="private" \
    Summary="Image to run Ravimoshark Auth API using Keycloak Server. It contains a default configuration."

ENV KEYCLOAK_IMPORT="/opt/conf/realm-sav-v${REALM_VERSION}.json"

COPY conf/realms/realm-sav-v${REALM_VERSION}.json /opt/conf/realm-sav-v${REALM_VERSION}.json