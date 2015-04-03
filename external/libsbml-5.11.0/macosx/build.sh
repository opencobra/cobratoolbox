#!/bin/sh -e
# macosx/build.sh.  Generated from build.sh.in by configure.
#
# Filename    : build.sh.in
# Description : This script creates a package file (.dmg file) for MacOSX.
# Author(s)   : Akira Funahashi, Michael Hucka
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

OSX_MAJOR_VER=`uname -r | cut -d'.' -f1`
if expr ${OSX_MAJOR_VER} \>= 12 | grep -q 1; then
  MACOS="mountainlion"
elif expr ${OSX_MAJOR_VER} \>= 11 | grep -q 1; then
  MACOS="lion"
elif expr ${OSX_MAJOR_VER} \>= 10 | grep -q 1; then
  MACOS="snowleopard"
else
  MACOS="leopard"
fi

DISKDIR=disk-image
PKGNAME=libSBML-5.11.0-libxml2-${MACOS}.pkg
DMGBASE=libsbml-5.11.0-libxml2
DMGNAME=${DMGBASE}-macosx-${MACOS}.dmg
DMGFINAL=../${DMGNAME}

if ! test -e ${PKGNAME}; then
  echo "**** ERROR: ${PKGNAME} does not exist -- nothing to do."
  exit 1
fi

if test -d ${DISKDIR}; then
  if test -d ${DISKDIR}-previous; then
    echo "Directory '${DISKDIR}-previous' exists; deleting it.  Hope that's okay."
    /bin/rm -rf ${DISKDIR}-previous
  fi
  echo "Moving previous copy of '${DISKDIR}' to '${DISKDIR}-previous'."
  mv -f ${DISKDIR} ${DISKDIR}-previous
fi

mkdir ${DISKDIR}
cp ${PKGNAME}           ${DISKDIR}
cp resources/README.txt ${DISKDIR}

mkdir ${DISKDIR}/docs
cp ../AUTHORS.txt  ${DISKDIR}/docs
cp ../COPYING.html ${DISKDIR}/docs
cp ../COPYING.txt  ${DISKDIR}/docs
cp ../FUNDING.txt  ${DISKDIR}/docs
cp ../LICENSE.html ${DISKDIR}/docs
cp ../LICENSE.txt  ${DISKDIR}/docs
cp ../NEWS.txt     ${DISKDIR}/docs
cp ../OLD_NEWS.txt ${DISKDIR}/docs
cp ../README.txt   ${DISKDIR}/docs
cp ../VERSION.txt  ${DISKDIR}/docs

/usr/bin/hdiutil create -ov -fs HFSX -layout SPUD -format UDZO \
		 -volname ${DMGBASE} -srcfolder ${DISKDIR} \
		 -imagekey zlib-level=9 -scrub ${DMGFINAL}

echo ""
echo "Done creating ${DMGFINAL}."
echo ""
