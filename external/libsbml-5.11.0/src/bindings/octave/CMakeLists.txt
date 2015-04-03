###############################################################################
#
# Description       : CMake build script for libSBML Octave bindings
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

if(WITH_OCTAVE)
SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}")
find_package(Octave)

if (NOT EXISTS "${MKOCTFILE_EXECUTABLE}")
	# fail if mkoctfile was not found
	message (FATAL_ERROR "The mkoctfile command is vital for building octave bindings. It was not found during configuration. Please manually specify MKOCTFILE_EXECUTABLE.")
endif()


# get location of library
get_property(sbml_location TARGET ${LIBSBML_LIBRARY} PROPERTY LOCATION)
get_filename_component(sbml_path ${sbml_location} PATH)
file(TO_CMAKE_PATH ${sbml_path} sbml_path)


# break up the libsbml library dependencies into paths and libraries
set(OCTAVE_EXTRA_LIBS)
set(OCTAVE_EXTRA_PATHS)
if (UNIX)
foreach(lib ${LIBSBML_LIBS})
	get_filename_component(name ${lib} NAME_WE)	
	get_filename_component(path ${lib} PATH)	
	string(REGEX REPLACE "lib" "" name "${name}")
	list(APPEND OCTAVE_EXTRA_LIBS -l${name})
	list(APPEND OCTAVE_EXTRA_PATHS -L${path})
endforeach()
endif()

# 
# Determine the octave installation directory
#
set(OCTAVE_PACKAGE_INSTALL_DIR)
if (UNIX OR CYGWIN) 
execute_process(COMMAND "${OCTAVE_CONFIG_EXECUTABLE}" -p CANONICAL_HOST_TYPE
    OUTPUT_VARIABLE OCTAVE_PLATFORM OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(OCTAVE_PACKAGE_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/octave/site/oct/${OCTAVE_PLATFORM})
else()
  set(OCTAVE_PACKAGE_INSTALL_DIR ${MISC_PREFIX}bindings/octave)
endif()
	

macro(build_octave_file fileName)
	# compile and link mex file
	ADD_CUSTOM_COMMAND(	
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.mex
		COMMAND "${CMAKE_COMMAND}"
		ARGS  -E remove ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.mex
		COMMAND "${MKOCTFILE_EXECUTABLE}"
		ARGS 
			-o ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.mex
			--mex
			-DUSE_OCTAVE		 
			-I${CMAKE_CURRENT_BINARY_DIR}/../../
			-I${CMAKE_CURRENT_SOURCE_DIR}/../../
			-I${LIBSBML_ROOT_SOURCE_DIR}/include
			${CMAKE_CURRENT_SOURCE_DIR}/../matlab/${fileName}.c
			-l${LIBSBML_LIBRARY}
			${OCTAVE_EXTRA_LIBS}
			${OCTAVE_EXTRA_PATHS}
			-L${sbml_path}
	
		MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/../matlab/${fileName}.c
		COMMENT "compile and link octave mex file: ${fileName}") 
	
	add_custom_target(binding_octave_${fileName} ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.mex ${LIBSBML_LIBRARY})
	add_dependencies(binding_octave_${fileName} ${LIBSBML_LIBRARY})
	
	# mark files
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.mex DESTINATION ${OCTAVE_PACKAGE_INSTALL_DIR} )

endmacro()

build_octave_file("TranslateSBML")
build_octave_file("OutputSBML")


foreach(mFile

    test.xml
    buildSBML.m
    CheckAndConvert.m  
    Contents.m
    ConvertFormulaToMathML.m
    installSBML.m
    isoctave.m
    isSBML_Model.m
    isFbcEnabled.m
    OutputSBML.m
    TranslateSBML.m
	
)

	install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../matlab/${mFile} DESTINATION ${OCTAVE_PACKAGE_INSTALL_DIR} )

endforeach()


if (WITH_CHECK)

	
	
	# copy test files
	file(GLOB files ${CMAKE_CURRENT_SOURCE_DIR}/../matlab/*.m)
	foreach(testfile ${files})
		file(COPY ${testfile} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
	endforeach()
	
	file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test)
	file(GLOB files ${CMAKE_CURRENT_SOURCE_DIR}/../matlab/test/*.m)
	list(REMOVE_ITEM files "${CMAKE_CURRENT_SOURCE_DIR}/../matlab/test/testReadFromFile9.m")
	foreach(testfile ${files})
		file(COPY ${testfile} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/test)
	endforeach()

	# this file needs to overwrite the matlab version!
	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../matlab/isFbcEnabled.m DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/test)
	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/test/testReadFromFile9.m DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/test)

	# copy test data
	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../matlab/test/test-data DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/test  )

	file(TO_NATIVE_PATH ${CMAKE_CURRENT_BINARY_DIR} bin_dir)

	add_test(
	  NAME test_octave_binding 
	  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/test
	  COMMAND "${OCTAVE_EXECUTABLE}" -p . -p .. -p ${bin_dir} --eval runTests)
	
	if(UNIX)
		if(APPLE)
			set_tests_properties(test_octave_binding PROPERTIES ENVIRONMENT "DYLD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../..:$ENV{DYLD_LIBRARY_PATH}")
		else()
			set_tests_properties(test_octave_binding PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../..:$ENV{LD_LIBRARY_PATH}")
		endif()
	else()
	    if(WIN32)
			STRING(REPLACE "\\;" ";" PATH_STRING " ${CMAKE_CURRENT_BINARY_DIR};${CMAKE_CURRENT_BINARY_DIR}/../..;$ENV{PATH}")
			STRING(REPLACE ";" "\\;" PATH_STRING "${PATH_STRING}")
			set_tests_properties(test_octave_binding PROPERTIES ENVIRONMENT "PATH=${PATH_STRING}")
		endif()
	endif()

	set_tests_properties(test_octave_binding PROPERTIES PASS_REGULAR_EXPRESSION "successful" )
	
	
endif()

endif()


