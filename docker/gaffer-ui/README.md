Gaffer UI
==========

The Gaffer UI contains the Gaffer UI which resides in [Gaffer Tools](https://github.com/gchq/gaffer-tools).

### Build

To build the Gaffer UI as well as the Gaffer REST service, use `docker-compose build`

You can provide your own ui.war file by putting it in the wars directory. This will be copied into the image.

### Run

To run the Gaffer UI against an example REST API, use `docker-compose up`