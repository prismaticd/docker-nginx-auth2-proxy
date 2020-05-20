# docker-nginx-oauth2-proxy

This is an example to set up a Docker container with Simple Auth and Oauth2, 
using this for private docker web apps exposed to the public internet

Give it a try locally with a Github oauth2 app only working on http://localhost:8282

```
docker compose up
```

## Used for this demo

* [Nginx auth_request directive](https://nginx.org/en/docs/http/ngx_http_auth_request_module.html) as a web server
* [Oauth2-Proxy](https://github.com/oauth2-proxy/oauth2-proxy) to force oauth2 logins
* [Fast API](https://fastapi.tiangolo.com/) as python backend example

## How does it work?

* Dockerfile downloads the last version of oauth2-proxy and exposed port 80
* Docker container run entrypoint.sh
    * start nginx on port 80
    * start oauth2-proxy on port 4180
    * starts fast api backend on port 8080
* Nginx does simple auth to protect the entire application from bots (login/password is set as env variables) 
* Nginx require auth_request to go to oauth2-proxy backend
* If oauth2-proxy can authenficate the user it sets a cookie _oauth2_proxy and X-Email and X-User headers
* If cookie is valid nginx sends the request to the backend
* Fast API can now read the X-Email and do additional granular access control without having to do Authentification


## Environement variables

```yaml
  HTTP_AUTH_LOGIN: test  # this will be simple auth login, if blank or not set there will be no simpleauth
  HTTP_AUTH_PASSWORD: test # this will be simple auth password, if blank or not set there will be no simpleauth
  OAUTH2_CLIENT_ID: asdasdasdasdas # oauth2 client if
  OAUTH2_CLIENT_SECRET: ghfhfghfghfghgfhghf  # oauth2 secret
  OAUTH2_PROVIDER: github  # Oauth2 app provider
  OAUTH2_COOKIE_SECRET: asdkjhdaskdask # secret for cookie sessions, generate one: python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(16)).decode())'
  OAUTH2_EMAIL_DOMAIN: "*" # email domain authorized for oauth2 if not * it will restric only emails from the given domain
  OAUTH2_FORCE_HTTPS: "false"  # Required to be false to test local, you should always be over HTTPS in production, do not set this env variable for prod
```