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

If you would like there to be some sort of delay between individual jobs, you
can specify that with a delay argument. The following example inserts a 30
second delay between each echo command:

    $ carrousel -c 'echo' --delay 30 foo bar baz
  

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
