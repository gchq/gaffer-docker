Extends the gchq/gaffer image to use Kerberos authentication.

The keytab is created at runtime using `ktutil` and the Principal details supplied from the environment.

To debug Kerberos, set `DEBUG`to `1` in the docker `.env`, adding `log4j.logger.org.apache.hadoop.security=DEBUG` in `log4j.properties` may also be useful.

Cannot be run standalone without a KDC.
