FROM node:20-buster as installer
COPY . /juice-shop
WORKDIR /juice-shop
RUN npm i -g typescript ts-node
RUN npm install --omit=dev --unsafe-perm
RUN npm dedupe --omit=dev
RUN rm -rf frontend/node_modules
RUN rm -rf frontend/.angular
RUN rm -rf frontend/src/assets
RUN mkdir logs
RUN chown -R 65532 logs
RUN chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/
RUN chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/
RUN rm data/chatbot/botDefaultTrainingData.json || true
RUN rm ftp/legal.md || true
RUN rm i18n/*.json || true

ARG CYCLONEDX_NPM_VERSION=latest
RUN npm install -g @cyclonedx/cyclonedx-npm@$CYCLONEDX_NPM_VERSION
RUN npm run sbom

# workaround for libxmljs startup error
FROM node:20-buster as libxmljs-builder
WORKDIR /juice-shop
RUN apt-get update && apt-get install -y build-essential python3
COPY --from=installer /juice-shop/node_modules ./node_modules
RUN rm -rf node_modules/libxmljs/build && \
  cd node_modules/libxmljs && \
  npm run build

FROM gcr.io/distroless/nodejs20-debian11
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.title="OWASP Juice Shop" \
    org.opencontainers.image.description="Probably the most modern and sophisticated insecure web application" \
    org.opencontainers.image.authors="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.vendor="Open Worldwide Application Security Project" \
    org.opencontainers.image.documentation="https://help.owasp-juice.shop" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="17.1.1" \
    org.opencontainers.image.url="https://owasp-juice.shop" \
    org.opencontainers.image.source="https://github.com/juice-shop/juice-shop" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE
WORKDIR /juice-shop
COPY --from=installer --chown=65532:0 /juice-shop .
COPY --chown=65532:0 --from=libxmljs-builder /juice-shop/node_modules/libxmljs ./node_modules/libxmljs
USER 65532
EXPOSE 3000
CMD ["/juice-shop/build/app.js"]


-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----
