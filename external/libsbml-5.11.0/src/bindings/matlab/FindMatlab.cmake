# - this module looks for Matlab
# Defines:
#  MATLAB_INCLUDE_DIR: include path for mex.h, engine.h
#  MATLAB_LIBRARIES:   required libraries: libmex, etc
#  MATLAB_MEX_LIBRARY: path to libmex.lib
#  MATLAB_MX_LIBRARY:  path to libmx.lib
#  MATLAB_ENG_LIBRARY: path to libeng.lib

# This file is based on the one coming with the CMAKE distro, however it needed adapting!
# I added a new variable: 
#
# MATLAB_ROOT_PATH which is the path to the Matlab Directory it can also be specified by the users!
#

#=============================================================================
# Copyright 2005-2009 Kitware, Inc.
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distributed this file outside of CMake, substitute the full
#  License text for the above reference.)

SET(MATLAB_FOUND 0)
SET(MATLAB_MEXOPTS_FILE)
SET(MATLAB_ROOT_PATH)
SET(MATLAB_MEXEXT)
#
if (NOT "${MATLAB_ROOT_PATH}")
	if(UNIX)
		if (APPLE)
			if(EXISTS "/Applications/MATLAB_R2014b.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2014b.app/")	
			elseif(EXISTS "/Applications/MATLAB_R2014a.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2014a.app/")	
			elseif(EXISTS "/Applications/MATLAB_R2013b.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2013b.app/")	
			elseif(EXISTS "/Applications/MATLAB_R2013a.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2013a.app/")	
			elseif(EXISTS "/Applications/MATLAB_R2012b.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2012b.app/")	
			elseif(EXISTS "/Applications/MATLAB_R2012a.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2012a.app/")	
			elseif(EXISTS "/Applications/MATLAB_R2011b.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2011b.app/")	
			elseif(EXISTS "/Applications/MATLAB_R2011a.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2011a.app/")	
			elseif (EXISTS "/Applications/MATLAB_R2010b.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2010b.app/")
			elseif(EXISTS "/Applications/MATLAB_R2010a.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2010a.app/")
			elseif(EXISTS "/Applications/MATLAB_R2009b.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2009b.app/")
			elseif(EXISTS "/Applications/MATLAB_R2009a.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2009a.app/")					
			elseif(EXISTS "/Applications/MATLAB_R2008b.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2008b.app/")
			elseif(EXISTS "/Applications/MATLAB_R2008a.app/")
				set(MATLAB_ROOT_PATH "/Applications/MATLAB_R2008a.app/")	
			endif()
		else()
			if (EXISTS "/opt/matlab/")
				set(MATLAB_ROOT_PATH "/opt/matlab/")
			endif()
		endif()
	else()
		if (CMAKE_SIZEOF_VOID_P EQUAL 4)
			if (EXISTS "C:/Program Files (x86)/MATLAB/R2011b")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2011b")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2011a")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2011a")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2012b")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2012b")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2012a")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2012a")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2013b")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2013b")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2013a")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2013a")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2014b")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2014b")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2014a")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2014a")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2010b")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2010b")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2010a")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2010a")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2009b")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2009b")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2009a")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2009a")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2008b")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2008b")
			elseif (EXISTS "C:/Program Files (x86)/MATLAB/R2008a")
				set(MATLAB_ROOT_PATH "C:/Program Files (x86)/MATLAB/R2008a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2011b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2011b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2011a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2011a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2012b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2012b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2012a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2012a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2011b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2011b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2011a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2011a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2010b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2010b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2010a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2010a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2009b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2009b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2009a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2009a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2008b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2008b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2008a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2008a")
			endif()
		else()
			if (EXISTS "C:/Program Files/MATLAB/R2011b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2011b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2011a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2011a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2012b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2012b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2012a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2012a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2013b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2013b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2013a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2013a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2014b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2014b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2014a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2014a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2010b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2010b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2010a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2010a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2009b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2009b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2009a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2009a")
			elseif (EXISTS "C:/Program Files/MATLAB/R2008b")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2008b")
			elseif (EXISTS "C:/Program Files/MATLAB/R2008a")
				set(MATLAB_ROOT_PATH "C:/Program Files/MATLAB/R2008a")
			endif()
		endif()
	endif()
endif() 

if (NOT EXISTS "${MATLAB_ROOT_PATH}")
	message(FATAL_ERROR "The Matlab installation could not be found, please specify the MATLAB_ROOT_PATH.")
else()
	set(MATLAB_ROOT_PATH "${MATLAB_ROOT_PATH}" CACHE PATH "Matlab directory")
endif()

SET(MATLAB_MEX_COMMAND)
SET(MATLAB_MATLAB_COMMAND)
IF(WIN32)
  IF(${CMAKE_GENERATOR} MATCHES "Visual Studio 6")
    SET(MATLAB_ROOT "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\7.0;MATLABROOT]/extern/lib/win32/microsoft/msvc60")
	if(NOT EXISTS "${MATLAB_ROOT}")
		SET(MATLAB_ROOT "${MATLAB_ROOT_PATH}/extern/lib/win32/microsoft/msvc60")
	endif()
  ELSE(${CMAKE_GENERATOR} MATCHES "Visual Studio 6")
    IF(${CMAKE_GENERATOR} MATCHES "Visual Studio 7")
      # Assume people are generally using 7.1,
      # if using 7.0 need to link to: ../extern/lib/win32/microsoft/msvc70
      SET(MATLAB_ROOT "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\7.0;MATLABROOT]/extern/lib/win32/microsoft/msvc71")
	  if(NOT EXISTS "${MATLAB_ROOT}")
		SET(MATLAB_ROOT "${MATLAB_ROOT_PATH}/extern/lib/win32/microsoft/msvc71")
	  endif()
    ELSE(${CMAKE_GENERATOR} MATCHES "Visual Studio 7")
      IF(${CMAKE_GENERATOR} MATCHES "Borland")
        # Same here, there are also: bcc50 and bcc51 directories
        SET(MATLAB_ROOT "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\7.0;MATLABROOT]/extern/lib/win32/microsoft/bcc54")
		if(NOT EXISTS "${MATLAB_ROOT}")
			SET(MATLAB_ROOT "${MATLAB_ROOT_PATH}/extern/lib/win32/microsoft/bcc54")
		endif()
      ELSE(${CMAKE_GENERATOR} MATCHES "Borland")
        IF(MATLAB_FIND_REQUIRED)
          MESSAGE(FATAL_ERROR "Generator not compatible: ${CMAKE_GENERATOR}")
        ENDIF(MATLAB_FIND_REQUIRED)
      ENDIF(${CMAKE_GENERATOR} MATCHES "Borland")
    ENDIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 7")
  ENDIF(${CMAKE_GENERATOR} MATCHES "Visual Studio 6")
  
  # unfortunately this won't find matlab R2010b on my machine
  if (NOT "${MATLAB_ROOT}")
		SET(MATLAB_MEX_COMMAND "${MATLAB_ROOT_PATH}/bin/mex.bat")
		if (CMAKE_SIZEOF_VOID_P EQUAL 4)
			SET(MATLAB_ROOT "${MATLAB_ROOT_PATH}/extern/lib/win32/microsoft/")
		else()
			SET(MATLAB_ROOT "${MATLAB_ROOT_PATH}/extern/lib/win64/microsoft/")
		endif()
  endif()
  SET(MATLAB_MEXEXT "${MATLAB_ROOT_PATH}/bin/mexext.bat")
  SET(MATLAB_MATLAB_COMMAND "${MATLAB_ROOT_PATH}/bin/matlab.bat")
ELSE (WIN32)
	SET(MATLAB_MEX_COMMAND "${MATLAB_ROOT_PATH}/bin/mex")
	SET(MATLAB_MEXEXT ${MATLAB_ROOT_PATH}/bin/mexext)
	SET(MATLAB_MATLAB_COMMAND "${MATLAB_ROOT_PATH}/bin/matlab")
	MESSAGE(STATUS ${MATLAB_ROOT_PATH}/bin/maci64/)
	if(APPLE)
		SET(MATLAB_ROOT 
			${MATLAB_ROOT_PATH}/extern/lib/maci64/
			${MATLAB_ROOT_PATH}/bin/maci64/
		)
	else()

		IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
		# Regular x86
		SET(MATLAB_ROOT
		/usr/local/matlab-7sp1/bin/glnx86/
		/opt/matlab-7sp1/bin/glnx86/
		$ENV{HOME}/matlab-7sp1/bin/glnx86/
		$ENV{HOME}/redhat-matlab/bin/glnx86/
		${MATLAB_ROOT_PATH}/bin/glnx86/
		)
		ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
		# AMD64:
		SET(MATLAB_ROOT
		/usr/local/matlab-7sp1/bin/glnxa64/
		/opt/matlab-7sp1/bin/glnxa64/
		$ENV{HOME}/matlab7_64/bin/glnxa64/
		$ENV{HOME}/matlab-7sp1/bin/glnxa64/
		$ENV{HOME}/redhat-matlab/bin/glnxa64/
		${MATLAB_ROOT_PATH}/bin/glnxa64/
		)
		ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
	endif()
ENDIF(WIN32)
    
  FIND_LIBRARY(MATLAB_MEX_LIBRARY
    NAMES libmex mex  libmex.dylib
    PATHS
	${MATLAB_ROOT}
	${MATLAB_ROOT_PATH}/bin/maci64/
    )
  FIND_LIBRARY(MATLAB_MX_LIBRARY
    NAMES libmx mx  libmx.dylib
	PATHS
    ${MATLAB_ROOT}
	${MATLAB_ROOT_PATH}/bin/maci64/
    )
  FIND_LIBRARY(MATLAB_ENG_LIBRARY
    NAMES libeng eng libeng.dylib
	PATHS
    ${MATLAB_ROOT}
	${MATLAB_ROOT_PATH}/bin/maci64/
    )

  FIND_PATH(MATLAB_INCLUDE_DIR
    "mex.h"
	PATHS
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\7.0;MATLABROOT]/extern/include"
	"C:/Program Files (x86)/MATLAB/R2010b/extern/include"
	"C:/Program Files/MATLAB/R2010b/extern/include"
	"/Applications/MATLAB_R2010b.app/extern/include"
    "${MATLAB_ROOT_PATH}/extern/include"
    "/usr/local/matlab-7sp1/extern/include/"
    "/opt/matlab-7sp1/extern/include/"
    "$ENV{HOME}/matlab-7sp1/extern/include/"
    "$ENV{HOME}/redhat-matlab/extern/include/"
    )

# This is common to UNIX and Win32:
SET(MATLAB_LIBRARIES
  ${MATLAB_MEX_LIBRARY}
  ${MATLAB_MX_LIBRARY}
  ${MATLAB_ENG_LIBRARY}
)

IF(MATLAB_INCLUDE_DIR AND MATLAB_LIBRARIES)
  SET(MATLAB_FOUND 1)
ENDIF(MATLAB_INCLUDE_DIR AND MATLAB_LIBRARIES)



execute_process(COMMAND ${MATLAB_MEXEXT} OUTPUT_VARIABLE MATLAB_MEX_EXT)
STRING(STRIP "${MATLAB_MEX_EXT}" MATLAB_MEX_EXT)

MARK_AS_ADVANCED(
  MATLAB_LIBRARIES
  MATLAB_MEX_LIBRARY
  MATLAB_MX_LIBRARY
  MATLAB_ENG_LIBRARY
  MATLAB_INCLUDE_DIR
  MATLAB_FOUND
  MATLAB_MATLAB_COMMAND
  MATLAB_ROOT
  MATLAB_ROOT_PATH
)

