Extends the gchq/gaffer image to use Kerberos authentication.

This consists of various changes to Accumulo config and additional initialisation steps. This folder also contains the boilerplate Accumulo client config needed to enable Kerberos for clients such as the Gaffer REST.

The keytab is created at runtime using `ktutil` and the Principal details supplied from the environment.

Cannot be run standalone without a KDC.