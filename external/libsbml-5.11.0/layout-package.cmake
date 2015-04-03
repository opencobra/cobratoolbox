###############################################################################
#
# Description       : CMake configuration for SBML Level 3 Layout package
# Original author(s): Frank Bergmann <fbergman@caltech.edu>
# Organization      : California Institute of Technology
#
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
#
###############################################################################

option(ENABLE_LAYOUT
"Enable libSBML support for the SBML Level 3 Graphical Layout ('layout') package." OFF)

# provide summary status                                    =
list(APPEND LIBSBML_PACKAGE_SUMMARY "SBML 'layout' package  = ${ENABLE_LAYOUT}")

if(ENABLE_LAYOUT)
	add_definitions( -DUSE_LAYOUT )
	set(LIBSBML_PACKAGE_INCLUDES ${LIBSBML_PACKAGE_INCLUDES} "LIBSBML_HAS_PACKAGE_LAYOUT")
	list(APPEND SWIG_EXTRA_ARGS -DUSE_LAYOUT)	
	list(APPEND SWIG_SWIGDOCDEFINES --define USE_LAYOUT)
endif()
