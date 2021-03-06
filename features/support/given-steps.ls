require! {
  'cucumber': {defineSupportCode}
  'fs'
  'path'
  'wait' : {wait}
}


defineSupportCode ({Given}) ->

  Given /^a file "([^"]*)" with the content:$/ (file-name, content) ->
    @create-file file-name, content


  Given /^Tertestrial had been running a test$/ (done) ->
    @root-dir = path.join 'example-applications', 'simple'
    @start-process @tertestrial-path, ~>
      @process.wait 'running', ~>
        @process.reset-output-streams!
        @send-command '{}', ~>
          @process.wait 'Running simple tests', ~>
            @process.reset-output-streams!
            done!


  Given /^Tertestrial is running$/, (done) ->
    @create-file 'tertestrial.yml', 'actions: {}'
    @start-process @tertestrial-path, done


  Given /^Tertestrial is running a long\-running test$/ (done) ->
    @root-dir = path.join 'example-applications', 'long-running-test'
    @start-process @tertestrial-path, ~>
      @send-command '{}', done



  Given /^Tertestrial is running inside the "([^"]*)" example application$/, timeout: 40_000, (app-name, done) ->
    @root-dir = path.join 'example-applications', app-name
    fs.unlink path.join(@root-dir, '.tertestrial.tmp'), ~>
      @run-process 'yarn install'
      @start-process @tertestrial-path, done


  Given /^Tertestrial is starting in a directory containing the file "([^"]*)"$/ (filename, done) ->
    @create-file 'tertestrial.yml', 'actions: {}'
    @create-file filename, ''
    @start-process @tertestrial-path, done


  Given /^Tertestrial runs with the configuration:$/, timeout: 40_000, (config, done) ->
    @create-file 'tertestrial.yml', config
    @start-process @tertestrial-path, done


  Given /^Tertestrial runs with the configuration file "([^"]*)":$/ (filename, content, done) ->
    @create-file filename, content
    @start-process @tertestrial-path, done
