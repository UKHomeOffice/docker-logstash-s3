FROM quay.io/ukhomeofficedigital/docker-centos-base

# All amazon s3 specific.
ENV ACCESS_KEY_ID WHOCARES
ENV SECRET_ACCESS_KEY THISISMYRLYMYAMZNSECRET
ENV ENDPOINT_REGION eu-west-1
ENV BUCKET commons-dev-logs
ENV SIZE_FILE 2048
ENV TIME_FILE 5
ENV FORMAT plain
ENV CANNED_ACL private

# Install logstash
COPY conf/logstash.repo /etc/yum.repos.d/logstash.repo
RUN rpm --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch
RUN yum -y install java-1.7.0-openjdk logstash-1.5.3 

# Install journald plugin
RUN yum -y install git rubygems
RUN git clone  https://github.com/stuart-warren/logstash-input-journald.git && \
cd logstash-input-journald && \
gem build logstash-input-journald.gemspec && \
/opt/logstash/bin/plugin install logstash-input-journald-0.0.2.gem

# Setup logstash config
COPY conf/*.conf /etc/logstash/conf.d/

# Run logstash agent.  Pass in s3 config so we can define at runtime.  Mostly done so we don't need to store credentials.
CMD /opt/logstash/bin/logstash agent -f /etc/logstash/conf.d/ -e "output { s3{ access_key_id => \"$ACCESS_KEY_ID\" secret_access_key => \"$SECRET_ACCESS_KEY\" region => \"$ENDPOINT_REGION\" bucket => \"$BUCKET\" size_file => \"$SIZE_FILE\" time_file => \"$TIME_FILE\" canned_acl => \"$CANNED_ACL\" } }"
