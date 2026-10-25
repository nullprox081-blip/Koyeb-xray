
FROM alpine:edge

ARG AUUID=772c3841-62ae-4604-a461-564cd3cfd7e9
ARG CADDYIndexPage=https://github.com/AYJCSGM/mikutap/archive/master.zip
ARG ParameterSSENCYPT=chacha20-ietf-poly1305
ARG PORT=80

ADD etc/Caddyfile /tmp/Caddyfile
ADD etc/xray.json /tmp/xray.json
ADD start.sh /start.sh

RUN apk add --no-cache ca-certificates caddy tor wget unzip python3 && \
    wget -O /tmp/Xray-linux-64.zip \
      https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -o /tmp/Xray-linux-64.zip -d /tmp/xray-bin && \
    install -m 755 /tmp/xray-bin/xray /xray && \
    mkdir -p /etc/caddy /usr/share/caddy && \
    printf 'User-agent: *\nDisallow: /\n' > /usr/share/caddy/robots.txt && \
    wget "$CADDYIndexPage" -O /tmp/site.zip && \
    unzip -qo /tmp/site.zip -d /tmp/site && \
    find /tmp/site -type f -name index.html -exec cp {} /usr/share/caddy/index.html \; && \
    test -s /usr/share/caddy/index.html && \
    export AUUID="$AUUID" PORT="$PORT" ParameterSSENCYPT="$ParameterSSENCYPT" && \
    python3 -c 'import os,pathlib; \
p=pathlib.Path("/tmp/Caddyfile").read_text(); \
p=p.replace("$AUUID",os.environ["AUUID"]); \
p=p.replace("$MYUUID-HASH",os.popen("caddy hash-password --plaintext "+__import__("shlex").quote(os.environ["AUUID"])).read().strip()); \
p=p.splitlines(); p[0]=":"+os.environ["PORT"]; \
pathlib.Path("/etc/caddy/Caddyfile").write_text("\n".join(p)+"\n"); \
p=pathlib.Path("/tmp/xray.json").read_text(); \
p=p.replace("$AUUID",os.environ["AUUID"]).replace("$ParameterSSENCYPT",os.environ["ParameterSSENCYPT"]); \
pathlib.Path("/xray.json").write_text(p)' && \
    rm -rf /tmp/Xray-linux-64.zip /tmp/xray-bin /tmp/site.zip /tmp/site

RUN chmod +x /start.sh

CMD ["/start.sh"]
