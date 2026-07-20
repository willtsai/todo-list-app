extension radius

@description('The Radius environment ID. Injected by the rad CLI.')
param environment string

@description('The Radius application ID. Injected by the rad CLI.')
param application string

@description('Container image for the to-do list web app.')
param image string = 'ghcr.io/willtsai/todo-list-app:latest'

@description('MySQL root/admin password.')
@secure()
param mysqlPassword string

resource mysqlSecret 'Radius.Security/secrets@2025-05-01-preview' = {
  name: 'mysql-secret'
  properties: {
    application: application
    environment: environment
    data: {
      password: {
        value: mysqlPassword
      }
    }
  }
}

resource mysql 'Radius.Data/mySqlDatabases@2025-08-01-preview' = {
  name: 'todos-db'
  properties: {
    application: application
    environment: environment
    database: 'todos'
  }
}

resource webApp 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'todo-app'
  properties: {
    application: application
    environment: environment
    container: {
      image: image
      ports: {
        web: {
          containerPort: 3000
        }
      }
      env: {
        MYSQL_HOST: {
          value: mysql.properties.host
        }
        MYSQL_DB: {
          value: 'todos'
        }
        MYSQL_USER: {
          value: 'root'
        }
        MYSQL_PASSWORD: {
          valueFrom: {
            secretRef: {
              source: mysqlSecret.id
              key: 'password'
            }
          }
        }
      }
    }
    connections: {
      mysql: {
        source: mysql.id
      }
    }
  }
}
