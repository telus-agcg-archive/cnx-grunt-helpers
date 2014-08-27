## Grunt Helpers

A repo with general Grunt helpers. At least, that's what it is starting as...

### EmberAppDeploy

A module that provides assistanace for deploying ember-cli applications in a way
that they can be used in Rails apps [ala](http://blog.abuiles.com/blog/2014/07/08/lightning-fast-deployments-with-rails/).
To use this module, create a Gruntfile.coffee file in your ember-cli project that looks like this:

```coffeescript
EmberAppDeploy = require('cnx-grunt-helpers').EmberAppDeploy;

module.exports = (grunt) ->
  grunt.initConfig EmberAppDeploy.config(grunt)

  EmberAppDeploy.registerTask(grunt)
```

The ember-cli project must also have a `.env.json` file that contains configuration settings for
deploying your app. It should [look like this](https://github.com/connexio-labs/cnx-grunt-helpers/blob/master/src/ember-app-deploy.coffee#L11).

The system where grunt is executed must also have environment variables for the AWS keys [like this](https://github.com/connexio-labs/cnx-grunt-helpers/blob/master/src/ember-app-deploy.coffee#L7).
