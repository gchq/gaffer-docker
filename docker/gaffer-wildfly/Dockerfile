FROM jboss/wildfly:10.1.0.Final

ARG gaffer_version
# Add store properties
COPY config/store.properties /opt/jboss/wildfly/standalone/gaffer/store.properties

# Add Graph config
COPY config/graphConfig.json /opt/jboss/wildfly/standalone/gaffer/graphConfig.json

# Copy any WARs you would like to use instead of the default ones stored in maven central
# The wars must be called rest.war / ui.war.
COPY --chown=jboss wars /opt/jboss/wildfly/standalone/deployments

# Add Apps if they do not exist already.
RUN if [ ! -f /opt/jboss/wildfly/standalone/deployments/rest.war ]; then curl http://central.maven.org/maven2/uk/gov/gchq/gaffer/accumulo-rest/${gaffer_version}/accumulo-rest-${gaffer_version}.war -o /opt/jboss/wildfly/standalone/deployments/rest.war --silent; fi
RUN if [ ! -f /opt/jboss/wildfly/standalone/deployments/ui.war ]; then curl http://central.maven.org/maven2/uk/gov/gchq/gaffer/ui/${gaffer_version}/ui-${gaffer_version}.war -o /opt/jboss/wildfly/standalone/deployments/ui.war --silent; fi

USER root
# Create schema directory
RUN mkdir /schema && chown jboss /schema

USER jboss

ADD example/schema /schema

CMD [ "/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-Dgaffer.schemas=/schema", "-Dgaffer.storeProperties=/opt/jboss/wildfly/standalone/gaffer/store.properties", "-Dgaffer.graph.config=/opt/jboss/wildfly/standalone/gaffer/graphConfig.json" ]