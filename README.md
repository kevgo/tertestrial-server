# Tertestrial Server

[![CircleCI](https://circleci.com/gh/Originate/tertestrial-server.svg?style=shield)](https://circleci.com/gh/Originate/tertestrial-server)
[![Dependency Status](https://david-dm.org/Originate/tertestrial-server.svg)](https://david-dm.org/Originate/tertestrial-server)
[![devDependency Status](https://david-dm.org/Originate/tertestrial-server/dev-status.svg)](https://david-dm.org/Originate/tertestrial-server#info=devDependencies)

_Runs the currently relevant test while coding._

Tertestrial runs configurable tasks on files or parts of files.
Tasks are triggered by hotkeys from within your code editor,
or automatically on file save,
and run in a separate terminal window outside of your editor.
A common application for this is
running a particular unit test that is currently driving your development,
i.e. which you want to make green,
as part of test-driven development.
With Tertestrial you can do this with an absolute minimum of key presses,
distractions, slowdown from unnecessary test runs,
and without having to leave your text editor.

<a href="https://youtu.be/pxrES6xQlxo" target="_blank">
  <img src="documentation/tertestrial_video_1.png" width="480" height="269">
</a>

Tertestrial works with all test frameworks
and any text editor with a [Tertestrial plugin](#editor-plugins).
It comes with a set of built-in configurations for common frameworks
that allow you to get started using it right away.


## How it works

Tertestrial consists of a server (in this repository)
and a number of editor plugins.
The editor plugins send commands to the server
via a named pipe `.tertestrial.tmp` in the directory where you start the server
(typically the base directory of the code base you are working on).
Tertestrial removes this pipe when stopping.


## Installation

* install [Node.js](https://nodejs.org/en)

* install the Tertestrial server:

  ```
  npm i -g tertestrial
  ```

* install the [Tertestrial plugin for your editor](#editor-plugins)

* add `.tertestrial.tmp` to your
  [global gitignore](https://help.github.com/articles/ignoring-files/#create-a-global-gitignore).


## Creating a configuration file

To use Tertestrial with a code base,
run `tertestrial setup` in the root directory of that code base.
This generates a configuration file
that tells Tertestrial
what to do with the different types of files in your project.
The setup script asks whether you want to use one of the built-in configurations
or make your own.


### Built-in configurations

If you select a built-in configuration,
you are done with the setup and can [start using Tertestrial](#running-tertestrial).


### Custom configurations

Editor plugins send simple JSON-encoded messages
that define what the user wants Tertestrial to do.
What keys and values they contain depends on your use case,
and how your editor plugin works.
As an example, here are the messages sent by
[Tertestrial-Vim](https://github.com/originate/tertestrial-vim):

- when the user wants to run the current action on the whole code base

  ```json
  {}
  ```

- when the user wants to run the current action on the given file

  ```json
  {"filename": "foo.js"}
  ```

- when the user wants to run the current action on the given line at the given file:

  ```json
  {"filename": "foo.js", "line": 3}
  ```

Tertestrial's configuration file (`tertestrial.yml`)
defines how Tertestrial should handle these messages.
To do that, it defines a number of actions.
These actions consist of:
- a `match` block that has a structure comparable to commands,
  but with regular expressions as placeholders.
  An action must match an incoming message precisely in order to be run.
  Only the most specifically matching action is executed.
- a `command` block that contains the console command that this action performs

Below is an example configuration file
for JavaScript developers
who use [Mocha](https://mochajs.org) for unit testing
and [Cucumber-JS](https://github.com/cucumber/cucumber-js) for end-to-end tests:

__tertestrial.yml__
```yml
actions:

  # Here we define what to do with files that have the extension ".feature"
  - match:
      filename: '\.feature$'
    command: 'cucumber-js {{filename}}'

  # Here we define how to run just a test at the given line
  # in files with the extension ".feature"
  - match:
      filename: '\.feature$'
      line: '\d+'
    command: 'cucumber-js {{filename}}:{{line}}'

  # Here we define what to do with files that have the extension ".js"
  - match:
      filename: '\.js$'
    command: 'mocha {{filename}}'
```

The commands to run are specified via
<a href="https://en.wikipedia.org/wiki/Mustache_(template_system)#Examples)">Mustache</a> templates.

When you tell the setup wizard that you want to create your own custom configuration,
it sets up the config file pre-populated with a built-in configuration of your choice
as a starting point for your customizations.


### Multiple action sets

Tertestrial allows to define several sets of actions
and switch between them at runtime.
An example is to have one action set for running tests using a real browser
and another action set to run them using a faster headless browser.

__tertestrial.yml__

```yml
actions:

  - headless:

      - match:
          filename: '\.feature$'
        command: 'TEST_PLATFORM=headless cucumber-js {{filename}}'

      - match:
          filename: '\.feature$'
          line: '\d+'
        command: 'TEST_PLATFORM=headless cucumber-js {{filename}}:{{line}}'

  - firefox:

      - match:
          filename: '\.feature$'
        command: 'TEST_PLATFORM=firefox cucumber-js {{filename}}'

      - match:
          filename: '\.feature$'
          line: '\d+'
        command: 'TEST_PLATFORM=firefox cucumber-js {{filename}}:{{line}}'
```

When Tertestrial starts, in activates the first action set.
In this example, it means if you tell it to test a file,
it will do so using the headless browser.
When you switch to the second action set,
it well test files using Firefox as the browser.


### Submitting commonly used configurations

If you have created a good config file
that you think should ship with Tertestrial,
please submit a PR that adds a file with your configuration to
[the "actions" folder](https://github.com/Originate/tertestrial-server/tree/master/actions),
matching the structure of the other files there.


## Running tertestrial

* align your text editor and terminal so that you see both at the same time
  (for example side by side)
* in the terminal, start `tertestrial` in the base directory of your code base
* in the text editor, send some commands using the tertestrial editor plugin
* watch your tests run in your terminal

To end the server, press __ctrl-c__ in the terminal.

__Pro tip:__ if you start tertestrial in the background by running `tertestrial &`,
you can see all test output,
and your terminal remains interactive,
i.e. you can keep running other commands there as well.
Just start typing in the terminal to see your command prompt.
To exit the Tertestrial server in this case,
run `fg` to bring tertestrial back into the foreground,
then press __ctrl-c__.


## Editor plugins

* [Vim](https://github.com/Originate/tertestrial-vim)
* [Emacs](https://github.com/dmh43/emacs-tertestrial)
* [Atom](https://github.com/charlierudolph/tertestrial-atom)


## Create your own editor plugin

Making your own editor plugin is super easy.
All your plugin has to do is be triggered somehow (ideally via hotkeys)
and write (append) the command to execute
as a JSON string into the existing file `.tertestrial.tmp`:

In addition to your [application-specific commands](#custom-configurations),
your editor plugin needs to support these built-in infrastructure messages:

- switching to a different [action set](#multiple-action-sets) (for example action set #2):

  ```json
  {"actionSet": 2}
  ```

- re-run the last test:

  ```json
  {"repeatLastTest": true}
  ```


## Credits

This software is based on an idea described by Gary Bernhard in his excellent
[Destroy All Software screencasts](https://www.destroyallsoftware.com/screencasts/catalog/running-tests-asynchronously).
If you find this software useful,
subscribe to Gary's talks and presentations
for more of his cool ideas!


## Development

see our [developer documentation](CONTRIBUTING.md).
