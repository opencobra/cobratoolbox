
#ifdef USE_LAYOUT
if (pkgName == "layout")
{
    if (sb->getTypeCode() == SBML_MODEL)
    {
		return SWIGTYPE_p_LayoutModelPlugin;
    }
    else if (sb->getTypeCode() == SBML_SPECIES_REFERENCE)
    {
		return SWIGTYPE_p_LayoutSpeciesReferencePlugin;
    } 
    else if (sb->getTypeCode() == SBML_MODIFIER_SPECIES_REFERENCE)
    {
		return SWIGTYPE_p_LayoutSpeciesReferencePlugin;
    } 
}
#endif // USE_LAYOUT

