###############################################################################
#
# Description       : CMake build script for libSBML MATLAB bindings
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

if(WITH_MATLAB)
SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}" ${CMAKE_MODULE_PATH}) 
find_package(Matlab)

# on windows let us build the library using MSVC, on Linux and OS X we choose
# to build with the buildSBML script by default
set(MATLAB_MEX_DEFAULT)
set(WITH_MATLAB_BUILDSBML_DEFAULT)
if (UNIX)
   set(WITH_MATLAB_BUILDSBML_DEFAULT ON)
   set(MATLAB_MEX_DEFAULT OFF)
else()
   set(WITH_MATLAB_BUILDSBML_DEFAULT OFF)
   set(MATLAB_MEX_DEFAULT OFF)
endif()

option(WITH_MATLAB_BUILDSBML   
      "Generate Matlab bindings using the buildsbml script from matlab."     ${WITH_MATLAB_BUILDSBML_DEFAULT} )
option(WITH_MATLAB_MEX   
      "Generate Matlab bindings using MEX compiler "     ${MATLAB_MEX_DEFAULT} )


# 
# Determine the matlab installation directory
#
set(MATLAB_PACKAGE_INSTALL_DIR)
if (UNIX OR CYGWIN) 
  set(MATLAB_PACKAGE_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR})
else()
  set(MATLAB_PACKAGE_INSTALL_DIR ${MISC_PREFIX}bindings/matlab)
endif()

if (WITH_MATLAB_BUILDSBML)

file(TO_CMAKE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../ binding_include_dir )
file(TO_CMAKE_PATH ${CMAKE_CURRENT_BINARY_DIR}/../../ binding_lib_dir )


ADD_CUSTOM_COMMAND(	

OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/TranslateSBML.${MATLAB_MEX_EXT}
       ${CMAKE_CURRENT_BINARY_DIR}/OutputSBML.${MATLAB_MEX_EXT}

COMMAND "${MATLAB_MATLAB_COMMAND}"
ARGS  -nosplash -nodesktop -memmgr debug -logfile runTests.log 
      -r \"cd ('${CMAKE_CURRENT_SOURCE_DIR}')\;buildSBML('${binding_include_dir}', '${binding_lib_dir}')\;quit\;\"

COMMAND "${CMAKE_COMMAND}"
ARGS  -E copy_if_different 
      ${CMAKE_CURRENT_SOURCE_DIR}/TranslateSBML.${MATLAB_MEX_EXT} 
      ${CMAKE_CURRENT_BINARY_DIR}

COMMAND "${CMAKE_COMMAND}"
ARGS  -E copy_if_different 
      ${CMAKE_CURRENT_SOURCE_DIR}/OutputSBML.${MATLAB_MEX_EXT} 
      ${CMAKE_CURRENT_BINARY_DIR}

DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/TranslateSBML.c"
        "${CMAKE_CURRENT_SOURCE_DIR}/OutputSBML.c"

WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
COMMENT "compile and link bindings using buildSBML"

) 

add_custom_target(binding_matlab_mexfiles ALL 
       DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/TranslateSBML.${MATLAB_MEX_EXT} 
               ${CMAKE_CURRENT_BINARY_DIR}/OutputSBML.${MATLAB_MEX_EXT} 
               ${LIBSBML_LIBRARY})
add_dependencies(binding_matlab_mexfiles ${LIBSBML_LIBRARY})

install(
    FILES 
       ${CMAKE_CURRENT_BINARY_DIR}/TranslateSBML.${MATLAB_MEX_EXT}  
       ${CMAKE_CURRENT_BINARY_DIR}/OutputSBML.${MATLAB_MEX_EXT}  
    DESTINATION 
       ${MATLAB_PACKAGE_INSTALL_DIR} 
)

elseif (WITH_MATLAB_MEX)

if (NOT EXISTS "${MATLAB_MEX_COMMAND}")
	# fail if mex was not found
	message (FATAL_ERROR "The mex command is vital for building matlab bindings. It was not found during configuration. Please manually specify MATLAB_MEX_COMMAND.")
endif()


# get location of library
get_property(sbml_location TARGET ${LIBSBML_LIBRARY} PROPERTY LOCATION)
get_filename_component(sbml_path "${sbml_location}" PATH)
file(TO_NATIVE_PATH ${sbml_path} sbml_path)

message(STATUS "matlab root        ${MATLAB_ROOT}")
message(STATUS "matlab mex command ${MATLAB_MEX_COMMAND}")
message(STATUS "matlab mex library ${MATLAB_MEX_LIBRARY}")
message(STATUS "matlab include dir ${MATLAB_INCLUDE_DIR}")
message(STATUS "matlab libraries   ${MATLAB_LIBRARIES}")
message(STATUS "matlab root path   ${MATLAB_ROOT_PATH}")
message(STATUS "extension is       ${MATLAB_MEX_EXT}")



# break up the libsbml library dependencies into paths and libraries
set(MATLAB_EXTRA_LIBS)
foreach(lib ${LIBSBML_LIBS})
	get_filename_component(name ${lib} NAME_WE)	
	get_filename_component(path ${lib} PATH)	
	string(REGEX REPLACE "lib" "" name "${name}")
	file(TO_NATIVE_PATH "${path}" native_path)
	list(APPEND MATLAB_EXTRA_LIBS -l${name})
	if (WIN32)
		list(APPEND MATLAB_EXTRA_LIBS -L${native_path})
	endif()
endforeach()

set(MATLAB_LIBSBML_LIB)
set(MATLAB_OBJ_FILE)
set(MATLAB_MEX_EXTRA_ARGS)
if(UNIX)
	set(MATLAB_LIBSBML_LIB -l${LIBSBML_LIBRARY} -L${sbml_path})
	set(MATLAB_MEX_EXTRA_ARGS -cxx)
else()
	if(MSVC)
		set(MATLAB_LIBSBML_LIB -l${LIBSBML_LIBRARY}-static -L${sbml_path})
		set(MATLAB_MEX_EXTRA_ARGS -DWIN32 -DLIBSBML_EXPORTS -DLIBLAX_EXPORTS )
	else()
		set(MATLAB_LIBSBML_LIB -l${LIBSBML_LIBRARY} -L${sbml_path})	
	endif()
endif()

macro(build_matlab_file fileName)
	
	if (NOT UNIX)
		# sarah commented that the mex command did not work for her, 
		# so let us try this one on windows
		
		file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${fileName}.c" src)
		file(TO_NATIVE_PATH "${CMAKE_CURRENT_BINARY_DIR}/../../" include_path0)
		file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../" include_path1)
		file(TO_NATIVE_PATH "${LIBSBML_ROOT_SOURCE_DIR}/include" include_path2)

		get_property(sbml_import TARGET ${LIBSBML_LIBRARY} PROPERTY LOCATION)
		string(REPLACE ".dll" ".lib" sbml_import ${sbml_import})
		file(TO_NATIVE_PATH "${sbml_import}" sbml_import)
		
		ADD_CUSTOM_COMMAND(	
			OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.${MATLAB_MEX_EXT}
			
			COMMAND "${CMAKE_COMMAND}"
			ARGS  -E remove ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.${MATLAB_MEX_EXT}
			
			COMMAND "${MATLAB_MEX_COMMAND}"
			ARGS 
				${src}
				-I${include_path0}
				-I${include_path1}
				-I${include_path2}
				${sbml_import}
				
			MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${fileName}.c
			COMMENT "compile and link matlab mex file: ${fileName}") 
	
	else()
	

	if (MSVC)
		set(MATLAB_OBJ_FILE ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.obj)
	else()
		set(MATLAB_OBJ_FILE ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.o)
	endif()

	# compile and link mex file
	ADD_CUSTOM_COMMAND(	
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.${MATLAB_MEX_EXT}
		
		COMMAND "${CMAKE_COMMAND}"
		ARGS  -E remove ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.${MATLAB_MEX_EXT}
		
		COMMAND "${MATLAB_MEX_COMMAND}"
		ARGS 
			-I"${CMAKE_CURRENT_BINARY_DIR}/../../"
			-I"${CMAKE_CURRENT_SOURCE_DIR}/../../"
			-I"${LIBSBML_ROOT_SOURCE_DIR}/include"
			-c
			${MATLAB_MEX_EXTRA_ARGS}
			"${CMAKE_CURRENT_SOURCE_DIR}/${fileName}.c"
		
		COMMAND "${MATLAB_MEX_COMMAND}"
		ARGS 
			${MATLAB_MEX_EXTRA_ARGS}
			-output "${CMAKE_CURRENT_BINARY_DIR}/${fileName}.${MATLAB_MEX_EXT}"
			${MATLAB_OBJ_FILE}
			${MATLAB_LIBSBML_LIB}
			${MATLAB_EXTRA_LIBS}
			
		MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/${fileName}.c
		COMMENT "compile and link matlab mex file: ${fileName}") 
	
	endif()
		
	add_custom_target(binding_matlab_${fileName} ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.${MATLAB_MEX_EXT} ${LIBSBML_LIBRARY})
	add_dependencies(binding_matlab_${fileName} ${LIBSBML_LIBRARY})

	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${fileName}.${MATLAB_MEX_EXT} DESTINATION ${MATLAB_PACKAGE_INSTALL_DIR} )
	install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../matlab/${fileName}.m DESTINATION ${MATLAB_PACKAGE_INSTALL_DIR} )

endmacro()

build_matlab_file("TranslateSBML")
build_matlab_file("OutputSBML")

else()

	if (MSVC)
	###############################################################################
	#
	# this is a directory level operation!
	#
	if (WITH_STATIC_RUNTIME)
		foreach(flag_var
			CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
			CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
			CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
			CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO)
	
			if(${flag_var} MATCHES "/MD")
				string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
			endif(${flag_var} MATCHES "/MD")
			
			
		endforeach(flag_var)
		add_definitions( -D_MT)
	endif(WITH_STATIC_RUNTIME)
	endif()
	
	include_directories(${MATLAB_INCLUDE_DIR})
	include_directories(BEFORE ${LIBSBML_ROOT_BINARY_DIR}/src)

	if (EXTRA_INCLUDE_DIRS) 
	  include_directories(${EXTRA_INCLUDE_DIRS})
	endif(EXTRA_INCLUDE_DIRS)
	
	foreach(matlab_source_file "TranslateSBML" "OutputSBML")
	
		add_library(matlab_binding_${matlab_source_file} SHARED "${CMAKE_CURRENT_SOURCE_DIR}/${matlab_source_file}.c")
		set_target_properties(matlab_binding_${matlab_source_file} PROPERTIES OUTPUT_NAME "${matlab_source_file}")
		set_target_properties(matlab_binding_${matlab_source_file} PROPERTIES SUFFIX ".${MATLAB_MEX_EXT}")
                set_target_properties(matlab_binding_${matlab_source_file} PROPERTIES  PREFIX "")
		if (MSVC)
		set_target_properties(matlab_binding_${matlab_source_file} PROPERTIES LINK_FLAGS "/export:mexFunction") 
		endif()
		target_link_libraries(matlab_binding_${matlab_source_file} ${MATLAB_LIBRARIES} ${LIBSBML_LIBRARY}-static)				
		install(TARGETS matlab_binding_${matlab_source_file} DESTINATION ${MATLAB_PACKAGE_INSTALL_DIR} )

	endforeach()
	
	
endif(WITH_MATLAB_BUILDSBML)


# mark files for installation
file(GLOB matlab_scripts "${CMAKE_CURRENT_SOURCE_DIR}/../matlab/*.m"
                         "${CMAKE_CURRENT_SOURCE_DIR}/../matlab/*.xml")
install(FILES ${matlab_scripts} DESTINATION ${MATLAB_PACKAGE_INSTALL_DIR})

# add test cases
if (WITH_CHECK)
	
	add_subdirectory(test)	

endif()


endif()

