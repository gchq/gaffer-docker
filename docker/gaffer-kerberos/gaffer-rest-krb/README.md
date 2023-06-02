Extends the gchq/gaffer-rest docker image to use Kerberos authentication.

This consists of adding a Kerberos client and configuration to use Kerberos to authenticate with Accumulo (modified `store.properties` and a new Accumulo client config file) 

The keytab is created at runtime using `ktutil` and the Principal details supplied from the environment.

Cannot be run standalone without a KDC.
