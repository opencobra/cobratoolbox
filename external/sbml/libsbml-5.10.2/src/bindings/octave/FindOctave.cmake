# Try to find the build flags to compile octave shared objects (oct and mex files)
# Once done this will define
#
# OCTAVE_FOUND - if octave is found
# OCTAVE_CXXFLAGS - extra flags
# OCTAVE_INCLUDE_DIRS - include directories
# OCTAVE_LINK_DIRS - link directories
# OCTAVE_LIBRARY_RELEASE - the relase version
# OCTAVE_LIBRARY_DEBUG - the debug version
# OCTAVE_LIBRARY - a default library, with priority debug.

# use mkoctfile
set(MKOCTFILE_EXECUTABLE)
set(OCTAVE_EXECUTABLE)
find_program(MKOCTFILE_EXECUTABLE NAME mkoctfile PATHS)
find_program(OCTAVE_EXECUTABLE NAME octave PATHS)

# use octave_config
set(OCTAVE_CONFIG_EXECUTABLE)
find_program(OCTAVE_CONFIG_EXECUTABLE NAME octave-config PATHS)


if(MKOCTFILE_EXECUTABLE)
  set(OCTAVE_FOUND 1)

  execute_process(
    COMMAND ${MKOCTFILE_EXECUTABLE} -p ALL_CXXFLAGS
    OUTPUT_VARIABLE _mkoctfile_cppflags
    RESULT_VARIABLE _mkoctfile_failed)
  string(REGEX REPLACE "[\r\n]" " " _mkoctfile_cppflags "${_mkoctfile_cppflags}")
  execute_process(
    COMMAND ${MKOCTFILE_EXECUTABLE} -p INCFLAGS
    OUTPUT_VARIABLE _mkoctfile_includedir
    RESULT_VARIABLE _mkoctfile_failed)
  string(REGEX REPLACE "[\r\n]" " " _mkoctfile_includedir "${_mkoctfile_includedir}")
  string(REGEX REPLACE "-I" " " _mkoctfile_includedir "${_mkoctfile_includedir}")
  execute_process(
    COMMAND ${MKOCTFILE_EXECUTABLE} -p ALL_LDFLAGS
    OUTPUT_VARIABLE _mkoctfile_ldflags
    RESULT_VARIABLE _mkoctfile_failed)
  string(REGEX REPLACE "[\r\n]" " " _mkoctfile_ldflags "${_mkoctfile_ldflags}")
  execute_process(
    COMMAND ${MKOCTFILE_EXECUTABLE} -p LFLAGS
    OUTPUT_VARIABLE _mkoctfile_lflags
    RESULT_VARIABLE _mkoctfile_failed)
  string(REGEX REPLACE "[\r\n]" " " _mkoctfile_lflags "${_mkoctfile_lflags}")
  execute_process(
    COMMAND ${MKOCTFILE_EXECUTABLE} -p LIBS
    OUTPUT_VARIABLE _mkoctfile_libs
    RESULT_VARIABLE _mkoctfile_failed)
  string(REGEX REPLACE "[\r\n]" " " _mkoctfile_libs "${_mkoctfile_libs}")
  execute_process(
    COMMAND ${MKOCTFILE_EXECUTABLE} -p OCTAVE_LIBS
    OUTPUT_VARIABLE _mkoctfile_octlibs
    RESULT_VARIABLE _mkoctfile_failed)
  string(REGEX REPLACE "[\r\n]" " " _mkoctfile_octlibs "${_mkoctfile_octlibs}")
  set(_mkoctfile_libs "${_mkoctfile_libs} ${_mkoctfile_octlibs}")

  string(REGEX MATCHALL "(^| )-l([./+-_\\a-zA-Z]*)" _mkoctfile_libs "${_mkoctfile_libs}")
  string(REGEX REPLACE "(^| )-l" "" _mkoctfile_libs "${_mkoctfile_libs}")

  string(REGEX MATCHALL "(^| )-L([./+-_\\a-zA-Z]*)" _mkoctfile_ldirs "${_mkoctfile_lflags}")
  string(REGEX REPLACE "(^| )-L" "" _mkoctfile_ldirs "${_mkoctfile_ldirs}")

  string(REGEX REPLACE "(^| )-l([./+-_\\a-zA-Z]*)" " " _mkoctfile_ldflags "${_mkoctfile_ldflags}")
  string(REGEX REPLACE "(^| )-L([./+-_\\a-zA-Z]*)" " " _mkoctfile_ldflags "${_mkoctfile_ldflags}")

  separate_arguments(_mkoctfile_includedir)

  set( OCTAVE_CXXFLAGS " ${_mkoctfile_cppflags}" )
  set( OCTAVE_LINK_FLAGS " ${_mkoctfile_ldflags} " )
  set( OCTAVE_INCLUDE_DIRS " ${_mkoctfile_includedir}")
  set( OCTAVE_LINK_DIRS ${_mkoctfile_ldirs})
  set( OCTAVE_LIBRARY ${_mkoctfile_libs})
  set( OCTAVE_LIBRARY_RELEASE " ${OCTAVE_LIBRARY} ")
  set( OCTAVE_LIBRARY_DEBUG " ${OCTAVE_LIBRARY} ")
endif(MKOCTFILE_EXECUTABLE)
if(OCTAVE_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND ${OCTAVE_CONFIG_EXECUTABLE} -p CANONICAL_HOST_TYPE
    OUTPUT_VARIABLE _octave_config_host_type
    RESULT_VARIABLE _octave_config_failed)
  string(REGEX REPLACE "[\r\n]""" _octave_config_host_type "${_octave_config_host_type}")
  execute_process(
    COMMAND ${OCTAVE_CONFIG_EXECUTABLE} -p API_VERSION
    OUTPUT_VARIABLE _octave_config_api_version
    RESULT_VARIABLE _octave_config_failed)
  string(REGEX REPLACE "[\r\n]""" _octave_config_api_version "${_octave_config_api_version}")
  execute_process(
    COMMAND ${OCTAVE_CONFIG_EXECUTABLE} -p LOCALVEROCTFILEDIR
    OUTPUT_VARIABLE _octave_config_localveroctfiledir
    RESULT_VARIABLE _octave_config_failed)
  string(REGEX REPLACE "[\r\n]""" _octave_config_localveroctfiledir "${_octave_config_localveroctfiledir}")

  set( OCTAVE_HOST_TYPE "${_octave_config_host_type}" )
  set( OCTAVE_API_VERSION "${_octave_config_api_version}" )
  set( OCTAVE_LOCALVEROCTFILEDIR "${_octave_config_localveroctfiledir}" )

endif(OCTAVE_CONFIG_EXECUTABLE)


MARK_AS_ADVANCED(
    OCTAVE_LIBRARY_FOUND
    OCTAVE_CXXFLAGS
    OCTAVE_LINK_FLAGS
    OCTAVE_INCLUDE_DIRS
    OCTAVE_LINK_DIRS
    OCTAVE_LIBRARY
    OCTAVE_LIBRARY_RELEASE
	OCTAVE_EXECUTABLE
    OCTAVE_LIBRARY_DEBUG
	MKOCTFILE_EXECUTABLE
	OCTAVE_CONFIG_EXECUTABLE
)
