# Carrousel

[![Gem Version](https://badge.fury.io/rb/carrousel.png)](http://badge.fury.io/rb/carrousel)
[![carrousel API Documentation](https://www.omniref.com/ruby/gems/carrousel.png)](https://www.omniref.com/ruby/gems/carrousel)

The Carrousel gem is a command line utility for running a single command on
multiple targets. Carrousel tracks which commands have succeeded or failed
based on the return of the system call, and sends failed jobs to the back of
the line to be tried again later.

## Installation

Add this line to your application's Gemfile:

    gem 'carrousel'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carrousel

## Usage

The most basic use case for Carrousel is to give it a command and a list of
items as command line arguments:

    $ carrousel -c 'echo' foo bar baz

In addition to passing in arguments on the command line, you can also pass them
in a file. These will be in addition to anything on the command line:

    $ carrousel -c 'echo' -l things-to-echo.txt foo bar baz

While running, carrousel will track it's progress in a carrousel runner status
file. This file is stored in the present working directory. If you need to kill
carrousel for any reason, you can pick up where you left off by passing the
status file into carrousel. The status file will save your completed items,
incompleted items, and the command used. The file will always be of the form
~/PWD/.carrousel\_runner\_status\_XXXXXXX. The following example kills the echo
carrousel and resumes it using a carrousel runner status file:

    $ carrousel -c 'echo' foo bar baz
    ... CTRL-C to kill this for some reason ...
    $ carrousel -s .carrousel_runner_status_130b02b


Finally, you can run jobs concurrently with the '-j' option:

    $ carrousel -c "ruby -e 'sleep ARGV.first.to_i'" 10 1 9 2 8 3 7 4 6 5 --verbose -j3
    <10> Executing command: ruby -e 'sleep ARGV.first.to_i' 10
    <1> Executing command: ruby -e 'sleep ARGV.first.to_i' 1
    <9> Executing command: ruby -e 'sleep ARGV.first.to_i' 9
    <1> System response: true
    <2> Executing command: ruby -e 'sleep ARGV.first.to_i' 2
    <2> System response: true
    <8> Executing command: ruby -e 'sleep ARGV.first.to_i' 8
    <9> System response: true
    <3> Executing command: ruby -e 'sleep ARGV.first.to_i' 3
    <10> System response: true
    <7> Executing command: ruby -e 'sleep ARGV.first.to_i' 7
    <8> System response: true
    <4> Executing command: ruby -e 'sleep ARGV.first.to_i' 4
    <3> System response: true
    <6> Executing command: ruby -e 'sleep ARGV.first.to_i' 6
    <4> System response: true
    <5> Executing command: ruby -e 'sleep ARGV.first.to_i' 5
    <7> System response: true
    <6> System response: true
    <5> System response: true
  

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
