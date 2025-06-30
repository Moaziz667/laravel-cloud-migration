apiVersion: v1
kind: ConfigMap
metadata:
  name: laravel-config
  namespace: production
data:
  APP_ENV: production
  APP_DEBUG: "false"
  APP_URL: http://localhost
  DB_CONNECTION: mysql
  DB_HOST: "${rds_endpoint}"
  DB_PORT: "3306"
  DB_DATABASE: laravel
  DB_USERNAME: admin
