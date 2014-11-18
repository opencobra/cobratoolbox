/**
 * casting to most specific SBMLExtension object
 */
 
#ifdef USE_LAYOUT
%pragma(csharp) modulecode =
%{
		if (pkgName == "layout")
			return new LayoutExtension(cPtr, owner);
%}
#endif /* USE_LAYOUT */
