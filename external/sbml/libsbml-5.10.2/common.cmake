###############################################################################
#
# Description       : Common CMake macros for building libSBML
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

#
# Utility macros for copying files
#
macro(copy_files srcDir destDir pattern)
	message(STATUS "Copying files from ${srcDir}")
    make_directory(${destDir})

    file(GLOB templateFiles RELATIVE ${srcDir} ${srcDir}/${pattern})
    foreach(templateFile ${templateFiles})
        set(srcTemplatePath ${srcDir}/${templateFile})
        if(NOT IS_DIRECTORY ${srcTemplatePath})
            #message(STATUS "Copying file ${templateFile}")
            configure_file(
                    ${srcTemplatePath}
                    ${destDir}/${templateFile}
                    COPYONLY)
        endif(NOT IS_DIRECTORY ${srcTemplatePath})
    endforeach(templateFile)
		
endmacro(copy_files)

macro(copy_file srcFile destDir)
    message(STATUS "Copying ${srcFile}")
    make_directory(${destDir})
    get_filename_component(name ${srcFile} NAME)    

	if(NOT IS_DIRECTORY ${srcFile})
		configure_file(
			${srcFile}
			${destDir}/${name}
			COPYONLY)
	endif(NOT IS_DIRECTORY ${srcFile})
		
endmacro(copy_file)

macro(copy_file_to_subdir srcFile destDir)
	get_filename_component(subdir ${srcFile} PATH)
	get_filename_component(name ${srcFile} NAME)
    
	make_directory(${destDir}/${subdir})
	message(STATUS "Copying ${srcFile}")
	
	if(NOT IS_DIRECTORY ${srcFile})
		configure_file(
			${srcFile}
			${destDir}/${subdir}/${name}
			COPYONLY)
	endif(NOT IS_DIRECTORY ${srcFile})
		
endmacro(copy_file_to_subdir)

#
# Utility macros for removing files
#
macro(remove_file srcFile)
	if(EXISTS ${srcFile})
		message(STATUS "Remove ${srcFile}")	
		file(REMOVE ${srcFile})
	else()
		message(STATUS "Cannot remove ${srcFile} it does not exist.")
	endif()
endmacro(remove_file)

macro(remove_file_in_subdir srcFile baseDir)
	get_filename_component(subdir ${srcFile} PATH)
	get_filename_component(name ${srcFile} NAME)
	if(EXISTS ${baseDir}/${subdir}/${name})
		message(STATUS "Remove ${srcFile}")
		file(REMOVE ${baseDir}/${subdir}/${name})
	endif()
endmacro(remove_file_in_subdir)
