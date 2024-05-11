FROM quay.io/centos/centos:stream10-development AS build
WORKDIR /src
RUN dnf -y install 'dnf-command(builddep)' && \
    dnf -y builddep traceroute
RUN dnf -y install jq
COPY traceroute.tgz /src/traceroute.tgz
RUN mkdir tr && tar -C tr --strip-components 1 -zxv -f /src/traceroute.tgz
RUN cd tr && make

FROM quay.io/centos/centos:stream10-development-minimal
COPY --from=build /src/tr/traceroute/traceroute /usr/bin/traceroute
LABEL io.containers.capabilities=net_admin,net_raw
ENTRYPOINT ["/usr/bin/traceroute"]

