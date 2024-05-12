FROM quay.io/centos/centos:stream10-development AS build
WORKDIR /src
RUN dnf -y install 'dnf-command(builddep)' && \
    dnf -y builddep traceroute
RUN dnf -y install jq patch
COPY traceroute.tgz /src/traceroute.tgz
COPY 0001-sends-a-payload-with-fastopen.patch /src/
RUN mkdir tr && tar -C tr --strip-components 1 -zxv -f /src/traceroute.tgz
#RUN /usr/bin/patch -p1 -d tr < ./0001-sends-a-payload-with-fastopen.patch
RUN cd tr && make

FROM quay.io/centos/centos:stream10-development-minimal
COPY --from=build /src/tr/traceroute/traceroute /usr/bin/traceroute
LABEL io.containers.capabilities=net_admin,net_raw
ENTRYPOINT ["/usr/bin/traceroute"]

