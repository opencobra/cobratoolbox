###############################################################################
#
# Description       : CMake build script for libSBML
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

if (WITH_DOXYGEN)
find_package(Doxygen)

if (NOT EXISTS "${DOXYGEN_EXECUTABLE}")
		message(FATAL_ERROR "Cannot generate documentation, please install doxygen / specify the DOXYGEN_EXECUTABLE.")
else()
		message(WARNING "Creating Documentation with CMake is experimental. Please consider configuring with gnumake, to generate documentation.")
endif()

# determine doxygen version
IF(DOXYGEN_EXECUTABLE)
  EXECUTE_PROCESS(COMMAND ${DOXYGEN_EXECUTABLE} "--version" OUTPUT_VARIABLE DOXYGEN_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
ENDIF()

# write specific file
if (DOXYGEN_VERSION VERSION_GREATER 1.7)
file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen-version-specific.txt "MARKDOWN_SUPPORT = NO")
else()
file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen-version-specific.txt "")
endif()

# configure installation html file
configure_file(
	${CMAKE_CURRENT_SOURCE_DIR}/src/libsbml-installation.html.in
	${CMAKE_CURRENT_SOURCE_DIR}/src/libsbml-installation.html
)

# configure java documentation file
configure_file(
	${CMAKE_CURRENT_SOURCE_DIR}/src/java-substitutions/libsbmlConstants.java.in
	${CMAKE_CURRENT_SOURCE_DIR}/src/java-substitutions/libsbmlConstants.java
)


# disable dot if we don't have it
set(HAVE_DOT)
set(DOT_PATH)
if (EXISTS "${DOXYGEN_DOT_PATH}")
	set(HAVE_DOT "YES")
	file(TO_NATIVE_PATH ${DOXYGEN_DOT_PATH} DOT_PATH)
else()
	set(HAVE_DOT "NO")
	set(DOT_PATH "")
endif()

set(PACKAGE_NAME "libSBML")

# replace variables as needed
foreach( lang "common" "c" "cpp" "perl" "python" "csharp")
configure_file(
	${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen-config-${lang}.txt.cmake
	${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen-config-${lang}.txt
)
endforeach()




# create C-api manuals
macro(createManual lang)
	make_directory(${CMAKE_CURRENT_SOURCE_DIR}/formatted/${lang}-api)
	make_directory(${CMAKE_CURRENT_SOURCE_DIR}/formatted/${lang}-api/search)

	file(GLOB graphics_files ${CMAKE_CURRENT_SOURCE_DIR}/src/common-graphics/*.jpg)
	foreach(graphic ${graphics_files})
		file(COPY ${graphic} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/formatted/${lang}-api)
	endforeach()

	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/formatted/${lang}-api output_path)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/formatted/${lang}-api/search search_path)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/common-graphics/official-sbml-supported-40.jpg logo_file)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/common-graphics/right-arrow.gif right_arrow)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/sbml.js sbml_js)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen-tabs.css tabs_css)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/search.png search_png)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/search.css search_css)

	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen-config-${lang}.txt api_doc)

	ADD_CUSTOM_COMMAND(
		OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/formatted/${lang}-api/index.html
		#COMMAND "${CMAKE_COMMAND}"
		#ARGS -E remove_directory ${output_path}
		COMMAND ${DOXYGEN_EXECUTABLE}
		ARGS   ${api_doc}
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src
		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			${logo_file}
			${output_path}
		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			${right_arrow}
			${output_path}
		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			${sbml_js}
			${output_path}
		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			${tabs_css}
			${output_path}
		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			${search_png}
			${search_path}
		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			${search_css}
			${search_path}
		COMMENT "Generate ${lang}-API Documentation"
		DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt

	)

	add_custom_target(api_docs_${lang} ALL DEPENDS
		${CMAKE_CURRENT_SOURCE_DIR}/formatted/${lang}-api/index.html
		${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt)

	if (${lang} STREQUAL "python")
		add_dependencies(api_docs_${lang} api_docs_python_py)
	endif()
	

	install(DIRECTORY ${output_path} DESTINATION ${MISC_PREFIX}docs )

endmacro()

createManual(c)
createManual(cpp)

# create python-api manuals
if (WITH_PYTHON)
	file(GLOB PYTHON_SUBSTITUTIONS ${CMAKE_CURRENT_SOURCE_DIR}/src/python-substitutions/*.py)
	ADD_CUSTOM_COMMAND(
		OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/src/libsbml.py
		COMMAND ${PYTHON_EXECUTABLE}
		ARGS    pythondocpreprocessor.py
				${CMAKE_CURRENT_BINARY_DIR}/../src/bindings/python/libsbml-doxygen.py  
				libsbml.py
				${PYTHON_SUBSTITUTIONS}
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src
		COMMENT "Generate libsbml.py"
		DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
	)	
	add_custom_target(api_docs_python_py ALL DEPENDS
		${CMAKE_CURRENT_SOURCE_DIR}/src/libsbml.py)
	createManual(python)
endif()

# create perl-api manuals
if (WITH_PERL)
	createManual(perl)
endif()

# create C#-api manuals
if (WITH_CSHARP)
	createManual(csharp)
endif()

# create java-api manuals
if (WITH_JAVA)
	# find java doc jar
	if (NOT EXISTS "${Java_JAVADOC_JAR}")
		get_filename_component(JDK_PATH ${Java_JAVA_EXECUTABLE} PATH )
		file(TO_NATIVE_PATH "${JDK_PATH}/../lib/tools.jar" Java_JAVADOC_JAR)
		if (NOT EXISTS "${Java_JAVADOC_JAR}")
			if (UNIX)
				if (APPLE)
					set(Java_JAVADOC_JAR "/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Classes/classes.jar")
				else()
					set(Java_JAVADOC_JAR ${JAVA_INCLUDE_PATH}/../lib/tools.jar)
				endif()
			endif()
		endif()
	endif()
	set(Java_JAVADOC_JAR ${Java_JAVADOC_JAR} CACHE FILEPATH "Location of javadoc jar")

	if (NOT EXISTS "${Java_JAVADOC_JAR}")
		message(FATAL_ERROR "Cannot generate java documentation, please specify the Java_JAVADOC_JAR.")
	endif()

	set(LIBSBML_JAVA_DIR "${CMAKE_CURRENT_BINARY_DIR}/../src/bindings/java/java-files")
	set(LIBSBML_JAVADOC_DOCTITLE "${PACKAGE_NAME} ${PACKAGE_VERSION} Java API Reference")
	set(LIBSBML_JAVADOC_HEADER "<B>${PACKAGE_NAME}<BR>${PACKAGE_VERSION}</B>")
	set(LIBSBML_JAVADOC_WINDOWTITLE "LibSBML Java API")
	file(READ "${CMAKE_CURRENT_SOURCE_DIR}/src/libsbml-java-footer.html"  LIBSBML_JAVADOC_FOOTER)
	string(STRIP 	${LIBSBML_JAVADOC_FOOTER} LIBSBML_JAVADOC_FOOTER)
	string(REGEX REPLACE "\n" "" LIBSBML_JAVADOC_FOOTER "${LIBSBML_JAVADOC_FOOTER}")


	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen-config-perl.txt api_doc)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_BINARY_DIR} current_dir)
	file(TO_NATIVE_PATH ${LIBSBML_JAVA_DIR} java_dir)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/formatted/java-api output_dir)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/formatted/java-api/org/sbml/libsbml/ java_output_dir)
	file(TO_NATIVE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src/common-graphics/* graphics_files)

	file(GLOB graphics_files ${CMAKE_CURRENT_SOURCE_DIR}/src/common-graphics/*.jpg)
	foreach(graphic ${graphics_files})
		file(COPY ${graphic} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/formatted/java-api/org/sbml/libsbml/)
	endforeach()


	ADD_CUSTOM_COMMAND(
		OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/formatted/java-api/index.html
		COMMAND ${Java_JAVAC_EXECUTABLE}
		ARGS -nowarn
			 -cp "${Java_JAVADOC_JAR}"
			 ${CMAKE_CURRENT_SOURCE_DIR}/src/SBMLDoclet.java
			  -d "${current_dir}"
		COMMAND ${Java_JAVA_EXECUTABLE}
		ARGS  -cp "${Java_JAVADOC_JAR}${FILE_SEP}${current_dir}"
		      SBMLDoclet
			  -excludefile java-skip.txt
			  -use -public -version -author -sourcetab 4 -keywords
			  -link http://java.sun.com/j2se/1.5.0/docs/api
			  -nodeprecated
			  -header "${LIBSBML_JAVADOC_HEADER}"
			  -bottom "${LIBSBML_JAVADOC_FOOTER}"
			  -windowtitle ${LIBSBML_JAVADOC_WINDOWTITLE}
			  -doctitle ${LIBSBML_JAVADOC_DOCTITLE}
			  -overview libsbml-java-fake-overview.html
			  -stylesheetfile doxygen-base-stylesheet.css
			  -d ${output_dir}
			  -tag note:a:"Note:"
	          -tag warning:a:"Warning:"
	          -tag docnote:a:"Documentation note:"
	          -sourcepath ${java_dir} org.sbml.libsbml
		COMMENT "Generate Java-API Documentation"
		VERBATIM
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src

		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			"${logo_file}"
			"${output_dir}"

		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			"${sbml_js}"
			"${output_dir}"

		COMMAND "${CMAKE_COMMAND}"
		ARGS -E copy
			"${tabs_css}"
			"${output_dir}"

#		COMMAND "${CMAKE_COMMAND}"
#		ARGS -E copy
#			${logo_file}
#			${java_output_dir}
#
		COMMAND "${CMAKE_COMMAND}"
		ARGS -DPACKAGE_VERSION=\"${PACKAGE_VERSION}\"
			-Djava_manual=${CMAKE_CURRENT_SOURCE_DIR}/formatted/java-api
			-P ${CMAKE_CURRENT_SOURCE_DIR}/process-java-doc.cmake

		DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
				${CMAKE_CURRENT_SOURCE_DIR}/process-java-doc.cmake

		)

	add_custom_target(api_docs_java ALL DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/formatted/java-api/index.html)

	install(DIRECTORY ${output_dir} DESTINATION ${MISC_PREFIX}docs )

endif()


endif()
