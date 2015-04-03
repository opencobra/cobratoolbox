###############################################################################
#
# Description       : CMake build script for creating the R package
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

# message("Creating: R package")

#execute R without letting it print to the command line: 

set(var_std_out)
set(var_std_err)

execute_process(COMMAND "${R_INTERPRETER}"
                ARGS  CMD INSTALL --build
                --no-libs
                --no-test-load
                --no-clean-on-error
                --no-multiarch
                libSBML
                -l temp
                OUTPUT_VARIABLE var_std_out
                ERROR_VARIABLE var_std_err
)

# here we search for what file has been produced, and print information to the user
file(GLOB GENERATED_FILES *.tgz *.tar.gz *.zip)
list(LENGTH GENERATED_FILES NUM_FILES)

if (NUM_FILES GREATER 0)

set(R_ARCHIVE "${GENERATED_FILES}" ${PACKAGE_NAME} CACHE STRING "")

message(STATUS "Created package: ${GENERATED_FILES}")

else()

message(STATUS "

The R package could not be created, the following error occured
${var_std_out}
${var_std_err}
")

endif()
