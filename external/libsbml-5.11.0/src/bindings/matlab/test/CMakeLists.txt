####################################################################
#
# test matlab language bindings
#

if(WITH_CHECK)

	# copy test files
	file(GLOB files ${CMAKE_CURRENT_SOURCE_DIR}/*.m)
	foreach(testfile ${files})
		file(COPY ${testfile} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
	endforeach()

	# copy test missing m-files
	file(GLOB files ${CMAKE_CURRENT_SOURCE_DIR}/../*.m)
	foreach(testfile ${files})
		file(COPY ${testfile} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/../)
	endforeach()

	# copy test data
	file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/test-data DESTINATION ${CMAKE_CURRENT_BINARY_DIR}  )
	file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/Out-test")
	add_test(test_matlab_binding "${MATLAB_MATLAB_COMMAND}" -nosplash -nodesktop -memmgr debug -logfile runTests.log -r "runTests;quit;")

	if(UNIX)
		if(APPLE)
			set_tests_properties(test_matlab_binding PROPERTIES ENVIRONMENT "DYLD_LIBRARY_PATH=${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../../../:$ENV{DYLD_LIBRARY_PATH}")
		else()
			set_tests_properties(test_matlab_binding PROPERTIES ENVIRONMENT "LD_LIBRARY_PATH=/usr/lib/:${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR}/../../../:$ENV{LD_LIBRARY_PATH}")
		endif()
	endif()
	
endif()

