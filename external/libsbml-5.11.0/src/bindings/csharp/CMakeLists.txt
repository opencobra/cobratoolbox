###############################################################################
# Description       : CMake build script for libSBML C# bindings
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


find_package(SWIG REQUIRED)
include(FindPythonInterp)

include(${SWIG_USE_FILE})

set(LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME "libsbmlcs" CACHE STRING
                       "The name of the native library file to generate. This can be changed to avoid conflicts with other applications using another version of the library.")
mark_as_advanced(LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME)


####################################################################
#
# create correct assembly information file
#
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/Properties/AssemblyInfo.cs.in"
  "${CMAKE_CURRENT_BINARY_DIR}/AssemblyInfo.cs"
  )

####################################################################
#
# generate files that include all packages:
#
# - local-downcast-extension.i

file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-extension-*.i")
update_ifile(
   "local-downcast-extension.i" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

# - local-downcast-namespaces.i
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-namespaces-*.i")
update_ifile(
   "local-downcast-namespaces.i" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

# - local-packages.i
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-packages-*.i")
update_ifile(
   "local-packages.i" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

# - local-downcast-converters.i
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-converters-*.i")
update_ifile(
   "local-downcast-converters.i" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

# remove conflicting copies of files, if they exist
foreach(conflict 
 ${CMAKE_CURRENT_SOURCE_DIR}/local-packages.i
 ${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-namespaces.i
 ${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-converters.i
 ${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-extension.i
)
  if (EXISTS ${conflict})
    file(REMOVE ${conflict})
  endif()
endforeach()

####################################################################
#
# determine local dependencies, so as to re-swig if one of them changed
#
file(GLOB SWIG_DEPENDENCIES
	${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/*.i
	${CMAKE_CURRENT_SOURCE_DIR}/../swig/*.i
	${CMAKE_CURRENT_SOURCE_DIR}/../swig/*.h
	)

#
# Remove SWIG wrappers if requested
#
if (LIBSBML_REMOVE_WRAPPERS)
  foreach(file
    ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/csdoc.i
  )
    if (EXISTS ${file})
      FILE(REMOVE ${file})
    endif()
  endforeach()
endif(LIBSBML_REMOVE_WRAPPERS)

####################################################################
#
# SWIG C# bindings
#
set(SWIG_EXTRA_FLAGS)
if(NOT UNIX)
	set(SWIG_EXTRA_FLAGS -DSWIGWIN -DSWIG_CSHARP_NO_WSTRING_HELPER)
endif()

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/swig-binding.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/swig-binding.cmake
	@ONLY
)

if (WITH_DOXYGEN AND NOT EXISTS "${PYTHON_EXECUTABLE}")
  message(FATAL_ERROR 
	"The csharp language bindings require PYTHON_EXECUTABLE to be set 
	 to the python command in order to build documentation."
  )
endif()

# munge argument lists to string, so that they can safely passed along
SET(SWIG_ARGS)
foreach(arg ${SWIG_EXTRA_ARGS} ${SWIG_EXTRA_FLAGS})
if (NOT UNIX)
  set(SWIG_ARGS "${SWIG_ARGS} ${arg}")
else()
  list(APPEND SWIG_ARGS ${arg})
endif()
endforeach()

SET(DOC_ARGS)
foreach(arg ${SWIG_SWIGDOCDEFINES})
if (NOT UNIX)
  set(DOC_ARGS "${DOC_ARGS} ${arg}")
else()
  list(APPEND DOC_ARGS ${arg})
endif()
endforeach()
 
# call a separate script for generating documentation / swiging the output 
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp
	       ${CMAKE_CURRENT_BINARY_DIR}/csharp-files/libsbml.cs
	       ${CMAKE_CURRENT_BINARY_DIR}/csharp-files/libsbmlPINVOKE.cs
		   ${CMAKE_CURRENT_BINARY_DIR}/csdoc.i
		   
	COMMAND "${CMAKE_COMMAND}"
	ARGS -DCUR_BIN_DIRECTORY=\"${CMAKE_CURRENT_BINARY_DIR}\"
		 -DBIN_DIRECTORY=\"${LIBSBML_ROOT_BINARY_DIR}\"
		 -DCUR_SRC_DIRECTORY=\"${CMAKE_CURRENT_SOURCE_DIR}\"
		 -DSRC_DIRECTORY=\"${LIBSBML_ROOT_SOURCE_DIR}\"
		 -DCMAKE_COMMAND=\"${CMAKE_COMMAND}\"
		 -DPYTHON_EXECUTABLE=\"${PYTHON_EXECUTABLE}\"
		 -DSWIG_SWIGDOCDEFINES=\"${DOC_ARGS}\"
		 -DSWIG_ARGS=\"${SWIG_ARGS}\"
		 -DSWIG_EXECUTABLE=\"${SWIG_EXECUTABLE}\"
		 -DWITH_DOXYGEN=\"${WITH_DOXYGEN}\"
		 -DLIB_NAME=\"${LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME}\"
		 -P "${CMAKE_CURRENT_BINARY_DIR}/swig-binding.cmake"
    
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/../swig/libsbml.i
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
            ${SWIG_DEPENDENCIES}
    COMMENT "Swig C# source"
)

add_custom_target(binding_csharp_swig ALL DEPENDS ${SWIG_DEPENDENCIES})

#
# Determine the csharp installation directory
#
set(CSHAPR_PACKAGE_INSTALL_DIR)
if (UNIX OR CYGWIN)
  set(CSHAPR_PACKAGE_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/mono/libsbmlcsP)
else()
  set(CSHAPR_PACKAGE_INSTALL_DIR ${MISC_PREFIX}bindings/csharp)
endif()

####################################################################
#
# Build native library
#

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../swig)
include_directories(BEFORE ${LIBSBML_ROOT_SOURCE_DIR}/src)
include_directories(BEFORE ${LIBSBML_ROOT_BINARY_DIR}/src)

if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)

add_library(binding_csharp_native_lib SHARED ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)
add_dependencies(binding_csharp_native_lib binding_csharp_swig)
if (UNIX)
# if name starts with 'lib' drop the prefix, otherwise we get 'liblibXXX'

set(UNIX_NATIVE_NAME "${LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME}")
string(LENGTH "${LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME}" length)
if (${length} GREATER 3)
	 string(SUBSTRING "${LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME}" 0 3 result)
	 if ("${result}" STREQUAL "lib")
	 	   math(EXPR length_minus_three "${length} - 3")
	 	   string(SUBSTRING "${LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME}" 3 ${length_minus_three} UNIX_NATIVE_NAME)
	 endif()
endif()
set_target_properties (binding_csharp_native_lib PROPERTIES OUTPUT_NAME "${UNIX_NATIVE_NAME}")
else()
set_target_properties (binding_csharp_native_lib PROPERTIES OUTPUT_NAME ${LIBSBML_CSHARP_BINDING_NATIVE_LIBRARY_NAME})
endif()
target_link_libraries(binding_csharp_native_lib ${LIBSBML_LIBRARY}-static)
INSTALL(TARGETS binding_csharp_native_lib
        DESTINATION ${CSHAPR_PACKAGE_INSTALL_DIR}
  )

####################################################################
#
# build managed library
#

ADD_CUSTOM_COMMAND(
	OUTPUT
		${CMAKE_CURRENT_BINARY_DIR}/libsbmlcsP.dll
		${CMAKE_CURRENT_BINARY_DIR}/TestRunner.exe
		${CMAKE_CURRENT_BINARY_DIR}/libsbmlcsP.xml

	COMMAND "${CMAKE_COMMAND}"
	ARGS -DCSHARP_EXTRA_ARGS=\"${CSHARP_EXTRA_ARGS}\"
		 -DCSHARP_COMPILER=\"${CSHARP_COMPILER}\"
		 -DBIN_DIRECTORY=\"${CMAKE_CURRENT_BINARY_DIR}\"
		 -DSRC_DIRECTORY=\"${CMAKE_CURRENT_SOURCE_DIR}\"
		 -P "${CMAKE_CURRENT_SOURCE_DIR}/compile-native-files.cmake"

	MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/../swig/libsbml.i"
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
			${CMAKE_CURRENT_SOURCE_DIR}/compile-native-files.cmake
			${CMAKE_CURRENT_BINARY_DIR}/csharp-files/libsbml.cs
	        ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp
	WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    COMMENT "Build csharp files"
	)

add_custom_target(binding_csharp_managed_lib ALL DEPENDS libsbmlcsP.dll)
add_dependencies(binding_csharp_managed_lib binding_csharp_swig)

INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libsbmlcsP.dll DESTINATION ${CSHAPR_PACKAGE_INSTALL_DIR})

####################################################################
#
# testing
#

if(WITH_CHECK)

file(TO_NATIVE_PATH ${CMAKE_CURRENT_BINARY_DIR}/libsbmlcsP.dll LIBSBML_LIB)
ADD_CUSTOM_COMMAND(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/TestRW.exe
    COMMAND "${CSHARP_COMPILER}"
    ARGS -r:${LIBSBML_LIB}
		-target:exe
		-out:TestRW.exe
		${CSHARP_EXTRA_ARGS}
		${CMAKE_CURRENT_SOURCE_DIR}${PATH_SEP}TestRW.cs
	MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/TestRW.cs
	DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libsbmlcsP.dll
		${CMAKE_CURRENT_SOURCE_DIR}/TestRunner.cs
		${CMAKE_CURRENT_SOURCE_DIR}/TestRW.cs
    COMMENT "Build C# TestRuner")


add_custom_target(binding_csharp_test_runner ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/TestRW.exe)
add_dependencies(binding_csharp_test_runner binding_csharp_managed_lib )

if(UNIX)
	add_test(
	  NAME test_csharp_bindings
	  COMMAND mono
	          ${CMAKE_CURRENT_BINARY_DIR}/TestRW.exe
			  ${LIBSBML_ROOT_SOURCE_DIR}/examples/sample-models/from-spec/level-2/
			  -p $<TARGET_FILE_DIR:binding_csharp_native_lib>)

	# to run the compiled tests
	add_test(
	  NAME test_csharp_bindings_full
      COMMAND mono
			${CMAKE_CURRENT_BINARY_DIR}/TestRunner.exe
			-d ${LIBSBML_ROOT_SOURCE_DIR}/src/sbml/test/test-data
			-l ${CMAKE_CURRENT_BINARY_DIR}/libsbmlcsP.dll
			-w ${CMAKE_CURRENT_SOURCE_DIR}
			-p $<TARGET_FILE_DIR:binding_csharp_native_lib>)

	if(APPLE)
		set_tests_properties(test_csharp_bindings PROPERTIES ENVIRONMENT "DYLD_LIBRARY_PATH=$<TARGET_FILE_DIR:binding_csharp_native_lib>:${CMAKE_CURRENT_BINARY_DIR}:$ENV{DYLD_LIBRARY_PATH}")
		set_tests_properties(test_csharp_bindings_full PROPERTIES ENVIRONMENT "DYLD_LIBRARY_PATH=$<TARGET_FILE_DIR:binding_csharp_native_lib>:${CMAKE_CURRENT_BINARY_DIR}:$ENV{DYLD_LIBRARY_PATH}")
	else()
		set_tests_properties(test_csharp_bindings PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=$<TARGET_FILE_DIR:binding_csharp_native_lib>:${CMAKE_CURRENT_BINARY_DIR}:$ENV{LD_LIBRARY_PATH}")
		set_tests_properties(test_csharp_bindings_full PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=$<TARGET_FILE_DIR:binding_csharp_native_lib>:${CMAKE_CURRENT_BINARY_DIR}:$ENV{LD_LIBRARY_PATH}")
	endif()
else()

	include(${LIBSBML_ROOT_SOURCE_DIR}/common.cmake)
	copy_files( ${LIBSBML_ROOT_SOURCE_DIR}/dependencies/bin/ ${CMAKE_CURRENT_BINARY_DIR} *.dll )

	add_test(NAME test_csharp_bindings
		COMMAND ${CMAKE_CURRENT_BINARY_DIR}/TestRW.exe ${LIBSBML_ROOT_SOURCE_DIR}/examples/sample-models/from-spec/level-2/
		-p $<TARGET_FILE_DIR:binding_csharp_native_lib>)

	#  to run the compiled tests
	add_test(NAME test_csharp_bindings_full
			COMMAND ${CMAKE_CURRENT_BINARY_DIR}/TestRunner.exe
			-d ${LIBSBML_ROOT_SOURCE_DIR}/src/sbml/test/test-data
			-l ${CMAKE_CURRENT_BINARY_DIR}/libsbmlcsP.dll
			-w ${CMAKE_CURRENT_SOURCE_DIR}
			-p $<TARGET_FILE_DIR:binding_csharp_native_lib>)
	
	# link again, this time against the dynamic librar, as this will reveal
	# any potential link errors (this library will not be distributed)
	#
	add_library(binding_csharp_native_dll_link_check SHARED ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)
	add_dependencies(binding_csharp_native_dll_link_check binding_csharp_swig)
	set_target_properties (binding_csharp_native_dll_link_check PROPERTIES OUTPUT_NAME "DllLinkCheck")
	target_link_libraries(binding_csharp_native_dll_link_check ${LIBSBML_LIBRARY})
	
endif()

endif()
