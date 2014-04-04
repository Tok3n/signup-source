module.exports = ( grunt ) ->
  grunt.initConfig
    pkg : grunt.file.readJSON( "package.json" )

    cssmin:
      add_banner:
        options:
          banner: '/* MINIFIED CSS */'
        files:
          '_site/css/styles.min.css': ['_site/css/styles.css']

    uncss:
      dist:
        files:
          '_site/css/tidy.css': ['_site/index.html']

  grunt.loadNpmTasks( 'grunt-uncss' )
  grunt.loadNpmTasks('grunt-contrib-cssmin')

  grunt.registerTask( 'default', ['cssmin', 'uncss'] )