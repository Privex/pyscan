#######
#
# To build this RHEL 8 docker file, you need a redhat account.
#
# The image comes from here: 
#   https://catalog.redhat.com/software/containers/rhel8/s2i-base/5ba0ad7a5a134643ef2eebb5?container-tabs=overview
#
#######

FROM registry.redhat.io/rhel8/s2i-base
VOLUME /app
WORKDIR /app
VOLUME /data

COPY . /app/


ENTRYPOINT [ "/bin/bash" ]

