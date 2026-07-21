extension radius

@description('The Radius environment ID. Injected by the rad CLI.')
param environment string

@description('MySQL root password.')
@secure()
param mysqlPassword string

resource app 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'todo-list-app'
  properties: {
    environment: environment
  }
}

resource todoImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'todo-app-image'
  properties: {
    environment: environment
    application: app.id
    build: {
      source: 'git::https://github.com/willtsai/todo-list-app.git'
    }
  }
}

resource mysql 'Radius.Data/mySqlDatabases@2025-08-01-preview' = {
  name: 'todos-db'
  properties: {
    environment: environment
    application: app.id
    username: 'root'
    password: mysqlPassword
  }
}

resource todoApp 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'todo-app'
  properties: {
    environment: environment
    application: app.id
    containers: {
      todoApp: {
        image: todoImage.properties.imageReference
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
            value: mysqlPassword
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
