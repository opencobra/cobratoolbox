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
merge_html( "libsbml-installation.html" "${java_manual}/libsbml-installation.html" "installation" )
merge_html( "libsbml-features.html" "${java_manual}/libsbml-features.html" "features" )
merge_html( "libsbml-accessing.html" "${java_manual}/libsbml-accessing.html" "accessibility to your software" )
merge_html( "libsbml-communications.html" "${java_manual}/libsbml-communications.html" "bug reports and other communications" )
merge_html( "libsbml-java-reading.html" "${java_manual}/libsbml-java-reading.html" "basic facilities for reading and writing SBML content" )
merge_html( "libsbml-java-math.html" "${java_manual}/libsbml-java-math.html" "facilities for manipulating mathematical expressions" )
merge_html( "libsbml-issues.html" "${java_manual}/libsbml-issues.html" "known issues and pitfalls" )
#merge_html( "libsbml-uninstallation.html" "${java_manual}/libsbml-uninstallation.html" "uninstallation" )
merge_html( "../../LICENSE.html" "${java_manual}/libsbml-license.html" "license" )

merge_html_verb( "../../NEWS.txt" "${java_manual}/libsbml-news.html" "news" )
merge_html_verb( "../../OLD_NEWS.txt" "${java_manual}/libsbml-old-news.html" "old-news" )

insert_javascript("${java_manual}/org/sbml/libsbml")
