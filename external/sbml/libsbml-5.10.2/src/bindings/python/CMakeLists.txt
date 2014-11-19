###############################################################################
#
# Description       : CMake build script for libSBML Python bindings
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
include(FindPythonLibs)
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
    ${CMAKE_CURRENT_BINARY_DIR}/pydoc-normal.i
    ${CMAKE_CURRENT_BINARY_DIR}/pydoc-doxygen.i
  )
    if (EXISTS ${file})
      FILE(REMOVE ${file})
    endif()
  endforeach()
endif(LIBSBML_REMOVE_WRAPPERS)

# the Python bindings will only build if some files are generated, 
# for those files to be generated the following python scripts are 
# needed
file(COPY 
     ${CMAKE_CURRENT_SOURCE_DIR}/../swig/libsbmlutils.py  
	 "${CMAKE_CURRENT_SOURCE_DIR}/../../../docs/src/utilities/generate-class-name-list.py"
	 "${CMAKE_CURRENT_SOURCE_DIR}/../../../docs/src/utilities/generate-converters-list.py"
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

####################################################################
#
# Swig bindings
#
#
ADD_CUSTOM_COMMAND(	
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp
           ${CMAKE_CURRENT_BINARY_DIR}/class-list.txt
           ${CMAKE_CURRENT_BINARY_DIR}/libsbml-converters.txt
	COMMAND "${PYTHON_EXECUTABLE}"
	ARGS	"${CMAKE_CURRENT_SOURCE_DIR}/../swig/swigdoc.py"
			--language python
			--top "${LIBSBML_ROOT_SOURCE_DIR}"
			--master "${CMAKE_CURRENT_SOURCE_DIR}/../swig/libsbml.i"
			--output "${CMAKE_CURRENT_BINARY_DIR}/pydoc-doxygen.i"
			${SWIG_SWIGDOCDEFINES}
			
    COMMAND "${PYTHON_EXECUTABLE}"
	ARGS	"${CMAKE_CURRENT_BINARY_DIR}/generate-class-name-list.py"
	        "${LIBSBML_ROOT_SOURCE_DIR}/src"
			>
			"${CMAKE_CURRENT_BINARY_DIR}/class-list.txt"
	COMMAND "${PYTHON_EXECUTABLE}"
	ARGS	"${CMAKE_CURRENT_BINARY_DIR}/generate-converters-list.py"	
	        "${CMAKE_CURRENT_BINARY_DIR}/class-list.txt"
			>
		    "${CMAKE_CURRENT_BINARY_DIR}/libsbml-converters.txt"
	COMMAND "${PYTHON_EXECUTABLE}"
	ARGS	"${CMAKE_CURRENT_SOURCE_DIR}/doc-converter/rewrite_pydoc.py"
			-f "${CMAKE_CURRENT_BINARY_DIR}/pydoc-doxygen.i"
			-o "${CMAKE_CURRENT_BINARY_DIR}/pydoc-normal.i"
			-i ${CMAKE_CURRENT_SOURCE_DIR}/../../../docs/src/common-text
			-g ${CMAKE_CURRENT_SOURCE_DIR}/../../../docs/src/common-graphics
	COMMAND "${CMAKE_COMMAND}"
	ARGS    -E rename pydoc-doxygen.i pydoc.i
    COMMAND "${SWIG_EXECUTABLE}"
    ARGS	-I${CMAKE_CURRENT_SOURCE_DIR}/../swig/
			-I${CMAKE_CURRENT_SOURCE_DIR} 
			-I${CMAKE_CURRENT_BINARY_DIR} 
			-I${LIBSBML_ROOT_BINARY_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/include
			-c++
			-python		
			${SWIG_EXTRA_ARGS}		 
			-o ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp 
			${CMAKE_CURRENT_SOURCE_DIR}/libsbml.i
	COMMAND "${CMAKE_COMMAND}"
	ARGS    -E rename pydoc.i pydoc-doxygen.i
	COMMAND "${CMAKE_COMMAND}"
	ARGS    -E rename libsbml.py libsbml-doxygen.py
	COMMAND "${CMAKE_COMMAND}"
	ARGS    -E rename pydoc-normal.i pydoc.i
    COMMAND "${SWIG_EXECUTABLE}"
    ARGS	-I${CMAKE_CURRENT_SOURCE_DIR}/../swig/
			-I${CMAKE_CURRENT_SOURCE_DIR} 
			-I${CMAKE_CURRENT_BINARY_DIR} 
			-I${LIBSBML_ROOT_BINARY_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/src
			-I${LIBSBML_ROOT_SOURCE_DIR}/include
			-c++
			-python		
			${SWIG_EXTRA_ARGS}		 
			-o ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp 
			${CMAKE_CURRENT_SOURCE_DIR}/libsbml.i
	COMMAND "${CMAKE_COMMAND}"
	ARGS    -E rename pydoc.i pydoc-normal.i 
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/libsbml.i
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
	        ${CMAKE_CURRENT_SOURCE_DIR}/doc-converter/rewrite_pydoc.py
			${CMAKE_CURRENT_SOURCE_DIR}/../swig/swigdoc.py
	        ${SWIG_DEPENDENCIES}
    COMMENT "Swig Python source") 

add_custom_target(binding_python_swig ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libsbml_wrap.cpp)
	
####################################################################
#
# Build native library
#

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../swig)
include_directories(${LIBSBML_ROOT_SOURCE_DIR}/include)
include_directories(${PYTHON_INCLUDE_DIRS})
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

add_library(binding_python_lib SHARED libsbml_wrap.cpp)
add_dependencies( binding_python_lib binding_python_swig) 

set_target_properties (binding_python_lib PROPERTIES OUTPUT_NAME "_libsbml")
if (UNIX)
	set_target_properties (binding_python_lib PROPERTIES PREFIX "")
	set_target_properties (binding_python_lib PROPERTIES SUFFIX ".so")
else()		
	if (CYGWIN)
		set_target_properties (binding_python_lib PROPERTIES PREFIX "")
		set_target_properties (binding_python_lib PROPERTIES SUFFIX ".dll")
	else()
		set_target_properties (binding_python_lib PROPERTIES SUFFIX ".pyd")	
	endif()
endif()

target_link_libraries(binding_python_lib ${LIBSBML_LIBRARY}-static ${PYTHON_LIBRARIES})

# 
# Determine the python installation directory
#
set(PYTHON_PACKAGE_INSTALL_DIR)
if (UNIX OR CYGWIN) 
  execute_process(COMMAND "${PYTHON_EXECUTABLE}" -c "import sys;import platform; sys.stdout.write(platform.python_version()[:3])"
    OUTPUT_VARIABLE PYTHON_VERSION)
  set(PYTHON_PACKAGE_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/python${PYTHON_VERSION}/site-packages)
else()
  set(PYTHON_PACKAGE_INSTALL_DIR ${MISC_PREFIX}bindings/python)
endif()

INSTALL(TARGETS binding_python_lib DESTINATION ${PYTHON_PACKAGE_INSTALL_DIR}/libsbml )

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/libsbml.pth" "libsbml\n")
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libsbml.pth  DESTINATION ${PYTHON_PACKAGE_INSTALL_DIR})
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/libsbml.py  DESTINATION ${PYTHON_PACKAGE_INSTALL_DIR}/libsbml )


option(WITH_CREATE_PYTHON_SOURCE   "Generate Python Source Package." OFF)
if (WITH_CREATE_PYTHON_SOURCE AND EXISTS "${LIBSBML_ROOT_SOURCE_DIR}/dev/utilities/python_package/")

SET(PYTHON_SOURCE_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/out)
file(TO_NATIVE_PATH ${PYTHON_SOURCE_OUT_DIR} NATIVE_OUT)

add_custom_command(
	OUTPUT
		${PYTHON_SOURCE_OUT_DIR}/setup.py
	COMMAND "${CMAKE_COMMAND}" 
	ARGS -E make_directory ${PYTHON_SOURCE_OUT_DIR}
	COMMAND "${CMAKE_COMMAND}"
	ARGS -DOUT_DIR=\"${NATIVE_OUT}\" 
		 -DSRC_DIR=\"${LIBSBML_ROOT_SOURCE_DIR}/src\"
		 -DBIN_DIR=\"${LIBSBML_ROOT_BINARY_DIR}\"
		 -P "${LIBSBML_ROOT_SOURCE_DIR}/dev/utilities/python_package/create_package.cmake"

	DEPENDS ${LIBSBML_ROOT_SOURCE_DIR}/VERSION.txt
	WORKING_DIRECTORY "${LIBSBML_ROOT_SOURCE_DIR}/dev/utilities/python_package/"
    COMMENT "Configure Python source package"
	)

add_custom_target(binding_python_source_config ALL DEPENDS ${PYTHON_SOURCE_OUT_DIR}/setup.py)
add_dependencies(binding_python_source_config binding_python_swig)

add_custom_command(
	OUTPUT ${PYTHON_SOURCE_OUT_DIR}/MANIFEST

	COMMAND "${PYTHON_EXECUTABLE}"
	ARGS setup.py 
	     sdist

	DEPENDS ${PYTHON_SOURCE_OUT_DIR}/setup.py
	        ${LIBSBML_ROOT_SOURCE_DIR}/dev/utilities/python_package/create_package.cmake
	WORKING_DIRECTORY "${PYTHON_SOURCE_OUT_DIR}"
    COMMENT "Create Python source package"
	)

add_custom_target(binding_python_source_package ALL DEPENDS ${PYTHON_SOURCE_OUT_DIR}/MANIFEST)
add_dependencies(binding_python_source_package binding_python_source_config)
 

endif(WITH_CREATE_PYTHON_SOURCE AND EXISTS "${LIBSBML_ROOT_SOURCE_DIR}/dev/utilities/python_package/")


####################################################################
#
# testing
#

if(WITH_CHECK)

	# copy test files to build dir
	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/test.py DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

	# run python tests
	add_test(NAME test_python_binding 
	         COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/test.py
	         -p $<TARGET_FILE_DIR:binding_python_lib> -b ${CMAKE_CURRENT_SOURCE_DIR}/test)

endif()
