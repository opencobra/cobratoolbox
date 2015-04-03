#!/usr/bin/env python
#
# @file    generate-extensions-summary.py
# @brief   Create a page summarizing libSBML L3 extensions for Java
# @author  Michael Hucka
#
# Usage:
#   generate-extensions-summary.py PATH-TO-PACKAGE-SUMMARY.html > file.html
#
# where
#   PATH-TO-PACKAGE-SUMMARY.html is the path to "package-summary.html"
#   produced by Javadoc
#
# This program rummages through the package-summary.html file produced by
# default by Javadoc (where "package" in Java's case has nothing to do with
# SBML L3 packages).  It looks for Java classes tagged in a certain way due
# to the rest of our documentation generation process, and outputs the
# body of a file list the libSBML package extensions for each L3 package.
#
# <!--------------------------------------------------------------------------
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
# ---------------------------------------------------------------------- -->*/

import os, sys, re
from os.path import join


header_template = '''
<p>SBML Level&nbsp;3 introduced a modular architecture, in which SBML
Level&nbsp;3 Core is usable in its own right (much like SBML Levels&nbsp;1
and&nbsp;2 before it), and optional SBML Level&nbsp;3 Packages add features
to this Core. To support this architecture, libSBML is itself divided into a
core libSBML and optional extensions. Core libSBML corresponds to the
features of SBML Levels&nbsp;1 to&nbsp;3 Core; they are always available, and
do not require applications to understand more than the SBML Levels&nbsp;1
to&nbsp;3 Core specifications. By contrast, the libSBML extensions are
separate plug-ins that each implement support for a given SBML Level&nbsp;3
package. There is a libSBML extension that implements support for the SBML
Level&nbsp;3 Hierarchical Model Composition package, another that implements
support for the SBML Level&nbsp;3 Flux Balance Constraints package, and so
on.  (Note that the SBML &ldquo;packages&rdquo; are not the same thing as
Java packages; this is an unfortunate and potentially confusing name
collision.  LibSBML does <em>not</em> use Java packages to implement SBML
packages.)</p>

<p> Not all possible SBML Level&nbsp;3 package specifications have been finalized
by the SBML community at this time. The stable releases of libSBML only
include the extensions for officially-released package specifications. The
rest of this page lists the libSBML extension packages for SBML Level&nbsp;3
available in the libSBML %%version%% Java interface.</p>
'''


section_start_template = '''
<table style="margin-top: 1.5em" border="1" width="100%" cellpadding="3" cellspacing="0" summary="">
<tr bgcolor="#ccccff" class="TableHeadingColor">
<th align="left" colspan="2"><font size="+2">
<b>Extension for SBML Level&nbsp;3 package '{}'</b></font></th>
</tr>
'''

entry_template = '''
<tr bgcolor="white" class="TableRowColor">
<td width="40%"><b><a href="org/sbml/libsbml/{}.html" title="class in org.sbml.libsbml">{}</a></b></td>
<td><span class='pkg-marker pkg-color-{}'><a href='group__{}.html'>{}</a></span> {}</td>
</tr>
'''

section_end_template = '''
</table>
&nbsp;

<p>
'''


def main(args):
    if len(args) != 2:
      print ("Must be given one argument: the path to package-summary.html")
      sys.exit(1)

    # Read the lines of the file into a string variable.
    with open(args[1]) as file:
        lines = ''.join([line.replace('\n', '') for line in file.readlines()])

    # Gather the package class data.  The next regexp will pull out
    # the class name, the package name, and a class description, in
    # that order.  The re.findall(...) will create a list of tuples.
    regexp = r'class in org.sbml.libsbml">\s*(\w+)\s*</A></B></TD>' \
             + r'\s*<TD><span class=[\'"]pkg-marker pkg-color-\w+[\'"]>' \
             + r'<a href=[\'"]group__\w+.html[\'"]>(\w+)</a></span>\s*(.+?)\s*</TD>'
    tuples = re.findall(regexp, lines, re.DOTALL)
    found_pkgs = sorted(list(set([entry[1] for entry in tuples])))

    # Now let's write some output, starting with lead-in text.
    print (header_template)

    for pkg in found_pkgs:
        print (section_start_template.format(pkg))
        class_tuples = [tuple for tuple in tuples if tuple[1] == pkg]
        for c in class_tuples:
            print (entry_template.format(c[0], c[0], pkg, pkg, pkg, c[2]))
        print (section_end_template)


if __name__ == '__main__':
  main(sys.argv)

