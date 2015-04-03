###############################################################################
#
# Description       : CMake build script for native NodeJS library
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

message("Creating: sbml.node")

# first ensure that all required variables are provided: 
#  
#  NODE_GYP_EXECUTABLE - path to node-gyp
#  NODEJS_EXECUTABLE   - path to node.js executable
#  PYTHON_EXECUTABLE   - path to python, that will be called by node-gyp
#  BIN_DIRECTORY       - path to the build dir, where binding.gyp.in was generated
#  LIBSBML_LIBRARY     - full path to the libsbml library to link against
#

if (NOT NODE_GYP_EXECUTABLE)
  message(FATAL_ERROR 
  "
       node-gyp is required to build the libSBML JS bindings. 
	   Please set the NODE_GYP_EXECUTABLE variable to the 
	   full location of node-gyp.
  "
  )
endif()

if (NOT PYTHON_EXECUTABLE)
  message(FATAL_ERROR 
  "
       Please specify the PYTHON_EXECUTABLE variable to a python 2 executable
	   compatible with node-gyp
  "
  )
endif()

if (NOT BIN_DIRECTORY)
  message(FATAL_ERROR 
  "
       Please specify the BIN_DIRECTORY variable
  "
  )
endif()

if (NOT LIBSBML_LIBRARY)
  message(FATAL_ERROR 
  "
       Please specify the LIBSBML_LIBRARY library to link against.
  "
  )
endif()

# create binding.gyp out of the generated binding.gyp.in, by writing the 
# library name inside
# 
file(READ ${BIN_DIRECTORY}/binding.gyp.in BINDING_CONTENT)
string(REPLACE "LIBSBML_LOCATION" ${LIBSBML_LIBRARY} BINDING_CONTENT ${BINDING_CONTENT})
file(WRITE ${BIN_DIRECTORY}/binding.gyp ${BINDING_CONTENT})

# if we have NODEJS_EXECUTABLE, prepend its path to the PATH, so it will be 
# called (needed to disambiguate on machines that use both 32bit and 64bit nodejs)
if (WIN32)
  if (NODEJS_EXECUTABLE)
    set(nodejs_dir)
	if("${CMAKE_VERSION}" VERSION_GREATER 2.8.11)
      get_filename_component(nodejs_dir ${NODEJS_EXECUTABLE} DIRECTORY)
	else()
      get_filename_component(nodejs_dir ${NODEJS_EXECUTABLE} PATH)
	endif()
    set(ENV{PATH} "${nodejs_dir};$ENV{PATH}")
  endif()
endif()

# finally compile the library
# 
set(ENV{PYTHON} ${PYTHON_EXECUTABLE}) 
execute_process(
    COMMAND "${NODE_GYP_EXECUTABLE}"
            "rebuild"
	        "${NODE_GYP_ARGS}"
	
	WORKING_DIRECTORY "${BIN_DIRECTORY}"
)

