Changing the Accumulo Passwords
===============================

When deploying accumulo - either as part of a Gaffer stack or as a standalone, the passwords for all the users and the instance.secret are set to default values. These should be changed. The instance.secret cannot be changed once deployed as it's used in initalisation.

When deploying the accumulo helm chart, the following values are set. If you're using the gaffer helm chart with the Accumulo integration, the values will be prefixed with "accumulo":

| Name                 | value                                         | default value
|----------------------|-----------------------------------------------|-----------------
| Instance Secret      | `config.accumuloSite."instance.secret"`       | "DEFAULT"
| Root password        | `config.userManagement.rootPassword`          | "root"
| Tracer user password | `config.userManagement.users.tracer.password` | "tracer"

When you deploy the Gaffer Helm chart with Accumulo, a "gaffer" user with a password of "gaffer" is used by default following the same pattern as the tracer user.

So to install a new Gaffer with Accumulo store, create an `accumulo-passwords.yaml` with the following contents:

```yaml
accumulo:
  enabled: true
  config:
    accumuloSite:
      instance.secret: "changeme"
    userManagement:
      rootPassword: "changeme"
      users:
        tracer:
          password: "changme"
        gaffer:
          password: "changeme"
```

You can install the graph with:

```bash
helm install my-graph gaffer-docker/gaffer -f accumulo-passwords.yaml 
```
