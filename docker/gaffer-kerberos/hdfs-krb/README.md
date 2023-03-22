Extends the gchq/hdfs image to use Kerberos authentication.

The keytab is created at runtime using `ktutil` and the Principal details supplied from the environment.

Adding/changing the following in the `log4j.properties` may also be useful for additional debugging:
```
log4j.rootLogger=DEBUG, stdout
log4j.logger.org.apache.hadoop.security=DEBUG
```
Cannot be run standalone without a KDC.
