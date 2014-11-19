## @file    CMakeLists.txt
## @brief   CMake build script for example programs
## @author  Frank T. Bergmann
##
## <!--------------------------------------------------------------------------
## This file is part of libSBML.  Please visit http://sbml.org for more
## information about SBML, and the latest version of libSBML.
##
## Copyright (C) 2013-2014 jointly by the following organizations:
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##     3. University of Heidelberg, Heidelberg, Germany
##
## Copyright (C) 2009-2013 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##  
## Copyright (C) 2006-2008 by the California Institute of Technology,
##     Pasadena, CA, USA 
##  
## Copyright (C) 2002-2005 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. Japan Science and Technology Agency, Japan
## 
## This library is free software; you can redistribute it and/or modify it
## under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation.  A copy of the license agreement is provided
## in the file named "LICENSE.txt" included with this software distribution
## and also available online as http://sbml.org/software/libsbml/license.html
## ------------------------------------------------------------------------ -->

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(BEFORE ${LIBSBML_ROOT_SOURCE_DIR}/src)
include_directories(${LIBSBML_ROOT_SOURCE_DIR}/include)
include_directories(BEFORE ${LIBSBML_ROOT_BINARY_DIR}/src)


if (EXTRA_INCLUDE_DIRS) 
include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)

foreach(example 

	addCVTerms
	addCustomValidator
	addingEvidenceCodes_1
	addingEvidenceCodes_2
	addModelHistory
	appendAnnotation
	callExternalValidator
	convertSBML
	createExampleSBML
	echoSBML
	inferUnits
	inlineFunctionDefintions
	convertReactions
	getAllElementsWithNotes
	printAnnotation
	printMath
	printNotes
	printSBML
	printRegisteredPackages
	printSupported
	printUnits
	promoteParameters
	readSBML
	renameSId
	setIdFromNames
	setNamesFromIds
	stripPackage
	translateMath
	translateL3Math
	unsetAnnotation
	unsetNotes
	validateSBML
	
)
	add_executable(example_cpp_${example} ${example}.cpp util.c)
	set_target_properties(example_cpp_${example} PROPERTIES  OUTPUT_NAME ${example})
	target_link_libraries(example_cpp_${example} ${LIBSBML_LIBRARY}-static)
	
	if (WITH_LIBXML)
		target_link_libraries(example_cpp_${example} ${LIBXML_LIBRARY} ${EXTRA_LIBS})
	endif()

	if (WITH_ZLIB)
		target_link_libraries(example_cpp_${example} ${LIBZ_LIBRARY})
	endif(WITH_ZLIB)
	if (WITH_BZIP2)
		target_link_libraries(example_cpp_${example} ${LIBBZ_LIBRARY})
	endif(WITH_BZIP2)

endforeach()

if (WITH_LIBXML)
  include_directories(${LIBXML_INCLUDE_DIR})
  add_executable(example_cpp_rngvalidator rngvalidator.cpp util.c)
  set_target_properties(example_cpp_rngvalidator PROPERTIES  OUTPUT_NAME rngvalidator)
  target_link_libraries(example_cpp_rngvalidator ${LIBSBML_LIBRARY}-static)
  target_link_libraries(example_cpp_rngvalidator ${LIBXML_LIBRARY} ${EXTRA_LIBS})
  if (WITH_ZLIB)
    target_link_libraries(example_cpp_rngvalidator ${LIBZ_LIBRARY})
  endif(WITH_ZLIB)
  if (WITH_BZIP2)
    target_link_libraries(example_cpp_rngvalidator ${LIBBZ_LIBRARY})
  endif(WITH_BZIP2)
endif()
