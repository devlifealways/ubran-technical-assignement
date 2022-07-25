FROM --platform=linux/amd64 node:14-alpine AS node_builder

LABEL examinee="Hamza Rouineb"
# could be set to Gitlab's CI_COMMIT_GIT
ARG GIT_COMMIT_SHA1="NONE"
ARG APP_PORT=3000

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --quiet
COPY tsconfig*.json ./
COPY app app
RUN npm run build


FROM --platform=linux/amd64 node:14-alpine

ENV NODE_ENV=production

RUN set -euxo pipefail ;\
  apk add --no-cache dumb-init; \
  rm -rf /var/cache/apk/*

WORKDIR /usr/src/app
RUN chown node:node .
USER node
COPY package*.json ./
RUN npm install --quiet
COPY --from=node_builder /usr/src/app/app/ app/

HEALTHCHECK --interval=1m --timeout=30s\
  --retries=3 CMD wget --spider\
  http://localhost:${APP_PORT} || exit 1

EXPOSE ${APP_PORT}

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "app/index.js"]