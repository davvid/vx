# vx

[![vx build status](https://api.travis-ci.org/davvid/vx.svg?branch=main)](https://travis-ci.org/davvid/vx)

vx is a simpler single-file [vex](https://github.com/sashahart/vex).

NOTE: a lot of this README was blatantly stolen from vex's README.

vx runs commands inside a virtualenv, like vex, but is implemented as a simple
single-file, dependency-free shell script.

vx is a simpler "vex", which itself is an alternative to virtualenv's
`source <path>/bin/activate` and `deactivate`.

The big difference is that, instead of modifying your shell environment
(`source <path>/bin/activate` + `deactivate`), the specified command is
run in a new environment where the virtualenv is active; the current shell is
left unchanged.

## Differences from Vex

The main difference between vx and vex are that vx ONLY supports
the following usage:

    vx <path> <command>

This is equivalent to the following vex command:

    vex --path <path> <command>

vx is simple and only handles virtualenv paths.

The main improvements over vex are that python's startup overhead is avoided,
and installation is simpler.  See the "Caveats" section for more details.

## How to install vx

Copy or symlink vx somewhere in your `$PATH`, e.g. `~/bin`, `~/.local/bin`,
or `/usr/local/bin`.  Alternatively, copy vx into your project.
vx is a single-file shell script with no external dependencies.

Running "make install" installs to `$HOME` by default (`~/bin/vx`).
Specify `prefix` to install into a specific installation prefix:

        make prefix=/usr/local install

## Examples

vx works with any command.

    vx <path> bash
        Launch a bash shell with the virtualenv at <path> activated in it.
        To deactivate, just exit the shell (using "exit" or Ctrl-D).

    vx <path> python
        Launch a Python interpreter inside the virtualenv at <path>.

    vx <path> which python
        Verify the path to python from inside the virtualenv at <path>.

    vx <path> pip freeze
        See what's installed inside the virtualenv at <path>.

    vx <path> pip install ipython
        Install ipython inside the virtualenv at <path>.

    vx <path> ipython
        Launch ipython inside the virtualenv at <path>.

vx can also be used to escape out of an active virtualenv.

    vx --reset <command>

## How vx works

vx runs any command from within a virtualenv, eliminating the need to
modify your current shell environment.

To know why this is different, you have to understand a little about how
virtualenv normally works.

The normal way people use a virtualenv (other than virtualenvwrapper, which
does this for them) is to open a shell and source a file called
`<path>/bin/activate`.

Sourcing this shell script modifies the environment in the current shell.
It saves the old values and sets up a shell function named `deactivate`
which restores those old values. When you run `deactivate` it restores
its saved values.

This is also the way virtualenvwrapper's `workon` functions - after all, it
is a wrapper for virtualenv.

If you want to use a virtualenv inside a script you probably don't use
activate, though, you just run the python that is inside the virtualenv's
bin/ directory.

The way virtualenv's activate works isn't elegant, but it usually works fine.
It's just specific to the shell, and sometimes gets a little fiddly because of
the decision to modify the current shell environment.

The principle of vx is much simpler, and it doesn't care what shell you
use, because it does not modify the current environment. It only sets up the
environment of the new process, and those environment settings go away
when the process does.  Thus, no `deactivate` or restoration of environment is
necessary.

For example, if you run `vx <path> bash` then that bash shell has the right
environment setup, but specifically "deactivating the virtualenv" is
unnecessary; the virtualenv "deactivates" when the process ends,
e.g. if you use `exit` or Ctrl-D as normal to leave bash. That's just
an example with bash, it works the same with anything.

## Caveats

Don't be surprised if `vx <path> sudo bash` results in a shell that doesn't use
your virtualenv. Safe sudo policy often controls the environment, notably as
a default on Debian and Ubuntu. It's better not to mess with this policy,
especially if you knew little enough that you wondered why it didn't work.
As a workaround, you can use this:

    sudo env PATH="$PATH" vx <path> bash

vex's README has a caveat about it being slow if someone does something crazy
like running vex a milliion times in a loop.  vx __does not__ have this caveat.
vx is a single-file shell script and does not incur python's startup overhead,
so its startup time is typically 8~10 times faster than vex.

Mind the results of asking to run commands with shell variables in them.
For example, you might expect this to print 'foo':

    vx <path> echo $VIRTUAL_ENV

The reason it doesn't is that your current shell is interpreting `$VIRTUAL_ENV`
even before vx gets it or can pass it to the subprocess. You could quote it:

    vx <path> echo '$VIRTUAL_ENV'

but then it literally prints `$VIRTUAL_ENV`, not the shell evaluation of the
variable, because that isn't the job of vx. That's a job for `/bin/sh` to do.

    vx <path> sh -c 'echo $VIRTUAL_ENV'
