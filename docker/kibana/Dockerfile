FROM docker.elastic.co/kibana/kibana:8.12.0

USER root
RUN apt-get update && apt-get install -y python3 python3-pip
COPY docker/kibana/init/requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt

#COPY docker/kibana/kibana.yaml /usr/share/kibana/config/kibana.yaml
COPY docker/kibana/init/init_kibana.py /usr/local/bin/
COPY docker/kibana/init/entrypoint.sh /usr/local/bin/

RUN mkdir -p /usr/share/kibana/init/data_views \
             /usr/share/kibana/init/dashboards
COPY docker/kibana/init/data_views/*.json /usr/share/kibana/init/data_views/
COPY docker/kibana/init/dashboards/*.json /usr/share/kibana/init/dashboards/

RUN chmod +x /usr/local/bin/entrypoint.sh

USER kibana
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]