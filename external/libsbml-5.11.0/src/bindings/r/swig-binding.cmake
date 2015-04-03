###############################################################################
#
# Description       : CMake build script for swigging the R bindings
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

# separate munged arguments
separate_arguments(SWIG_ARGS)

#
# Remove SWIG wrappers if requested
#
if (LIBSBML_REMOVE_WRAPPERS)
 foreach(file 
    ${CUR_BIN_DIRECTORY}/libsbml_wrap.cpp
    ${CUR_BIN_DIRECTORY}/libSBML.R
  )
    if (EXISTS ${file})
      FILE(REMOVE ${file})
    endif()
  endforeach()
endif()

# execute swig
execute_process(

    COMMAND "${SWIG_EXECUTABLE}"
         -I${CUR_SRC_DIRECTORY}/../swig/
         -I${BIN_DIRECTORY}/src
         -I${SRC_DIRECTORY}/src
         -I${SRC_DIRECTORY}/include
         -I${CUR_SRC_DIRECTORY}
         -c++
         -r
         ${SWIG_ARGS}
         -o ${CUR_BIN_DIRECTORY}/libsbml_wrap.cpp
         ${CUR_SRC_DIRECTORY}/libsbml.i

    WORKING_DIRECTORY "${CUR_BIN_DIRECTORY}"
    ERROR_VARIABLE  VAR_ERROR
    OUTPUT_VARIABLE OUT_ERROR
)

if (VAR_ERROR)
  message(${VAR_ERROR})
endif()
