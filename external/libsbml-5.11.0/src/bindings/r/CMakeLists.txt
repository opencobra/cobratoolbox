###############################################################################
#
# Description       : CMake build script for libSBML R bindings
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

SET(R_INCLUDE_DIRS)
SET(R_LIB)
SET(R_INTERPRETER)
SET(R_ADDITIONAL_PATH_ENTRIES "" CACHE STRING "Additional paths to the RTOOLS / GCC binary directories to build package")
SET(CMAKE_FIND_FRAMEWORK NEVER)
SET(CMAKE_FIND_APPBUNDLE NEVER)
# first lets search for the include/lib/interpreter if a user did not specify them
if (NOT R_INCLUDE_DIRS)
    find_path(R_INCLUDE_DIRS
        NAMES R.h
        PATHS /usr/include /usr/local/include /usr/share/R/include
              /Library/Frameworks/R.framework/Versions/Current/Resources/include
              $ENV{ProgramFiles}/R/R-3.1.0/include
              $ENV{ProgramW6432}/R/R-3.1.0/include
              $ENV{ProgramFiles}/R/R-3.0.3/include
              $ENV{ProgramW6432}/R/R-3.0.3/include
              $ENV{ProgramFiles}/R/R-2.15.3/include
              $ENV{ProgramW6432}/R/R-2.15.3/include
              $ENV{ProgramFiles}/R/R-2.15.2/include
              $ENV{ProgramW6432}/R/R-2.15.2/include
              $ENV{ProgramFiles}/R/R-2.15.1/include
              $ENV{ProgramW6432}/R/R-2.15.1/include
              ${LIBSBML_ROOT_SOURCE_DIR}/include
              ${LIBSBML_DEPENDENCY_DIR}/include
        DOC "The directory containing the R include files."
        )
endif()

if (NOT R_LIB)
    SET(R_SUFFIX)
	if (WIN32)
		if (LIBSBML_BUILD_TYPE STREQUAL "32bit")
		SET(R_SUFFIX "/i386")
		else()
		SET(R_SUFFIX "/x64")
		endif()
	endif()
	find_library(R_LIB
			NAMES Rlib.lib R
			PATHS /usr/lib /usr/local/lib /usr/lib/R/lib
            $ENV{ProgramFiles}/R/R-3.1.0/bin${R_SUFFIX}
            $ENV{ProgramW6432}/R/R-3.1.0/bin${R_SUFFIX}
            $ENV{ProgramFiles}/R/R-3.0.3/bin${R_SUFFIX}
            $ENV{ProgramW6432}/R/R-3.0.3/bin${R_SUFFIX}
            $ENV{ProgramFiles}/R/R-2.15.3/bin${R_SUFFIX}
            $ENV{ProgramW6432}/R/R-2.15.3/bin${R_SUFFIX}
            $ENV{ProgramFiles}/R/R-2.15.2/bin${R_SUFFIX}
            $ENV{ProgramW6432}/R/R-2.15.2/bin${R_SUFFIX}
            $ENV{ProgramFiles}/R/R-2.15.1/bin${R_SUFFIX}
            $ENV{ProgramW6432}/R/R-2.15.1/bin${R_SUFFIX}
            /Library/Frameworks/R.framework/Versions/Current/Resources/lib
            ${LIBSBML_ROOT_SOURCE_DIR}
            ${LIBSBML_DEPENDENCY_DIR}/lib
			DOC "The file name of the R library."
			)
endif()
if (NOT R_INTERPRETER)
	find_program(R_INTERPRETER
        NAMES R R32 R64
        PATHS 
          $ENV{ProgramFiles}/R/R-3.1.0/bin
          $ENV{ProgramW6432}/R/R-3.1.0/bin
          $ENV{ProgramFiles}/R/R-3.0.3/bin
          $ENV{ProgramW6432}/R/R-3.0.3/bin
          $ENV{ProgramFiles}/R/R-2.15.3/bin
          $ENV{ProgramW6432}/R/R-2.15.3/bin
          $ENV{ProgramFiles}/R/R-2.15.2/bin
          $ENV{ProgramW6432}/R/R-2.15.2/bin
          $ENV{ProgramFiles}/R/R-2.15.1/bin
          $ENV{ProgramW6432}/R/R-2.15.1/bin
          /Library/Frameworks/R.framework/Versions/Current/Resources/bin/
          /usr/local/bin
          /usr/bin
        DOC "The file name of the R interpreter."
        )
endif()

# message(
# "
#              R_INCLUDE_DIRS = ${R_INCLUDE_DIRS}
#                       R_LIB = ${R_LIB}
#               R_INTERPRETER = ${R_INTERPRETER}
#   R_ADDITIONAL_PATH_ENTRIES = ${R_ADDITIONAL_PATH_ENTRIES}
# 
# ")

# if we have not found something, stop here to ask for it
if (NOT R_INTERPRETER)
	message(FATAL_ERROR "Need the R interpreter in order to create an R package") 
endif()
if (NOT R_LIB)
	message(FATAL_ERROR "Need the R library, please specify R_LIB")
endif()
if (NOT R_INCLUDE_DIRS)
	message(FATAL_ERROR "Need the R include directory, please specify R_INCLUDE_DIRS")
endif()



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


# munge argument lists to string, so that they can safely passed along
SET(SWIG_ARGS)
foreach(arg ${SWIG_EXTRA_ARGS} ${SWIG_EXTRA_FLAGS})
if (NOT UNIX)
  set(SWIG_ARGS "${SWIG_ARGS} ${arg}")
else()
  list(APPEND SWIG_ARGS ${arg})
endif()
endforeach()

add_custom_command(	
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp
	       ${CMAKE_CURRENT_BINARY_DIR}/libSBML.R
    COMMAND "${CMAKE_COMMAND}"
    ARGS	-DCUR_BIN_DIRECTORY=\"${CMAKE_CURRENT_BINARY_DIR}\"
		 -DBIN_DIRECTORY=\"${LIBSBML_ROOT_BINARY_DIR}\"
		 -DCUR_SRC_DIRECTORY=\"${CMAKE_CURRENT_SOURCE_DIR}\"
		 -DSRC_DIRECTORY=\"${LIBSBML_ROOT_SOURCE_DIR}\"
		 -DCMAKE_COMMAND=\"${CMAKE_COMMAND}\"
		 -DPYTHON_EXECUTABLE=\"${PYTHON_EXECUTABLE}\"
		 -DSWIG_SWIGDOCDEFINES=\"${DOC_ARGS}\"
		 -DSWIG_ARGS=\"${SWIG_ARGS}\"
		 -DSWIG_EXECUTABLE=\"${SWIG_EXECUTABLE}\"
		 -DLIBSBML_REMOVE_WRAPPERS=${LIBSBML_REMOVE_WRAPPERS}
		 -P "${CMAKE_CURRENT_SOURCE_DIR}/swig-binding.cmake"
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/libsbml.i
	DEPENDS ${SWIG_DEPENDENCIES}
    COMMENT "Swig: R Bindings") 

add_custom_target(binding_r_swig ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)

	
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
include_directories(${R_INCLUDE_DIRS})
include_directories(BEFORE ${LIBSBML_ROOT_BINARY_DIR}/src)
include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR})

if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)

if (MSVC)
  # the build fails when compiled with packages as the object file is too 
  # big adding the big flag makes it work!
  add_definitions(/bigobj)
endif(MSVC)

add_library(binding_r_lib SHARED ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)
add_dependencies(binding_r_lib binding_r_swig)


set_target_properties (binding_r_lib PROPERTIES OUTPUT_NAME "libSBML")
if (UNIX)
	set_target_properties (binding_r_lib PROPERTIES PREFIX "")
	if (APPLE)
		set_target_properties (binding_r_lib PROPERTIES SUFFIX ".so")
    if( "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" AND CLANG_USE_STDLIB )
      set_target_properties (binding_r_lib PROPERTIES COMPILE_FLAGS " -std=c++0x -stdlib=libstdc++")
    endif()
	endif()
endif()
if (R_ADDITIONAL_PATH_ENTRIES)
target_link_libraries(binding_r_lib ${LIBSBML_LIBRARY}-static ${R_LIB} ${R_ADDITIONAL_PATH_ENTRIES})
else()
target_link_libraries(binding_r_lib ${LIBSBML_LIBRARY}-static ${R_LIB})
endif()

####################################################################
#
# create the r package
#

MACRO (TODAY RESULT) 
    IF (WIN32) 
        EXECUTE_PROCESS(COMMAND "cmd" " /C date /T" OUTPUT_VARIABLE ${RESULT} OUTPUT_STRIP_TRAILING_WHITESPACE) 
        string(REGEX REPLACE "(..)/(..)/..(..).*" "\\1/\\2/\\3" ${RESULT} ${${RESULT}}) 
    ELSEIF(UNIX) 
        EXECUTE_PROCESS(COMMAND "date" "+%Y-%m-%d" OUTPUT_VARIABLE ${RESULT} OUTPUT_STRIP_TRAILING_WHITESPACE) 
        string(REGEX REPLACE "(..)/(..)/..(..).*" "\\1/\\2/\\3" ${RESULT} ${${RESULT}}) 
    ELSE (WIN32) 
        MESSAGE(SEND_ERROR "date not implemented") 
        SET(${RESULT} 000000) 
    ENDIF (WIN32) 
ENDMACRO (TODAY) 

TODAY(CURRENT_DATE) 

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/libSBML")

set(R_LIBRARY_DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/libSBML/inst/libs")

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libSBML/R)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/temp)
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/DESCRIPTION.in"
  "${CMAKE_CURRENT_BINARY_DIR}/libSBML/DESCRIPTION"
  )
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/NAMESPACE"
  "${CMAKE_CURRENT_BINARY_DIR}/libSBML/NAMESPACE"
)

get_target_property(LIBSBML_R_NATIVELIB binding_r_lib LOCATION)

if (APPLE AND ENABLE_UNIVERSAL)

file(MAKE_DIRECTORY ${R_LIBRARY_DESTINATION})
file(MAKE_DIRECTORY ${R_LIBRARY_DESTINATION}/i386)
file(MAKE_DIRECTORY ${R_LIBRARY_DESTINATION}/x86_64)

add_custom_command(	
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libSBML_${PACKAGE_VERSION}.zip
	COMMAND "${CMAKE_COMMAND}"
			-DFILENAME=\"${CMAKE_CURRENT_BINARY_DIR}/libSBML.R\"
			-P "${CMAKE_CURRENT_SOURCE_DIR}/patch-swig-file.cmake"
	COMMAND "${CMAKE_COMMAND}"
	ARGS  -E copy_if_different 
		 ${LIBSBML_R_NATIVELIB}
		 ${R_LIBRARY_DESTINATION}/i386
	COMMAND "${CMAKE_COMMAND}"
	ARGS  -E copy_if_different
		 ${LIBSBML_R_NATIVELIB}
		 ${R_LIBRARY_DESTINATION}/x86_64
	COMMAND "${CMAKE_COMMAND}"
	ARGS  -E copy_if_different 
		 ${CMAKE_CURRENT_BINARY_DIR}/libSBML.R
		 ${CMAKE_CURRENT_BINARY_DIR}/libSBML/R
    COMMAND "${R_INTERPRETER}"
    ARGS  CMD INSTALL --build 
	      --no-libs 
		  --no-test-load 
		  --no-clean-on-error 
		  --no-multiarch 
		  libSBML
		  -l temp		  
	MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/libSBML.R
	DEPENDS ${SWIG_DEPENDENCIES}
    COMMENT "Create R Package") 

else(APPLE AND ENABLE_UNIVERSAL)

if (WIN32)
if (LIBSBML_BUILD_TYPE STREQUAL "32bit")
set(R_LIBRARY_DESTINATION "${R_LIBRARY_DESTINATION}/i386")
else()
set(R_LIBRARY_DESTINATION "${R_LIBRARY_DESTINATION}/x64")
endif()
endif()

if (APPLE)
if (LIBSBML_BUILD_TYPE STREQUAL "32bit")
set(R_LIBRARY_DESTINATION "${R_LIBRARY_DESTINATION}/i386")
else()
set(R_LIBRARY_DESTINATION "${R_LIBRARY_DESTINATION}/x86_64")
endif()
endif(APPLE)


file(MAKE_DIRECTORY ${R_LIBRARY_DESTINATION})

add_custom_command(	
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libSBML_${PACKAGE_VERSION}.zip
	COMMAND "${CMAKE_COMMAND}"
			-DFILENAME=\"${CMAKE_CURRENT_BINARY_DIR}/libSBML.R\"
			-P "${CMAKE_CURRENT_SOURCE_DIR}/patch-swig-file.cmake"
	COMMAND "${CMAKE_COMMAND}"
	ARGS  -E copy_if_different 
		 ${LIBSBML_R_NATIVELIB}
		 ${R_LIBRARY_DESTINATION}
	COMMAND "${CMAKE_COMMAND}"
	ARGS  -E copy_if_different 
		 ${CMAKE_CURRENT_BINARY_DIR}/libSBML.R
		 ${CMAKE_CURRENT_BINARY_DIR}/libSBML/R
  COMMAND "${CMAKE_COMMAND}"
	ARGS -DR_INTERPRETER=\"${R_INTERPRETER}\"
		 -P "${CMAKE_CURRENT_SOURCE_DIR}/create-r-package.cmake"
  
	MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/libSBML.R
	DEPENDS ${SWIG_DEPENDENCIES}
    COMMENT "Create R Package (${LIBSBML_BUILD_TYPE})") 
endif(APPLE AND ENABLE_UNIVERSAL)
add_custom_target(binding_r_package ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libSBML_${PACKAGE_VERSION}.zip binding_r_lib)

if(WITH_CHECK AND NOT MSVC)

	# running a basic test printing the 
	add_test(test_r_binding ${R_INTERPRETER} --slave -e 
	".libPaths('temp');library(libSBML);cat(getLibSBMLDottedVersion() == '${PACKAGE_VERSION}')")
	set_tests_properties(test_r_binding PROPERTIES PASS_REGULAR_EXPRESSION "TRUE" )

endif()

# at configuration time, we won't know what the final filename of the produced file 
# is, so we need to run a separate script at the end of installation to print the 
# message
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake-r-install.cmake.in
               ${CMAKE_CURRENT_BINARY_DIR}/cmake-r-install.cmake @ONLY)

INSTALL (SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/cmake-r-install.cmake )


####################################################################
#
# create the r source package
#


option(WITH_CREATE_R_SOURCE   "Generate R Source Package." OFF)
if (WITH_CREATE_R_SOURCE)



SET(R_SOURCE_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/out)
file(TO_NATIVE_PATH ${R_SOURCE_OUT_DIR} NATIVE_OUT)

add_custom_command(
	OUTPUT ${R_SOURCE_OUT_DIR}/configure
	COMMAND "${CMAKE_COMMAND}" 
	ARGS -E make_directory ${R_SOURCE_OUT_DIR}
	COMMAND "${CMAKE_COMMAND}"
	ARGS -DOUT_DIR=\"${NATIVE_OUT}\" 
		 -DSRC_DIR=\"${LIBSBML_ROOT_SOURCE_DIR}/src\"
		 -DBIN_DIR=\"${LIBSBML_ROOT_BINARY_DIR}\"
		 -P "${CMAKE_CURRENT_SOURCE_DIR}/create_package.cmake"

	DEPENDS ${LIBSBML_ROOT_SOURCE_DIR}/VERSION.txt
                ${CMAKE_CURRENT_SOURCE_DIR}/create_package.cmake
	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    COMMENT "Configure R source package"
	)

add_custom_target(binding_r_source_config ALL DEPENDS ${R_SOURCE_OUT_DIR}/configure)

configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/DESCRIPTION.in"
  "${R_SOURCE_OUT_DIR}/DESCRIPTION"
  )
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/NAMESPACE"
  "${R_SOURCE_OUT_DIR}/NAMESPACE"
)
add_dependencies(binding_r_source_config binding_r_swig)

add_custom_command(
	OUTPUT ${R_SOURCE_OUT_DIR}/libSBML_${PACKAGE_VERSION}.tar.gz
	COMMAND "${CMAKE_COMMAND}"
			-DFILENAME=\"${CMAKE_CURRENT_BINARY_DIR}/libSBML.R\"
			-P "${CMAKE_CURRENT_SOURCE_DIR}/patch-swig-file.cmake"
	COMMAND "${R_INTERPRETER}"
	ARGS CMD 
	     build
	     . 
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/create_package.cmake
  WORKING_DIRECTORY "${R_SOURCE_OUT_DIR}"
  COMMENT "Create R source package"
)

add_custom_target(binding_r_source_package ALL DEPENDS ${R_SOURCE_OUT_DIR}/libSBML_${PACKAGE_VERSION}.tar.gz)
add_dependencies(binding_r_source_package binding_r_source_config)
 

endif(WITH_CREATE_R_SOURCE)


