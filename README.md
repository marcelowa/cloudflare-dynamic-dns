# Cloudflare dynamic DNS docker
A small docker image that checks and update cloudflare DNS when the IP changes every 5 minutes
- https://www.cloudflare.com/learning/dns/glossary/dynamic-dns
- https://developers.cloudflare.com/api/resources/dns/subresources/records/methods/update


## Usage:
Running this Docker requires some environment variables (mandatory)
  
`CLOUDFLARE_API_TOKEN` Your API token on Cloudflare  
`CLOUDFLARE_ZONE` The zone on which the host your would like to update reside, typically it would be the domain, eg. example.com  
`CLOUDFLARE_HOST` The host you would like to update, eg. foo.example.com  

## Run
```shell
docker run -d --name=cloudflare-dynamic-dns \
    -e CLOUDFLARE_API_TOKEN=your_api_token_on_cloudflare \
    -e CLOUDFLARE_ZONE=example.com \
    -e CLOUDFLARE_HOST=foo.example.com \
    marcelowa/cloudflare-dynamic-dns:latest
```

## Pull
```shell
docker pull marcelowa/cloudflare-dynamic-dns:latest
```

License
MIT licensed.