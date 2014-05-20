#
# Integration tests docker file for cloudify manager
# https://github.com/cloudify-cosmo/cloudify-manager
#

FROM phusion/passenger-customizable:0.9.10

#
# URLs
#
ENV PIP_URL https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py
ENV RIE_URL http://aphyr.com/riemann/riemann_0.2.5_all.deb
ENV RMQ_URL http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
ENV ELS_URL http://packages.elasticsearch.org/GPG-KEY-elasticsearch

#
# PPAs
#
RUN echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list && \
    curl -s $RMQ_URL | apt-key add -
RUN echo "deb http://packages.elasticsearch.org/elasticsearch/1.0/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list && \
    curl -s $ELS_URL | apt-key add -

#
# General stuff
#
EXPOSE 22
RUN /usr/sbin/enable_insecure_key
RUN apt-get update && \
    /build/utilities.sh && \
    /build/ruby2.1.sh && \
    /build/devheaders.sh && \
    /build/python.sh && \
    apt-get install -y ca-certificates openjdk-7-jdk python-dev #zlib1g-dev libssl-dev libreadline6-dev libyaml-dev

#
# PIP and modules
#
RUN curl --silent --show-error --retry 5 $PIP_URL | python && \
    pip install nose

#
# Ruby Gems
#
RUN gem install bundler

#
# Riemann
#
RUN FILE=`mktemp` && \
    curl "$RIE_URL" -o $FILE && \
    sudo dpkg -i $FILE

#
# ElasticSearch
#
RUN apt-get install -y elasticsearch=1.0.1
RUN mkdir -p /usr/share/elasticsearch/data && \
    chmod 777 /usr/share/elasticsearch/data

#
# RabbitMQ
#
RUN apt-get install -y rabbitmq-server

#
# Virtualenv
#
RUN pip install virtualenv

#CMD /sbin/my_init --enable-insecure-key
