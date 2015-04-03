#!/usr/bin/env python
#
# @file   libsbmlutils.py
# @brief  Common utility code used by some of our other Python programs.
# @author Michael Hucka
# @date   Created 2014-03-26
#
#<!---------------------------------------------------------------------------
# This file is part of libSBML.  Please visit http://sbml.org for more
# information about SBML, and the latest version of libSBML.
#
# Copyright (C) 2013-2014 jointly by the following organizations:
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
#     3. University of Heidelberg, Heidelberg, Germany
#
# Copyright (C) 2009-2013 jointly by the following organizations:
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
#
# Copyright (C) 2006-2008 by the California Institute of Technology,
#     Pasadena, CA, USA
#
# Copyright (C) 2002-2005 jointly by the following organizations:
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. Japan Science and Technology Agency, Japan
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation.  A copy of the license agreement is provided
# in the file named "LICENSE.txt" included with this software distribution
# and also available online as http://sbml.org/software/libsbml/license.html
#----------------------------------------------------------------------- -->*/

import os, re
from os.path import join

skip_dirs    = ['math-legacy', 'compress', 'test', '.deps', '.libs',
                'test-data', 'subdir']

skip_files   = ['extensiontypes.h', 'libsbml_wrap.h', 'libsbml_wrap-win.h',
                'dirent.h', 'CMakeLists.txt', 'README.txt', 'extern.h',
                'common-documentation.h', 'common-sbmlerror-codes.h']

skip_classes = ['is', 'endl', 'flush']

#
# find_classes(X)
#

def find_classes(arg, cplusplus = False, swig_too = False, enums_too = True):
    """List class declarations found in .h files.

    ARG can be a single directory or a list of files.  Returns a list of all
    classes found in all .h and (if swig_too=True) .i files in ARG, or if ARG
    is a directory, found recursively in files in ARG and its subdirectories.

    If cplusplus=True, it searches only for proper C++ declarations of
    classes and (if enums_too=True) enumerations; otherwise, it looks only
    for Doxygen-style @class and (if enums_too=True) @enum declarations in
    the comments of .h files (and if swig_too=True, in the contents of .i
    files).  It always skips classes whose names begin with 'doc_'.

    Enums are assumed to have names ending '_t'.  When enums_too=False, all
    classes whose names end in '_t' are omitted from the results.
    """

    if type(arg) is list:
        classes = [c for file in arg for c in classes_in_file(file, cplusplus, swig_too)]
    else:
        classes = classes_in_dir(arg, cplusplus, swig_too)
    if not enums_too:
        classes = [item for item in classes if not item.endswith('_t')]
    return cleanup(classes)


def classes_in_dir(dir, cplusplus, swig_too):
    classes = []
    for root, dirnames, found_files in os.walk(dir):
        dirname = os.path.split(root)[1]
        if dirname in skip_dirs:
            continue
        for tail in found_files:
            name = os.path.normcase(tail)
            if (not (name.endswith('.h') or name.endswith('.txt') \
                     or (swig_too and name.endswith('.i')))):
                continue
            if name.lower() in skip_files:
                continue
            path = os.path.join(root, tail)
            classes.append(classes_in_file(path, cplusplus, swig_too))
    return [item for sublist in classes for item in sublist]


def classes_in_file(filename, cplusplus, swig_too):
    stream = open(filename)
    classes = []
    if cplusplus:
        scanner = cplusplus_class_finder
    else:
        scanner = doxygen_class_finder
    if filename.endswith('.h') or filename.endswith('.txt'):
        classes = class_finder(stream, scanner)
    elif swig_too and filename.endswith('.i'):
        classes = class_finder(stream, swig_class_finder)
    stream.close()
    return classes


def class_finder(stream, scanner):
    classes = []
    isInternal = False
    for line in stream.readlines():
        if (line.find('@cond doxygenLibsbmlInternal') >= 0): isInternal = True
        if (line.find('@endcond') >= 0):                     isInternal = False
        if isInternal:
            continue
        found = scanner(line)
        if found:
            classes.append(found)
    return classes


def cplusplus_class_finder(line):
    if line.find(';') > 0:              # Skip forward class declarations.
        return None
    match = re.search(r'^class\s+(LIB[_A-Z]+\s+)?(\w+)', line)
    if match != None:
        return match.group(2)
    return None


def doxygen_class_finder(line):
    match = re.search('(@class|@enum)\s+(\w+)', line)
    if match != None:
        name = match.group(2)
        # Ignore documentation fragments pseudoclasses.
        if not name.startswith("doc_"):
            return name
    return None


def swig_class_finder(line):
    start = line.find('%template(')
    if start >= 0:
        end = line.find(')')
        return line[start + 10:end].strip()
    return None


def cleanup(classes):
    nullfree  = [item for item in classes if item]
    skipfree  = [item for item in nullfree if not item in skip_classes]
    return skipfree
