## GP-BKE-RUNTIME-DATABASE-MYSQL

This Helm-Chart provisions a MySQL database with help of [bitnami/mysql](https://github.com/bitnami/charts/tree/master/bitnami/mysql) chart. See there for detailed documentation.

This BKE ist ment to be bundled together with an application-BKE. Then environment-variables 
to connect with the database are injected into the application. Currently secrets are used 
to store the necessary information.


# Usage

```helm repo add gepaplexx https://gepaplexx.github.io/gp-helm-charts/```  
```oc new-project example-dev```  
```helm install mydb gepaplexx/gp-bke-runtime-database-mysql -n example-dev```

Note that the bitnami/postgres chart is included with the dependency alias `db`. You have to
add this prefix to variables in order to use its variables. E.g. in `values.yml`:

```
db:
  auth:
    username: "appuser"
``` 

to use `auth.username=appuser` from bitnami chart.
