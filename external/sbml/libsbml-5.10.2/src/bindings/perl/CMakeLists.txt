###############################################################################
#
# Description       : CMake build script for libSBML Perl bindings
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
include(FindPerlLibs)
include(FindPythonInterp)


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

# fail if we don't have python interpreter
if (NOT EXISTS "${PYTHON_EXECUTABLE}")
	message(FATAL_ERROR "The perl language bindings require PYTHON_EXECUTABLE to be set to the python command.")
endif()

	

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
    ${CMAKE_CURRENT_BINARY_DIR}/LibSBML_wrap.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/LibSBML.pod
  )
    if (EXISTS ${file})
      FILE(REMOVE ${file})
    endif()
  endforeach()
endif(LIBSBML_REMOVE_WRAPPERS)


ADD_CUSTOM_COMMAND(	
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/LibSBML_wrap.cpp ${CMAKE_CURRENT_BINARY_DIR}/LibSBML.pod
	COMMAND "${PYTHON_EXECUTABLE}"
	ARGS	"${CMAKE_CURRENT_SOURCE_DIR}/../swig/swigdoc.py"
			--language perl
			--top "${LIBSBML_ROOT_SOURCE_DIR}"
			--master "${CMAKE_CURRENT_SOURCE_DIR}/../swig/libsbml.i"
			--output "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.pod"	
			${SWIG_SWIGDOCDEFINES}
			
    COMMAND "${SWIG_EXECUTABLE}"
    ARGS	-I${CMAKE_CURRENT_SOURCE_DIR}/../swig/
			-I${CMAKE_CURRENT_SOURCE_DIR} 
			-I${LIBSBML_ROOT_BINARY_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/include
			-c++
			-perl5
			-proxy
			${SWIG_EXTRA_ARGS}		 
			-o ${CMAKE_CURRENT_BINARY_DIR}/LibSBML_wrap.cpp 
			${CMAKE_CURRENT_SOURCE_DIR}/LibSBML.i
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/LibSBML.i
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
	        ${SWIG_DEPENDENCIES}
    COMMENT "Swig Perl bindings source") 

add_custom_target(binding_perl_swig ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/LibSBML_wrap.cpp ${CMAKE_CURRENT_BINARY_DIR}/LibSBML.pod)


# 
# Determine the perl installation directory
#
set(PERL_PACKAGE_INSTALL_DIR)
set(PERL_PACKAGE_INSTALL_BIN_DIR)
if (UNIX OR CYGWIN) 
  execute_process(COMMAND "${PERL_EXECUTABLE}" -V:version
    OUTPUT_VARIABLE PERL_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE "'" "" PERL_VERSION ${PERL_VERSION})
  string(REPLACE ";" "" PERL_VERSION ${PERL_VERSION})
  string(REPLACE "version=" "" PERL_VERSION ${PERL_VERSION})
  string(REPLACE " " "" PERL_VERSION ${PERL_VERSION})
  execute_process(COMMAND "${PERL_EXECUTABLE}" -V:archname
    OUTPUT_VARIABLE PERL_PLATFORM OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " "" PERL_PLATFORM ${PERL_PLATFORM})
  string(REPLACE "'" "" PERL_PLATFORM ${PERL_PLATFORM})
  string(REPLACE ";" "" PERL_PLATFORM ${PERL_PLATFORM})
  string(REPLACE "archname=" "" PERL_PLATFORM ${PERL_PLATFORM})
  set(PERL_PACKAGE_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/perl5/site_perl/${PERL_VERSION}/${PERL_PLATFORM})
  set(PERL_PACKAGE_INSTALL_BIN_DIR ${PERL_PACKAGE_INSTALL_DIR}/auto/libSBML)
else()
  set(PERL_PACKAGE_INSTALL_DIR ${MISC_PREFIX}bindings/perl)
  set(PERL_PACKAGE_INSTALL_BIN_DIR ${PERL_PACKAGE_INSTALL_DIR})
endif()
	
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.pod" DESTINATION ${PERL_PACKAGE_INSTALL_DIR})
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.pm" DESTINATION ${PERL_PACKAGE_INSTALL_DIR})
 
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "#ifdef WIN32\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "// do not include MFC\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "#define WIN32_LEAN_AND_MEAN \n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "// do not include GDI by default\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "#define NOGDI\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "#endif\n\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "#include <EXTERN.h>\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "#include \"LibSBML_wrap.cpp\"\n")
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp" "\n\n")

####################################################################
#
# Build native library
#

include_directories(BEFORE ${CMAKE_CURRENT_SOURCE_DIR})
include_directories(BEFORE ${CMAKE_CURRENT_SOURCE_DIR}/../swig)
include_directories(BEFORE ${LIBSBML_ROOT_SOURCE_DIR}/include)
include_directories(BEFORE ${PERL_INCLUDE_PATH})
include_directories(BEFORE ${LIBSBML_ROOT_BINARY_DIR}/src)
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR})

if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)

if (NOT UNIX)
	add_definitions(-DWIN32SCK_IS_STDSCK -DWIN32IO_IS_STDIO)
	
	
	if (MSVC)
	# these definitions are needed for activestate perl 5.14.2
	if (LIBSBML_BUILD_TYPE STREQUAL "32bit")
	  add_definitions( -D_USE_32BIT_TIME_T -DPERL_TEXTMODE_SCRIPTS -DNO_STRICT ) 
	elseif(LIBSBML_BUILD_TYPE STREQUAL "64bit")
		add_definitions( -DUSE_64_BIT_INT -DUSE_ITHREADS -DMULTIPLICITY ) 
	endif()
	add_definitions(
		-DUSE_LARGE_FILES		
		-DUSE_SITECUSTOMIZE
		-DPERL_IMPLICIT_CONTEXT 
		)
	endif()
endif ()

if(APPLE)
	#add_definitions(-DPERL_DARWIN)
endif()

if (MSVC)
  # the build fails when compiled with packages as the object file is too 
  # big adding the big flag makes it work!
  add_definitions(/bigobj)
endif(MSVC)


add_library(binding_perl_lib MODULE ${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp)
set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/LibSBML.cpp 
      PROPERTIES OBJECT_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/LibSBML_wrap.cpp)
add_dependencies(binding_perl_lib binding_perl_swig)
target_link_libraries(binding_perl_lib ${LIBSBML_LIBRARY}-static ${PERL_LIBRARY})

set_target_properties(binding_perl_lib PROPERTIES  OUTPUT_NAME LibSBML)
set_target_properties(binding_perl_lib PROPERTIES  PREFIX "")

if(APPLE)
	set_target_properties(binding_perl_lib PROPERTIES  SUFFIX ".bundle")
endif()

INSTALL(TARGETS binding_perl_lib  DESTINATION ${PERL_PACKAGE_INSTALL_BIN_DIR} )
 
 
 if (WITH_CHECK)
	add_test(NAME test_perl_binding 
                 WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                 COMMAND ${PERL_EXECUTABLE} 
                 -I${CMAKE_CURRENT_BINARY_DIR}
				 -I$<TARGET_FILE_DIR:binding_perl_lib>
		"-MExtUtils::Command::MM" -e "test_harness(0)" 
		"${CMAKE_CURRENT_SOURCE_DIR}/t/*.t")
	
	if(UNIX)
		if(APPLE)
			set_tests_properties(test_perl_binding PROPERTIES ENVIRONMENT "DYLD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../..:$ENV{DYLD_LIBRARY_PATH}")
		else()
			set_tests_properties(test_perl_binding PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=/usr/lib/:${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../..:$ENV{LD_LIBRARY_PATH}")
		endif()
	endif()
		
 endif()
