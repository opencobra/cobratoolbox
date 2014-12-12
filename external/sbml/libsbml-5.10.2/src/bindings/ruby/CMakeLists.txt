###############################################################################
#
# Description       : CMake build script for libSBML Ruby bindings
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
include(${SWIG_USE_FILE})
include(FindRuby)


####################################################################
#
# determine local dependencies, so as to re-swig if one of them changed
# 

file(GLOB SWIG_DEPENDENCIES 
	${CMAKE_CURRENT_SOURCE_DIR}/*.i 
	${CMAKE_CURRENT_SOURCE_DIR}/*.h 
	${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/../swig/*.i
	${CMAKE_CURRENT_SOURCE_DIR}/../swig/*.h
	)

####################################################################
#
# generate files that include all packages: 
#


# - local-packages.i
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-*.i")
list(REMOVE_ITEM DOWNCAST_EXTENSION "local-packages.i")
# - local-packages.i
update_ifile(
   "local-packages.i" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

# - local-downcast.cpp
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-packages-*.cpp")
update_cfile(
   "local-downcast.cpp" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

# - local-downcast-extension.cpp
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-extension-*.cpp")
update_cfile(
   "local-downcast-extension.cpp" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}" 
)

# - local-downcast-namespaces.cpp
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-namespaces-*.cpp")
update_cfile(
   "local-downcast-namespaces.cpp" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

# - local-downcast-plugins.cpp
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-plugins-*.cpp")
update_cfile(
   "local-downcast-plugins.cpp" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)


# - local-downcast-converters.cpp
file(GLOB DOWNCAST_EXTENSION RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${CMAKE_CURRENT_SOURCE_DIR}/local-downcast-converters-*.cpp")
update_cfile(
   "local-downcast-converters.cpp" 
   ${CMAKE_CURRENT_BINARY_DIR} 
   "${DOWNCAST_EXTENSION}"
)

#
# Remove SWIG wrappers if requested
#
if (LIBSBML_REMOVE_WRAPPERS)
  foreach(file 
    ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp
  )
    if (EXISTS ${file})
      FILE(REMOVE ${file})
    endif()
  endforeach()
endif(LIBSBML_REMOVE_WRAPPERS)

ADD_CUSTOM_COMMAND(	
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp
    COMMAND "${SWIG_EXECUTABLE}"
    ARGS	-I${CMAKE_CURRENT_SOURCE_DIR}/../swig/
			-I${CMAKE_CURRENT_SOURCE_DIR} 
			-I${LIBSBML_ROOT_BINARY_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/include
			-c++
			-ruby		
			${SWIG_EXTRA_ARGS}		 
			-o ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp 
			${CMAKE_CURRENT_SOURCE_DIR}/libsbml.i
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/libsbml.i
	DEPENDS ${SWIG_DEPENDENCIES}
    COMMENT "Swig Ruby source") 

add_custom_target(binding_ruby_swig ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)

	
####################################################################
#
# Build native library
#

if(WIN32)
	add_definitions(-DNT=1 -DIMPORT)
endif()
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../swig)
include_directories(${LIBSBML_ROOT_SOURCE_DIR}/include)
include_directories(${RUBY_INCLUDE_DIRS})
include_directories(${RUBY_HDR_DIR})
include_directories(BEFORE ${LIBSBML_ROOT_BINARY_DIR}/src)
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR})

if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)


add_library(binding_ruby_lib SHARED ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)
add_dependencies(binding_ruby_lib binding_ruby_swig)

# 
# Determine the ruby installation directory
#
set(RUBY_PACKAGE_INSTALL_DIR)
if (UNIX OR CYGWIN) 
  execute_process(COMMAND "${RUBY_EXECUTABLE}" -e "print RUBY_PLATFORM"
    OUTPUT_VARIABLE RUBY_PLATFORM)
  set(RUBY_PACKAGE_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/ruby/site_ruby/${RUBY_VERSION_MAJOR}.${RUBY_VERSION_MINOR}/${RUBY_PLATFORM})
else()
  set(RUBY_PACKAGE_INSTALL_DIR ${MISC_PREFIX}bindings/ruby)
endif()

set_target_properties (binding_ruby_lib PROPERTIES OUTPUT_NAME "libSBML")
if (UNIX)
	set_target_properties (binding_ruby_lib PROPERTIES PREFIX "")
	if (APPLE)
		set_target_properties (binding_ruby_lib PROPERTIES SUFFIX ".bundle")
	endif()
endif()
target_link_libraries(binding_ruby_lib ${LIBSBML_LIBRARY}-static ${RUBY_LIBRARY})
INSTALL(TARGETS binding_ruby_lib DESTINATION ${RUBY_PACKAGE_INSTALL_DIR} )

####################################################################
#
# testing
#

if(WITH_CHECK)

	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/test.rb DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

	# convert paths
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_BINARY_DIR}/test.rb test_runner)

	# run ruby tests
	add_test(test_ruby_binding ${RUBY_EXECUTABLE} -I. -I${CMAKE_CURRENT_SOURCE_DIR} -I${CMAKE_CURRENT_SOURCE_DIR}/ruby ${test_runner} 
	       -b ${CMAKE_CURRENT_SOURCE_DIR}/test -p ${CTEST_CONFIGURATION_TYPE})

	# specify that tests have passed if we find only dots	
	set_tests_properties(test_ruby_binding PROPERTIES PASS_REGULAR_EXPRESSION "[.]+" )
	# specify that tests have failed in case there was one of the words below in the output
	set_tests_properties(test_ruby_binding PROPERTIES FAIL_REGULAR_EXPRESSION "Error;ERROR;Failed")	

	if(UNIX)
		if(APPLE)
			set_tests_properties(test_ruby_binding PROPERTIES ENVIRONMENT "DYLD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../..:$ENV{DYLD_LIBRARY_PATH}")
		else()
			set_tests_properties(test_ruby_binding PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=/usr/lib/:${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../..:$ENV{LD_LIBRARY_PATH}")
		endif()
	endif()	
	
endif()

