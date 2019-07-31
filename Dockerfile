# FROM golang:1.12-alpine as build

# RUN apk add --no-cache \
#     alpine-sdk \
#     redis \
#     dep

# WORKDIR /code
# RUN git clone https://github.com/contribsys/faktory /code/src/faktory

# WORKDIR /code/src/faktory
# COPY Makefile /code/src/faktory
# RUN export GOPATH=/code \
#  && make prepare \
#  && make test \
#  && make build
# above does not build properly: ../github.com/contribsys/faktory/storage/sorted_redis.go:62:49: cannot use redis.Z literal (type redis.Z) as type *redis.Z in argument to rs.store.rclient.client.cmdable.ZAdd
FROM contribsys/faktory as binary

FROM bcit/alpine:3.10
RUN apk add --no-cache \
    redis \
    ca-certificates \
    socat

COPY --from=binary /faktory /

RUN mkdir -p /var/lib/faktory/db \
 && mkdir -p /.faktory \
 && chmod 775 /.faktory \
 && chmod 775 -R /var/lib/faktory/

EXPOSE 7419 7420
CMD ["/faktory", "-w", "0.0.0.0:7420", "-b", "0.0.0.0:7419", "-e", "production"]
