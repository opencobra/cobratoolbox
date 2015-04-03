#
# This file applies post processing to the generated java documentation.
# 
#
#
#

macro(merge_html sourceFile targetFile title)
	
	file(READ "libsbml-java-top.html" top)
	file(READ "${sourceFile}" source)
	file(READ "libsbml-java-bottom.html" bottom)
	file(READ "libsbml-java-footer.html" footer)
	
	set(content "${top}${source}${bottom}${footer}")

	string(REPLACE "%%title%%" "${title}" content "${content}")
	string(REPLACE "%%version%%" "${PACKAGE_VERSION}" content "${content}")
	
	file(WRITE "${targetFile}" "${content}")
	
endmacro()

macro(merge_html_verb sourceFile targetFile title)

	file(READ "libsbml-java-top.html" top)
	file(READ "libsbml-java-verb-top.html" verb)
	file(READ "${sourceFile}" source)
	file(READ "libsbml-java-verb-bottom.html" verb_bottom)
	file(READ "libsbml-java-bottom.html" bottom)
	file(READ "libsbml-java-footer.html" footer)

	set(content "${top}${verb}${source}${verb_bottom}${bottom}${footer}")

	string(REPLACE "%%title%%" "${title}" content "${content}")
	string(REPLACE "%%version%%" "${PACKAGE_VERSION}" content "${content}")

	file(WRITE "${targetFile}" "${content}")	
	
endmacro()

macro(insert_javascript directory)

	file(GLOB html_files ${directory}/*.html)
	
	foreach(html ${html_files})
		file(READ "${html}" content)
		
		# only change if it is not included yet
		if(NOT "${content}" MATCHES "^.*sbml.js^.*")
		
			string(REPLACE "<SCRIPT type=\"text/javascript\">"
					"<script type=\"text/javascript\" src=\"../../../sbml.js\"></script><SCRIPT type=\"text/javascript\">"
					content ${content})
					
			file(WRITE "${html}" "${content}")
		
		endif()
		
	endforeach()
	
endmacro()

merge_html( "libsbml-java-overview.html" "${java_manual}/overview-summary.html" "Java ${PACKAGE_VERSION} API" )
merge_html( "libsbml-java-installation-guide.html" "${java_manual}/libsbml-java-installation-guide.html" "LibSBML installation" )
merge_html( "libsbml-java-reading.html" "${java_manual}/libsbml-java-reading.html" "Reading and writing SBML content" )
merge_html( "libsbml-java-math.html" "${java_manual}/libsbml-java-math.html" "Manipulating mathematical expressions" )
merge_html( "libsbml-java-misc.html" "${java_manual}/libsbml-java-misc.html" "Miscellaneous Java-specific information" )
merge_html( "libsbml-java-example-files.html" "${java_manual}/libsbml-java-example-files.html" "Example libSBML programs in Java" )
#merge_html( "libsbml-core-versus-packages.html" "${java_manual}/libsbml-core-versus-packages.html" "LibSBML &ldquo;core&rdquo; and extensions" )
#merge_html( "common-text/libsbml-installation.html" "${java_manual}/libsbml-installation.html" "LibSBML installation" )
#merge_html( "common-text/libsbml-downloading.html" "${java_manual}/libsbml-downloading.html" "LibSBML downloads" )
merge_html( "common-text/libsbml-features.html" "${java_manual}/libsbml-features.html" "LibSBML features" )
merge_html( "common-text/libsbml-setting-library-path.html" "${java_manual}/libsbml-setting-library-path.html" "Setting your library search path" )
merge_html( "common-text/libsbml-import-for-java.html" "${java_manual}/libsbml-import-for-java.html" "Accessing libSBML from Java software" )
merge_html( "common-text/libsbml-communications.html" "${java_manual}/libsbml-communications.html" "Bug reports and other communications" )
merge_html( "common-text/libsbml-issues.html" "${java_manual}/libsbml-issues.html" "Known issues and pitfalls" )
#merge_html( "common-text/sbml-specifications-table.html" "${java_manual}/libsbml-specifications.html" "SBML specifications" )
merge_html( "../../LICENSE.html" "${java_manual}/libsbml-license.html" "LibSBML license" )
merge_html_verb( "../../NEWS.txt" "${java_manual}/libsbml-news.html" "LibSBML news" )

insert_javascript("${java_manual}/org/sbml/libsbml")
