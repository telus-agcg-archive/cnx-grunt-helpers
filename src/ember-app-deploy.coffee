module.exports = {
  ###
    driven by variables set in '.env.json' in root of project
    along with environment variables that exist on the system
  
    System Environment Variables:
    - AWS_ACCESS_KEY
    - AWS_SECRET_KEY
  
    .env.json variables:
    {
      "AWS": {
        "bucket": ...
        "cdn": {
          "subdomain": ...
        }
      },
      "REDIS": {
        "dev": {
          "host": ...
          "port": ...
        },
        "prod": {
          "host": ...
          "port": ...
        }
      }
      "APP_NAME": ...
      "DEV_HOSTAPP_FILEPATH": ...
    }
  ###
  config: ((grunt) ->
    timestamp = Date.now().toString()
    config = {
      env: grunt.file.readJSON '.env.json'
      processEnv: process.env

      s3:
        options:
          key:    '<%= processEnv.AWS_ACCESS_KEY %>'
          secret: '<%= processEnv.AWS_SECRET_KEY %>'
          bucket: '<%= env.AWS.bucket %>'
          access: 'public-read'
          headers:
            "Cache-Control": "max-age=630720000, public" # 2 years
            "Expires": new Date(Date.now() + 630720000).toUTCString()
        prod:
          upload: [
            {
              src: 'dist/assets/*'
              dest: timestamp + '/assets/'
            }
          ]

      redis:
        options:
          prefix: '<%= env.APP_NAME %>' + timestamp + ':'
          currentDeployKey: '<%= env.APP_NAME %>' + timestamp
          manifestKey: '<%= env.APP_NAME %>' + '_manifest_ten_deploys'
          manifestSize: 10
        dev:
          options:
            host: '<%= env.REDIS.dev.host %>'
            port: '<%= env.REDIS.dev.port %>'
          files: src : ["dist/index.html"]
        prod:
          options:
            host: '<%= env.REDIS.prod.host %>'
            port: '<%= env.REDIS.prod.port %>'
            # connectionOptions: auth_pass: '<%= env.REDIS.production.password %>'
          files: src : ["dist/index.html"]

      hashres:
        prod:
          # files to be fingerprinted
          src: [
            'dist/assets/<%= env.APP_NAME %>.js'
            # 'dist/assets/vendor.css'
            'dist/assets/<%= env.APP_NAME %>.css'
          ]
          # file that needs references rewritten
          dest: 'dist/index.html'

      cdn:
        options:
          cdn: "https://<%= env.AWS.cdn.subdomain %>.cloudfront.net/" + timestamp
          flatten: true
        dist:
          src: ['./dist/index.html']

      shell:
        options:
          stdout: true
          stderr: true
          failOnError: true
        dev: command: 'ember build --environment=development; cp dist/assets/* <%= env.DEV_HOSTAPP_FILEPATH %>'
        prod: command: 'ember build --environment=production'
      watch:
        dev: {
          files: ['app/**'],
          tasks: ['default'],
          options: {
            spawn: false
          }
        }
    }
    config
  ),
  registerTask: ((grunt, taskName = 'default') ->
    relativePath = 'cnx-grunt-helpers/node_modules'
    grunt.loadNpmTasks("#{relativePath}/grunt-shell")
    grunt.loadNpmTasks("#{relativePath}/grunt-redis-manifest")

    # Default task(s). flag can be '-prod' or '-p'
    target = if grunt.option('prod') or grunt.option('p') then 'prod' else 'dev'

    if target is 'prod'
      grunt.loadNpmTasks("#{relativePath}/grunt-s3")
      grunt.loadNpmTasks("#{relativePath}/grunt-hashres")
      grunt.loadNpmTasks("#{relativePath}/grunt-cdn")
      grunt.registerTask taskName, [ "shell:#{target}"
                                      'hashres'
                                      'cdn'
                                      's3'
                                      "redis:#{target}" ]
    else
      grunt.loadNpmTasks("#{relativePath}/grunt-contrib-watch")
      grunt.registerTask taskName, [ "shell:#{target}",
                                      "redis:#{target}" ]
  )
}
