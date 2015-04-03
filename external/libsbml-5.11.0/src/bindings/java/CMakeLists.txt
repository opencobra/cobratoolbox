###############################################################################
#
# Description       : CMake build script for libSBML Java bindings
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
find_package(JNI)
find_package(Java COMPONENTS Development REQUIRED)
include(FindPythonInterp)
include(${SWIG_USE_FILE})


####################################################################
#
# create manifest file
# 
configure_file (
  "${CMAKE_CURRENT_SOURCE_DIR}/Manifest.txt.in"
  "${CMAKE_CURRENT_BINARY_DIR}/Manifest.txt"
  )

####################################################################
#
# ensure that javac, jar and python are available
# 

if (NOT EXISTS "${Java_JAVAC_EXECUTABLE}")
	if (NOT EXISTS "${JAVA_COMPILE}")
		message(FATAL_ERROR "The java language bindings require Java_JAVAC_EXECUTABLE to be set to the javac command.")
	else()
		SET(Java_JAVAC_EXECUTABLE "${JAVA_COMPILE}" CACHE STRING "Javac compiler" FORCE)
	endif()
endif()


if (NOT EXISTS "${Java_JAR_EXECUTABLE}")
	if (NOT EXISTS "${JAVA_ARCHIVE}")	
		message(FATAL_ERROR "The java language bindings require Java_JAR_EXECUTABLE to be set to the jar command.")
	else()
        set (Java_JAR_EXECUTABLE "${JAVA_ARCHIVE}" CACHE STRING "jar command" FORCE)
	endif()
endif()

if (NOT EXISTS "${PYTHON_EXECUTABLE}")
	message(FATAL_ERROR "The java language bindings require PYTHON_EXECUTABLE to be set to the python command.")
endif()


####################################################################
#
# determine local dependencies, so as to re-swig if one of them changed
# 


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

# 
# Determine the java installation directory
#
set(JAVA_PACKAGE_BIN_INSTALL_DIR)
set(JAVA_PACKAGE_JAR_INSTALL_DIR)
if (UNIX OR CYGWIN) 
  set(JAVA_PACKAGE_BIN_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR})
  set(JAVA_PACKAGE_JAR_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/share/java)  
else()
  set(JAVA_PACKAGE_BIN_INSTALL_DIR ${MISC_PREFIX}bindings/java)
  set(JAVA_PACKAGE_JAR_INSTALL_DIR ${MISC_PREFIX}bindings/java)  
endif()

#
# Remove SWIG wrappers if requested
#
if (LIBSBML_REMOVE_WRAPPERS)
  foreach(file 
    ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp 
    ${CMAKE_CURRENT_BINARY_DIR}/javadoc.i
  )
    if (EXISTS ${file})
      FILE(REMOVE ${file})
    endif()
  endforeach()
endif(LIBSBML_REMOVE_WRAPPERS)

# the Java bindings will only build if some files are generated, 
# for those files to be generated the following python scripts are 
# needed
file(COPY 
     ${CMAKE_CURRENT_SOURCE_DIR}/../swig/libsbmlutils.py
     "${CMAKE_CURRENT_SOURCE_DIR}/../../../docs/src/utilities/generate-class-name-list.py"
     "${CMAKE_CURRENT_SOURCE_DIR}/../../../docs/src/utilities/generate-converters-list.py"
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

	 
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

file(GLOB SWIG_DEPENDENCIES 
	${CMAKE_CURRENT_SOURCE_DIR}/*.i 
	${CMAKE_CURRENT_SOURCE_DIR}/*.h 
	${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
	${CMAKE_CURRENT_SOURCE_DIR}/../swig/*.i
	${CMAKE_CURRENT_SOURCE_DIR}/../swig/*.h
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/swig-binding.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/swig-binding.cmake
	@ONLY
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

SET(DOC_ARGS)
foreach(arg ${SWIG_SWIGDOCDEFINES})
if (NOT UNIX)
  set(DOC_ARGS "${DOC_ARGS} ${arg}")
else()
  list(APPEND DOC_ARGS ${arg})
endif()
endforeach()

	 
####################################################################
#
# Swig bindings
#
#
add_custom_command(	

	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp 
	       ${CMAKE_CURRENT_BINARY_DIR}/javadoc.i
	       ${CMAKE_CURRENT_BINARY_DIR}/class-list.txt
	       ${CMAKE_CURRENT_BINARY_DIR}/libsbml-converters.txt
	       ${CMAKE_CURRENT_BINARY_DIR}/java-files/org/sbml/libsbml/libsbmlJNI.java
		   ${CMAKE_CURRENT_BINARY_DIR}/java-files/org/sbml/libsbml/libsbml.java

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
	COMMENT "Swig Java source"

)
	
add_custom_target(binding_java_swig ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../swig)
include_directories(${LIBSBML_ROOT_SOURCE_DIR}/include)
include_directories(BEFORE ${LIBSBML_ROOT_BINARY_DIR}/src)

if (EXTRA_INCLUDE_DIRS) 
 include_directories(${EXTRA_INCLUDE_DIRS})
endif(EXTRA_INCLUDE_DIRS)

# if additional directories are set be sure to include them
if (JNI_INCLUDE_DIRS)
include_directories(${JNI_INCLUDE_DIRS})
endif(JNI_INCLUDE_DIRS)
if (JAVA_INCLUDE_PATH)
include_directories(${JAVA_INCLUDE_PATH})
endif(JAVA_INCLUDE_PATH)
if (JAVA_INCLUDE_PATH2)
include_directories(${JAVA_INCLUDE_PATH2})
endif(JAVA_INCLUDE_PATH2)


add_library(binding_java_lib SHARED ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp )
add_dependencies( binding_java_lib binding_java_swig) 
set_target_properties (binding_java_lib PROPERTIES OUTPUT_NAME "sbmlj")


if(APPLE)
	set_target_properties (binding_java_lib PROPERTIES SUFFIX ".jnilib")
endif()

INSTALL(TARGETS binding_java_lib DESTINATION ${JAVA_PACKAGE_BIN_INSTALL_DIR} )

target_link_libraries(binding_java_lib ${LIBSBML_LIBRARY}-static )

ADD_CUSTOM_COMMAND(	
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsbmlj.jar
		     ${CMAKE_CURRENT_BINARY_DIR}/test/AutoTestRunner.class

	COMMAND "${CMAKE_COMMAND}"
	ARGS    -E make_directory  ${CMAKE_CURRENT_BINARY_DIR}/test

	COMMAND "${CMAKE_COMMAND}"
	ARGS -DJava_JAVAC_EXECUTABLE=\"${Java_JAVAC_EXECUTABLE}\"
		 -DJava_JAR_EXECUTABLE=\"${Java_JAR_EXECUTABLE}\"
		 -DBIN_DIRECTORY=\"${CMAKE_CURRENT_BINARY_DIR}\"
		 -DSRC_DIRECTORY=\"${CMAKE_CURRENT_SOURCE_DIR}\"
		 -DFILE_SEP=\"${FILE_SEP}\"
		 -DPATH_SEP=${PATH_SEP}
		 -P "${CMAKE_CURRENT_SOURCE_DIR}/compile-native-files.cmake"
	
	MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/java-files/org/sbml/libsbml/libsbml.java

	WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  COMMENT "Building: libsbml.jar"
)

add_custom_target(binding_java_jar ALL DEPENDS 
	${CMAKE_CURRENT_BINARY_DIR}/libsbmlj.jar
	${CMAKE_CURRENT_BINARY_DIR}/java-files/org/sbml/libsbml/libsbmlJNI.java
     ${CMAKE_CURRENT_BINARY_DIR}/java-files/org/sbml/libsbml/libsbml.java
)
	
add_dependencies(binding_java_jar binding_java_swig)
	
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libsbmlj.jar DESTINATION ${JAVA_PACKAGE_JAR_INSTALL_DIR}) 
	
	
	
#
# Invoke tests if compiled with check
# 
if(WITH_CHECK)

    if (NOT UNIX)
	  # on windows ignore warnings about backslash in command line, as we do use it where
	  # necessary
	  cmake_policy(SET CMP0010 NEW)
	endif()
	
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_BINARY_DIR}/libsbmlj.jar jar_file)
    file(TO_NATIVE_PATH ${CMAKE_CURRENT_BINARY_DIR} current_dir)
    file(TO_NATIVE_PATH ${CMAKE_CURRENT_BINARY_DIR}/test test_dir)
	
	# run tests
	add_test(NAME test_java_binding 
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			COMMAND "${Java_JAVA_EXECUTABLE}" 
			-Xss8m
	        -Djava.library.path=$<TARGET_FILE_DIR:binding_java_lib>
			-cp "${jar_file}${FILE_SEP}${current_dir}${FILE_SEP}${test_dir}"
			AutoTestRunner						    
			)
	# specify that tests have passed if we find only dots	
	set_tests_properties(test_java_binding PROPERTIES PASS_REGULAR_EXPRESSION "[.]+" )
	# specify that tests have failed in case there was one of the words below in the output
	set_tests_properties(test_java_binding PROPERTIES FAIL_REGULAR_EXPRESSION "Error;ERROR;Failed;Exception")	
	
	# set up the DYLD / LD_LIBRARY /PATH to include the library
	if(UNIX)
		if(APPLE)
			set_tests_properties(test_java_binding PROPERTIES ENVIRONMENT "DYLD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:$ENV{DYLD_LIBRARY_PATH}")
		else()
			set_tests_properties(test_java_binding PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:$ENV{LD_LIBRARY_PATH}")
		endif()
	else()
		if(MSVC)
			
			# on windows setting the path alone would only work if the dependent libraries are in the path
			# since that is likely not the case for now we ask the users to set up the path prior to calling ctest
			# otherwise this would do the trick: 
			
			#set(new_path "${current_dir};$ENV{PATH}")
			#string(REPLACE ";" "\\;" new_path "${new_path}")
			#set_tests_properties(test_java_binding PROPERTIES ENVIRONMENT PATH="${new_path}")
		endif()
	endif() 

endif(WITH_CHECK)


