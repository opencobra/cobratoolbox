#!/usr/bin/env python

import re
import sys

def getFunctionNames(filename):
    file = open(filename, 'r')
    functions = []

    for line in file.readlines():
        if re.search(r'\Adef ', line):
            functions.append(line[4:line.rfind('(')])

    file.close()
    return functions


def main (args):
    """Usage:
        pythondocpreprocessor.py sourcelibsbml.py outputlibsbml.py FILE FILE ...

    Each FILE is assumed to have the same name as a class (minus the .py
    file extension).  For each FILE, this program first removes the class
    definition from sourcelibsbml.py, appends the contents of FILE, and
    writes the result to outputlibsbml.py.  If FILE is empty, this has the
    effect of removing a class completely.  If FILE is a name that has
    equivalent in sourcelibsbml.py, the result is to add new content.

    Special case: the file libsbml.py is examined for function definitions
    to remove from the top level; it is not used as a class named 'libsbml'.
    """

    if len(sys.argv) < 4:
        print(main.__doc__)
        sys.exit(1)

    input     = open(args[1], 'r')
    output    = open(args[2], 'w')
    filenames = args[3:]

    contents  = ""

    # Remove classes and functions that are being replaced (or just
    # removed outright).

    classes   = []
    functions = []

    for f in filenames:
        if re.search('libsbml.py', f) != None:
            functions = getFunctionNames(f)
        else:
            classes.append(f[f.rfind('/') + 1 : f.rfind('.')])

    print ("Processing " + args[1])
    print ("Will remove the following classes: " + ", ".join(classes))
    print ("Will remove the following functions: " + ", ".join(functions))

    skipping = False
    for line in input:
        if skipping and re.search(r'\A\S', line):
            skipping = False
        if skipping == False:
            for c in classes:
                if re.search(r'\Aclass ' + c + '\([^)]+\):', line):
                    skipping = True
                    continue
        if skipping == False:
            for f in functions:
                if re.search(r'\Adef ' + f, line):
                    skipping = True
                    continue
        if skipping:
            continue
        else:
            contents += line

    # Remove classes and functions marked @internal

    newContents     = ""
    pattern         = r'^\s*(def|class) \w+\([^)]*\): ?\n +"""(.*?)"""'
    inInternalClass = False

    for m in re.finditer(pattern, contents, flags=re.MULTILINE|re.DOTALL):
        if m.group(1) == 'class':
            if re.search('@internal', m.group(2)) != None:
                # Notice we won't even write this class or its methods out.
                inInternalClass = True
            else:
                inInternalClass = False
                newContents += m.group(0) + '\n'
        else:                               # it's a def
            if not inInternalClass and re.search('@internal', m.group(2)) == None:
                newContents += m.group(0) + '\n'

    # Append the contents of files we're using for substitutions.

    print ("Will append the contents of the following files: " + " ".join(filenames))
    for f in filenames:
        newContents += open(f, 'r').read() + '\n'

    print ("Writing output to " + args[2])
    output.write(newContents)


if __name__ == '__main__':
  main(sys.argv)
