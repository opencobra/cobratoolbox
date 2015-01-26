#!/bin/sh
#
# This is a wrapper script which is used when building a mex file 
# of octave bindings.
# This script was originally implemented by Moriyoshi Koizumi.
#

SHAREDLIBEXT=so

args=
while test ! -z "$1"; do
    if test -f "$1" && expr "$1" : ".*lib.*\\.$SHAREDLIBEXT\$" > /dev/null; then
        args="$args '-L`dirname \"$1\"`' '-l`basename \"$1\" \".$SHAREDLIBEXT\" | sed -e 's/^lib//'`'"
    elif expr "$1" : "-f" > /dev/null; then
        CFLAGS="$CFLAG $1"
    else
        args="$args '$1'"
    fi
    shift
done

export CFLAGS
eval "exec $args"
