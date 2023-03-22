Extends the normal Zookeeper docker image to use Kerberos authentication.

The keytab is created at runtime using `ktutil` and the Principal details supplied from the environment.

To see more debug info about Kerberos, add `-Dsun.security.krb5.debug=true -Dsun.security.spnego.debugset` to the `SERVER_JVMFLAGS` in  `java.env`.

Cannot be run standalone without a KDC.
