What you have here, is a Docker container for Gaffer.  This is a small
instance and is really only useful only development / trial
purposes.  But containerising allows a quick way to find out what Gaffer is
like and develop against the interfaces.  The container deploys: Hadoop,
Accumulo, Zookeeper, and launches Gaffer using Wildfly.

The memory settings of Accumulo are low to ensure Accumulo runs in a
small footprint.  Budget for around 2GB for trivial amounts of data, 6GB
for anything with some load.

To run:

  docker run -p 8080:8080 gchq/docker/0.3.9

You can then access the Gaffer API at port 8080, e.g. try accessing URL
http://HOSTNAME:8080/example-rest/v1/status

When the container dies, the data is lost.  If you want data to persist,
mount a volume on /data e.g.

  docker run -p 8080:8080 -v /data/gaffer:/data cybermaggedon/docker/0.3.9

The default schema deployed is usable.  If you want to set your own schema
then you need to change /usr/local/wildfly/schema/* by e.g. mounting
replacement volumes.

At high input load, Zookeeper seems to continually grow until it exhausts the
container memory footprint.

In future, I will probably detangle Hadoop, Accumulo, Zookeeper and Gaffer
into separate containers to run linked.

