/**
 * casting to most specific SBMLExtension object
 */

#ifdef USE_LAYOUT
%pragma(java) modulecode =
%{
    if (pkgName.equals("layout"))
		return new LayoutExtension(cPtr, owner);
	%}
#endif // USE_LAYOUT		
