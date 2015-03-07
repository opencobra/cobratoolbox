#include "utility.h"


#include <sbml/xml/XMLAttributes.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * This function compares two XMLNodes if they have identical content.
 * If the two nodes are identical, the function returns true.
 */
bool compareXMLNodes(const XMLNode& node1,const XMLNode& node2)
{
  bool equal=true;
  // check if the nodes have the same name, the same namespace uri, the same attributes and the same number of children
  equal=(node1.getName()==node2.getName());
  equal=(equal && (node1.getURI()==node2.getURI()));
  XMLAttributes attr1=node1.getAttributes();
  XMLAttributes attr2=node2.getAttributes();
  int i=0,iMax=attr1.getLength();
  equal=(iMax==attr2.getLength());
  std::string attrName;
  while(equal && i<iMax)
  {
    attrName=attr1.getName(i);
    equal=(attr2.getIndex(attrName)!=-1);
    // also check the namspace
    equal=(equal && (attr1.getURI(i)==attr2.getURI(i)));
    ++i;
  }
  // recursively check all children
  i=0;
  iMax=node1.getNumChildren();
  equal=(equal && (iMax==(int)node2.getNumChildren()));
  while(equal && i<iMax)
  {
    equal=compareXMLNodes(node1.getChild(i),node2.getChild(i));
    ++i;
  }
  return equal;
}

LIBSBML_CPP_NAMESPACE_END
