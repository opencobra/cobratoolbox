## @file    CMakeLists.txt
## @brief   CMake build script for example programs
## @author  Frank T. Bergmann
##
## <!--------------------------------------------------------------------------
## This file is part of libSBML.  Please visit http://sbml.org for more
## information about SBML, and the latest version of libSBML.
##
## Copyright (C) 2013-2014 jointly by the following organizations:
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##     3. University of Heidelberg, Heidelberg, Germany
##
## Copyright (C) 2009-2013 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##  
## Copyright (C) 2006-2008 by the California Institute of Technology,
##     Pasadena, CA, USA 
##  
## Copyright (C) 2002-2005 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. Japan Science and Technology Agency, Japan
## 
## This library is free software; you can redistribute it and/or modify it
## under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation.  A copy of the license agreement is provided
## in the file named "LICENSE.txt" included with this software distribution
## and also available online as http://sbml.org/software/libsbml/license.html
## ------------------------------------------------------------------------ -->

# only compile examples if specified, but always copy samples
if(WITH_EXAMPLES)

add_subdirectory(c)
add_subdirectory(c++)

if(WITH_CSHARP)
  add_subdirectory(csharp)
endif(WITH_CSHARP)

if(WITH_JAVA)
  add_subdirectory(java)
endif(WITH_JAVA)

file(GLOB PACKAGE_EXAMPLES "*package.cmake")
foreach(package ${PACKAGE_EXAMPLES})
    include(${package})
endforeach()

endif(WITH_EXAMPLES)



# the remaining language bindings do not need to be compiled in order to run. 

# Now we just have to select files for installation# 
install(FILES README.txt DESTINATION ${MISC_PREFIX}examples)

# install c examples
file(GLOB c_samples "${CMAKE_CURRENT_SOURCE_DIR}/c/*.c"
                    "${CMAKE_CURRENT_SOURCE_DIR}/c/*.h"
                    "${CMAKE_CURRENT_SOURCE_DIR}/c/README.txt")
install(FILES ${c_samples} DESTINATION ${MISC_PREFIX}examples/c)

# install c++ examples
file(GLOB cpp_samples "${CMAKE_CURRENT_SOURCE_DIR}/c++/*.c"
                      "${CMAKE_CURRENT_SOURCE_DIR}/c++/*.cpp"
                      "${CMAKE_CURRENT_SOURCE_DIR}/c++/*.h"
                      "${CMAKE_CURRENT_SOURCE_DIR}/c++/README.txt")
install(FILES ${cpp_samples} DESTINATION ${MISC_PREFIX}examples/c++)

if(WITH_CSHARP)
# install c# examples
file(GLOB cs_samples "${CMAKE_CURRENT_SOURCE_DIR}/csharp/*.cs"
                     "${CMAKE_CURRENT_SOURCE_DIR}/csharp/README.txt")
install(FILES ${cs_samples} DESTINATION ${MISC_PREFIX}examples/csharp)
endif()

if(WITH_JAVA)
# install java examples
file(GLOB java_samples "${CMAKE_CURRENT_SOURCE_DIR}/java/*.java"
                       "${CMAKE_CURRENT_SOURCE_DIR}/java/README.txt")
install(FILES ${java_samples} DESTINATION ${MISC_PREFIX}examples/java)
endif()

if(WITH_PERL)
# install perl examples
file(GLOB perl_samples "${CMAKE_CURRENT_SOURCE_DIR}/perl/*.pl"
                       "${CMAKE_CURRENT_SOURCE_DIR}/perl/README.txt")
install(FILES ${perl_samples} DESTINATION ${MISC_PREFIX}examples/perl)
endif()

if (WITH_PYTHON)
# install python examples
file(GLOB python_samples "${CMAKE_CURRENT_SOURCE_DIR}/python/*.py"
                         "${CMAKE_CURRENT_SOURCE_DIR}/python/README.txt")
install(FILES ${python_samples} DESTINATION ${MISC_PREFIX}examples/python)
endif()


if(WITH_RUBY)
# install ruby examples
file(GLOB perl_samples "${CMAKE_CURRENT_SOURCE_DIR}/ruby/*.rb"
                       "${CMAKE_CURRENT_SOURCE_DIR}/ruby/README.txt")
install(FILES ${perl_samples} DESTINATION ${MISC_PREFIX}examples/ruby)
endif()

if (WITH_R)
# install r examples
file(GLOB python_samples "${CMAKE_CURRENT_SOURCE_DIR}/r/*.R"
                         "${CMAKE_CURRENT_SOURCE_DIR}/r/README.txt")
install(FILES ${python_samples} DESTINATION ${MISC_PREFIX}examples/r)
endif()


#layout examples now follow the structure of other packages
#if (ENABLE_LAYOUT)
# install layout examples
#file(GLOB layout_samples "${CMAKE_CURRENT_SOURCE_DIR}/layout/*.cpp"
#                         "${CMAKE_CURRENT_SOURCE_DIR}/layout/*.java"
#                         "${CMAKE_CURRENT_SOURCE_DIR}/layout/*.xsl"
#                         "${CMAKE_CURRENT_SOURCE_DIR}/layout/*.py"
#					 )
#install(FILES ${layout_samples} DESTINATION ${MISC_PREFIX}examples/layout)
#endif()

# install sample-models
file(GLOB l2_samples "${CMAKE_CURRENT_SOURCE_DIR}/sample-models/from-spec/level-2/*.xml")
install(FILES ${l2_samples} DESTINATION ${MISC_PREFIX}examples/sample-models/from-spec/level-2)

file(GLOB l3_samples "${CMAKE_CURRENT_SOURCE_DIR}/sample-models/from-spec/level-3/*.xml")
install(FILES ${l3_samples} DESTINATION ${MISC_PREFIX}examples/sample-models/from-spec/level-3)

