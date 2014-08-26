module.exports = {
  gruntConfig: (() ->
  ),
  registerTask: ((grunt, taskName = 'default') ->
    grunt.loadNpmTasks('grunt-shell')
    grunt.loadNpmTasks('grunt-redis-manifest')

    # Default task(s). flag can be '-prod' or '-p'
    target = if grunt.option('prod') or grunt.option('p') then 'prod' else 'dev'

    if target is 'prod'
      grunt.loadNpmTasks('grunt-s3')
      grunt.loadNpmTasks('grunt-hashres')
      grunt.loadNpmTasks('grunt-cdn')
      grunt.registerTask taskName, [ "shell:#{target}"
                                      'hashres'
                                      'cdn'
                                      's3'
                                      "redis:#{target}" ]
    else
      grunt.loadNpmTasks('grunt-contrib-watch')
      grunt.registerTask taskName, [ "shell:#{target}",
                                      "redis:#{target}" ]
  )
}