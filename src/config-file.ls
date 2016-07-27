require! {
  './helpers/error-message' : {abort}
  './helpers/file-type'
  'fs'
  'glob'
  'js-yaml' : yaml
  'livescript'
  'path'
  'prelude-ls' : {capitalize}
  'remove-value'
}


# Represents the Tertestrial config file
#
# Config files can be written in a variety of languages
# like JavaScript, CoffeeScript, LiveScript, etc
class ConfigFile

  ->
    config-file-name = @_get-config-file-name!
    compiler-method-name = "_compile#{capitalize file-type config-file-name}"
    unless @[compiler-method-name]
      abort "Config files of type '#{file-type config-file-name}' are not supported"
    config = @[compiler-method-name] fs.read-file-sync(config-file-name, 'utf8')
    @mappings = config.mappings |> @_standardize-mappings |> @_prepend-empty-mapping


  # Compiles the given LSON text, and returns a hash
  _compile-ls: (content) ->
    eval livescript.compile content, bare: yes, header: no

  _compile-yml: (content) ->
    yaml.safe-load content


  # Finds the Tertestrial config file and returns its name
  _get-config-file-name: ->
    config-files = glob.sync 'tertestrial.*'
    remove-value config-files, 'tertestrial.tmp'
    if config-files.length is 0
      abort "cannot find configuration file"
    if config-files.length > 1
      abort "multiple config files found: #{config-files.join ', '}"
    config-files[0]


  _load-internal-mapping: (filename) ->
    file-content = fs.read-file-sync path.join(__dirname, '..', 'mappings', "#{filename}.ls"), 'utf8'
    @_compile-ls file-content


  _prepend-empty-mapping: (mappings) ->
    mappings.unshift {}
    mappings


  _standardize-mappings: (mappings) ->
    switch mapping-type = typeof! mappings
      | 'Object'  =>  [mappings]
      | 'Array'   =>  mappings
      | 'String'  =>  @_standardize-mappings @_load-internal-mapping(mappings).mappings
      | _         =>  abort "unknown mapping type: #{mapping-type}"



module.exports = ConfigFile
