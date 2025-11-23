#!/bin/sh
set -e

: "${INTERNAL_ALB_DNS:?INTERNAL_ALB_DNS is required}"

cat >/etc/nginx/conf.d/default.conf <<'EOF'
map $http_x_forwarded_proto $best_proto {
  default $http_x_forwarded_proto;
  ""      $scheme;
}

server {
  listen 80;
  server_name _;

  # 헬스체크
  location = /health {
    add_header Content-Type text/plain;
    return 200 'ok';
  }

  # 공통 프록시 설정
  proxy_http_version 1.1;
  proxy_connect_timeout 5s;
  proxy_send_timeout 60s;
  proxy_read_timeout 60s;

 #root
  location / {
    proxy_set_header Host              $host;
    proxy_set_header X-Real-IP         $remote_addr;
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host  $host;
    proxy_set_header X-Forwarded-Proto $best_proto;

    proxy_pass http://REPLACE_INTERNAL_ALB_DNS/;
    proxy_redirect off;
  }
EOF

sed -i "s#REPLACE_INTERNAL_ALB_DNS#$INTERNAL_ALB_DNS#g" /etc/nginx/conf.d/default.conf

# Grafana
if [ -n "$GRAFANA_URL" ]; then
cat >>/etc/nginx/conf.d/default.conf <<EOF
  # grafana
  location = /grafana {
    rewrite ^ /grafana/ break;
  }

  location /grafana/ {
    proxy_set_header Host              \$host;
    proxy_set_header X-Real-IP         \$remote_addr;
    proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host  \$host;
    proxy_set_header X-Forwarded-Proto \$best_proto;
    proxy_set_header X-Forwarded-Prefix /grafana;
    proxy_set_header Upgrade           \$http_upgrade;
    proxy_set_header Connection        "upgrade";

    proxy_pass $GRAFANA_URL;      # ← 슬래시 제거!
    proxy_redirect off;
  }
EOF
fi

# Prometheus
if [ -n "$PROMETHEUS_URL" ]; then
cat >>/etc/nginx/conf.d/default.conf <<EOF
  location = /prometheus {
    rewrite ^ /prometheus/ break;
  }

  location /prometheus/ {
    proxy_set_header Host              \$host;
    proxy_set_header X-Real-IP         \$remote_addr;
    proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host  \$host;
    proxy_set_header X-Forwarded-Proto \$best_proto;
    proxy_set_header X-Forwarded-Prefix /prometheus;

    proxy_pass $PROMETHEUS_URL;       # ← 슬래시 제거!
    proxy_redirect off;
  }
EOF
fi

# Loki
if [ -n "$LOKI_URL" ]; then
cat >>/etc/nginx/conf.d/default.conf <<EOF
  location = /loki {
    rewrite ^ /loki/ break;
  }

  location /loki/ {
    proxy_set_header Host              \$host;
    proxy_set_header X-Real-IP         \$remote_addr;
    proxy_set_header X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host  \$host;
    proxy_set_header X-Forwarded-Proto \$best_proto;
    proxy_set_header X-Forwarded-Prefix /loki;

    proxy_pass $LOKI_URL;             # ← 슬래시 제거!
    proxy_redirect off;
  }
EOF
fi

# 마무리
echo "}" >> /etc/nginx/conf.d/default.conf

nginx -t
exec nginx -g 'daemon off;'

