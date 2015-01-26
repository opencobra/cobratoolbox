# 
# Description:  Test the version of SWIG we were configured with
# First Author:	Michael Hucka <mhucka@caltech.edu>
# Organization: California Institute of Technology
#
# -----------------------------------------------------------------------------
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
# -----------------------------------------------------------------------------

SWIG="swig"
NEED="2.0.0"

if test "$SWIG" = "no"; then
  # This means --with-swig was given with an explicit argument/path, but
  # when configure ran, it didn't actually find a swig program at that
  # location.  That wouldn't matter if we never needed swig, but if this
  # script (chk_swig_version.sh) is getting invoked, it means we need it.

  echo
  echo "libSBML was configured using --with-swig=SOMETHING, but the directory"
  echo "SOMETHING/bin does not appear to contain a runnable 'swig' program."
  echo "The current build situation requires 'swig' with version $NEED"
  echo "or later.  Please re-run configure using appropriate corrections to"
  echo "value of the argument given to --with-swig, and then re-make."
  echo
  exit 1;
fi

if ! ($SWIG -version > /dev/null 2>&1); then
  echo 
  echo One or more of the dependencies required to compile a file in the
  echo libSBML language bindings has changed, but libSBML cannot find the
  echo program \'swig\' and thus cannot proceed.  Please re-run the libSBML
  echo \'configure\' program using the --with-swig option to indicate where
  echo the configure program can find \'swig\' version $NEED or later.
  echo 
  exit 1;
fi

rx=`echo $NEED | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
ry=`echo $NEED | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
rz=`echo $NEED | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`

version=`"$SWIG" -version 2>&1`

sx=`echo $version | sed -e 's/SWIG Version \([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
sy=`echo $version | sed -e 's/SWIG Version \([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
sz=`echo $version | sed -e 's/SWIG Version \([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`

if test $sx -gt $rx \
    || (test $sx -eq $rx && test $sy -gt $ry) \
    || (test $sx -eq $rx && test $sy -eq $ry && test $sz -ge $rz); then
    exit 0;
else
  echo 
  echo One or more of the dependencies required to compile a file in the
  echo libSBML language bindings has changed, but the version of \'swig\'
  echo found \($sx.$sy.$sz\) by the libSBML build system is too old.  Please
  echo re-run the libSBML \'configure\' program using the --with-swig
  echo option to indicate where the configure program can find \'swig\'
  echo version $NEED or later.
  echo 
  exit 1;
fi
