require! {
  'chalk' : {bold, cyan, green}
  'fs'
  'inquirer'
  'path'
  'prelude-ls' : {map, sort}
  'shelljs/global'
}


function built-in-mappings
  fs.readdir-sync(path.join __dirname, '..' 'mappings')
    |> map -> path.basename it, path.extname(it)
    |> sort


function create-builtin-config mapping
  fs.write-file-sync 'tertestrial.yml', "mappings: #{mapping}"
  console.log """

  Created configuration file #{cyan 'tertestrial.yml'}.

  """


function create-custom-mapping language
  cp path.join(__dirname, '..' 'templates' 'tertestrial.js'), 'tertestrial.js'
  console.log """

  Created configuration file #{cyan 'tertestrial.js'} as a starter.
  Please adapt it to your project.

  """


module.exports = ->
  console.log bold 'Tertestrial setup wizard\n'
  questions =
    message: 'Do you want to use a built-in mapping?'
    type: 'list'
    name: 'mapping'
    choices: [{name: 'No, I want to build my own custom mapping', value: 'no'},
              new inquirer.Separator!].concat built-in-mappings!
  inquirer.prompt(questions).then (answers) ->
    if answers.mapping isnt 'no'
      create-builtin-config answers.mapping
      process.exit!

    create-custom-mapping answers.language