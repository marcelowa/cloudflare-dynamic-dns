# Cloudflare dynamic DNS docker
A small docker image that checks and update cloudflare dns when the ip changes every 5 minutes

## Usage:
Running this docker requires passing 4 environment variables  
  
`API_TOKEN` Your API token on Cloudflare  
`ZONE` The zone on which the host your would like to update reside, typically it would be the domain, eg. example.com  
`HOST` The host you would like to update, eg. foo.example.com  

## Run
```shell
docker run -d --name=cloudflare-dynamic-dns \
    -e API_TOKEN=your_api_key_on_cloudflare \
    -e ZONE=example.com \
    -e HOST=foo.example.com \
    marcelowa/cloudflare-dynamic-dns:latest
```

## Pull
```shell
docker pull marcelowa/cloudflare-dynamic-dns:latest
```

License
MIT licensed.