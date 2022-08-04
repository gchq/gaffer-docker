Extends the gchq/hdfs image to use Kerberos authentication.

The keytab is created at runtime using `ktutil` and the Principal details supplied from the environment.

To debug Kerberos, set `DEBUG`to `1` in the docker `.env`, the following in `log4j.properties` may also be useful:
```
log4j.rootLogger=DEBUG, stdout
log4j.logger.org.apache.hadoop.security=DEBUG
```
Cannot be run standalone without a KDC.
