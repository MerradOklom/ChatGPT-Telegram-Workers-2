FROM node:alpine AS DEV

WORKDIR /app
COPY package.json vite.config.ts tsconfig.json ./
COPY src ./src
RUN npm install && npm run build:local

FROM node:alpine AS PROD

WORKDIR /app
COPY --from=DEV /app/dist/index.js /app/dist/index.js
COPY --from=DEV /app/package.json /app/
RUN apk add --no-cache sqlite && \
    npm install --only=production --omit=dev && \
    npm cache clean --force
COPY create-configs.sh /app/create-configs.sh
RUN chmod +x /app/create-configs.sh

EXPOSE 8787
CMD ["/bin/bash", "-c", "/app/create-configs.sh && npm run start:dist"]
CMD ["npm", "run", "start:dist"]
