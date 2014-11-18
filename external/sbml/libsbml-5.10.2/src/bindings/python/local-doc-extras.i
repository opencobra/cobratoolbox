%feature("docstring") Model::renameIDs "
";


%feature("docstring") SBasePlugin::getListOfAllElements "
@return an SBaseList of all child SBase objects, including those
nested to an arbitrary depth.

@return a list of all child objects.
";



%feature("docstring") SBase::getListOfAllElements "
@return an SBaseList of all child SBase objects, including those
nested to an arbitrary depth.

@return a list of all child objects.
";


%feature("docstring") SBase::getListOfAllElementsFromPlugins "
@return an SBaseList of all child SBase objects contained in SBML package
plug-ins.

This method walks down the list of all SBML Level 3 packages used by the
model, and returns all objects contained in them.

@return an SBaseList of all children objects from package plug-ins.
";


%feature("docstring") ASTNode::getListOfNodes "
@return an ASTNodeList of all ASTNode objects.

Unlike the equivalent method in the libSBML C/C++ interface, this method does
not offer the ability to pass a predicate as an argument.  The method always
returns the list of all ASTNode objects.

@return the ASTNodeList of nodes.

@warning The list returned is owned by the caller and should be deleted after
the caller is done using it.  The ASTNode objects in the list; however, are
<strong>not</strong> owned by the caller (as they still belong to the tree
itself), and therefore should not be deleted.
";
