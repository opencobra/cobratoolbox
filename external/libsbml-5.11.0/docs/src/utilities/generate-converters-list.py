#!/usr/bin/env python
#
# @file   generate-converters-list.py
# @brief  Generate libsbml-converters.txt, a list of SBML converter classes
# @author Michael Hucka
# @date   Created 2013-12-19
#
# This program takes one argument, the file "class-list.txt" that is assumed to
# be created by the document-creation process prior to invoking this program.
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

import sys


def main(args):
    if len(args) != 2:
        print("Must be given one argument: the path to class-list.txt")
        sys.exit(1)

    filestream = open(args[1], 'r')
    lines = filestream.read().splitlines()
    filestream.close()

    classes = [name for name in lines if name.endswith('Converter')]
    # Skip the base class name.
    classes = filter(lambda x: x != 'SBMLConverter', classes)

    print('/**')
    print(' * @class doc_list_of_libsbml_converters')
    print(' * ')
    print(' * @par')
    print(' * @li ' + '\n * @li '.join(classes))
    # Make sure to close the list with the following 3 items.  The way that
    # swigdoc.py processes class definitions chops off the /** and */, which
    # leaves nothing for swigdoc.py's @li-matching regexp to terminate its
    # match.  The extra <p> followed by a blank line does it.
    print(' * <p>')
    print(' *')
    print(' */')


if __name__ == '__main__':
    main(sys.argv)
