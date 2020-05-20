#!/usr/bin/env bash

# -e exit on non 0 return
set -e
# -u exit on undefined variables
set -u
# -x print command before running (note that enabling this makes the gitlab test fail emails less readable)
#set -x
# bubble up the non 0 on pipes
set -o pipefail

if [[ $# -eq 0 ]]; then
    ENTRY_COMMAND="web"
else
    ENTRY_COMMAND="$1"
fi

echo "Launching Entrypoint ->${ENTRY_COMMAND}"

if [[ $ENTRY_COMMAND == "" ]]; then
 exit 0
elif [[ $ENTRY_COMMAND == "web" ]]; then
  if [ "${HTTP_AUTH_PASSWORD}" != "" ] && [ "${HTTP_AUTH_LOGIN}" != "" ]; then
    sed -i "s/#auth_basic/auth_basic/g;" /etc/nginx/conf.d/default.conf
    rm -rf /etc/nginx/.htpasswd
    echo -n $HTTP_AUTH_LOGIN:$(openssl passwd -apr1 $HTTP_AUTH_PASSWORD) >> /etc/nginx/.htpasswd
    echo "Basic auth is on for user ${HTTP_AUTH_LOGIN}..."
  fi
  if [[ "${OAUTH2_FORCE_HTTPS:-}" ]] && [[ "${OAUTH2_FORCE_HTTPS}" == "false" ]]; then
      FORCE_HTTPS="-cookie-secure=false -force-https=false"
  else
      FORCE_HTTPS="-cookie-secure=true -force-https=true"
  fi
  service nginx start
  # https://oauth2-proxy.github.io/oauth2-proxy/configuration
  oauth2_proxy -client-id="${OAUTH2_CLIENT_ID}" \
              -client-secret="${OAUTH2_CLIENT_SECRET}" \
              -provider="${OAUTH2_PROVIDER}" \
              -cookie-secret="${OAUTH2_COOKIE_SECRET}" \
              ${FORCE_HTTPS} \
              -set-xauthrequest=true \
              -email-domain="${OAUTH2_EMAIL_DOMAIN}" -upstream file:///dev/null &

  uvicorn main:app --host 0.0.0.0 --port 8080
else
  # Non blocking entrypoint starting bash
  exec "$@"
fi
