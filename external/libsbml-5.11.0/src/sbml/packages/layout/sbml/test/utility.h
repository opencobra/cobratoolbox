#ifndef LAYOUT_TESTS_UTILITY_H__
#define LAYOUT_TESTS_UTILITY_H__

#include <sbml/xml/XMLNode.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * This function compares two XMLNodes if they have identical content.
 * If the two nodes are identical, the function returns true.
 */
bool compareXMLNodes(const XMLNode& node1,const XMLNode& node2);

LIBSBML_CPP_NAMESPACE_END

#endif // LAYOUT_TESTS_UTILITY_H__
