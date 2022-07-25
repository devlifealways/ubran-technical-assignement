FROM node:14-alpine AS node_builder

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --quiet
COPY tsconfig*.json ./
COPY app app
RUN npm run build


FROM node:14-alpine

RUN set -euxo pipefail ;\
  apk add --no-cache dumb-init; \
  rm -rf /var/cache/apk/*

WORKDIR /usr/src/app
RUN chown node:node .
USER node
COPY package*.json ./
RUN npm install --quiet
COPY --from=node_builder /usr/src/app/app/ app/
EXPOSE 3000

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["node", "app/index.js"]