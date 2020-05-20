FROM prismaticd/django-nginx:3.7

# get latest oauth2 proxy
RUN apt-get update \
  && apt-get install jq -y \
  && curl -L --silent \
$(curl --silent "https://api.github.com/repos/oauth2-proxy/oauth2-proxy/releases/latest" \
  | jq  -r '.assets[] | select(.name | contains("linux-amd64")).browser_download_url' \
  | grep ".tar.gz") \
| tar -xz --strip-components 1 && mv oauth2_proxy /usr/bin/ \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /files/
COPY ./entrypoint.sh /files/entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

COPY default.conf /etc/nginx/conf.d/default.conf
# COPY nginx.conf /etc/nginx/nginx.conf

COPY ./requirements.txt /files/requirements.txt
RUN pip install -r requirements.txt && rm -rf /root/.cache/
COPY src/ /files/