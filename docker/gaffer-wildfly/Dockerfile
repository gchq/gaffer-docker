FROM jboss/wildfly:10.1.0.Final

ARG gaffer_version
# Add store properties
ADD config/store.properties /opt/jboss/wildfly/standalone/configuration/store.properties

# Add Graph config
ADD config/graphConfig.json /opt/jboss/wildfly/standalone/configuration/graphConfig.json

# Add Apps
RUN curl http://central.maven.org/maven2/uk/gov/gchq/gaffer/accumulo-rest/${gaffer_version}/accumulo-rest-${gaffer_version}.war -o /opt/jboss/wildfly/standalone/deployments/rest.war
RUN curl http://central.maven.org/maven2/uk/gov/gchq/gaffer/ui/${gaffer_version}/ui-${gaffer_version}.war -o /opt/jboss/wildfly/standalone/deployments/ui.war

USER root
# Create schema directory
RUN mkdir /schema && chown jboss /schema

USER jboss

CMD [ "/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-Dgaffer.schemas=/schema", "-Dgaffer.storeProperties=/opt/jboss/wildfly/standalone/configuration/store.properties", "-Dgaffer.graph.config=/opt/jboss/wildfly/standalone/configuration/graphConfig.json" ]