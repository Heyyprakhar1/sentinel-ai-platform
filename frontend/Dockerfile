# ============================================================
# Stage 1 - Build React App
# ============================================================

FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --silent

COPY . .

RUN npm run build


# ============================================================
# Stage 2 - Runtime
# ============================================================

FROM nginxinc/nginx-unprivileged:1.27-alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK \
  CMD wget -qO- http://127.0.0.1:8080/ || exit 1

CMD ["nginx","-g","daemon off;"]
