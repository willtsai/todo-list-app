import radius as radius

@description('The Radius application')
resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'app'
  properties: {
    environment: radius.envVar('RADIUS_ENVIRONMENT_ID')
  }
}
