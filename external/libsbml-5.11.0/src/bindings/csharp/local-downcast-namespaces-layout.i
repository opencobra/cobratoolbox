/**
 * casting to most specific SBMLNamespaces object
 */


#ifdef USE_LAYOUT
%pragma(csharp) modulecode =
%{
	
	if (ns.hasURI(LayoutExtension.getXmlnsL3V1V1()) || ns.hasURI(LayoutExtension.getXmlnsL2()))
	{
		return new LayoutPkgNamespaces(cPtr, owner);
	}
	%}
#endif /* USE_LAYOUT */
