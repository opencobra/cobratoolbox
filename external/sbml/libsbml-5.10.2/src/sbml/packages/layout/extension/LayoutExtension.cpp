/**
 * @file    LayoutExtension.cpp
 * @brief   Implementation of LayoutExtension, the core module of layout package.
 * @author  Akiya Jouraku
 * 
 * <!--------------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 * 
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/extension/SBMLExtensionRegister.h>
#include <sbml/extension/SBMLExtensionRegistry.h>
#include <sbml/extension/SBasePluginCreator.h>
#include <sbml/extension/SBMLDocumentPlugin.h>


#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/packages/layout/extension/LayoutModelPlugin.h>
#include <sbml/packages/layout/extension/LayoutSpeciesReferencePlugin.h>
#include <sbml/packages/layout/extension/LayoutSBMLDocumentPlugin.h>
#include <sbml/packages/layout/validator/LayoutSBMLErrorTable.h>


#ifdef __cplusplus

#include <iostream>

LIBSBML_CPP_NAMESPACE_BEGIN

// -------------------------------------------------------------------------
//
// This block is global initialization code which should be automatically 
// executed before invoking main() block.
//
// -------------------------------------------------------------------------

//------------- (START) -----------------------------------

// The name of this package

const std::string& LayoutExtension::getPackageName ()
{
	static const std::string pkgName = "layout";
	return pkgName;
}

//
// Default SBML level, version, and package version
//
unsigned int LayoutExtension::getDefaultLevel()
{
	return 3;
}  

unsigned int LayoutExtension::getDefaultVersion()
{
	return 1; 
}

unsigned int LayoutExtension::getDefaultPackageVersion()
{
	return 1;
} 

//
// XML namespaces of (1) package versions of layout extension, and 
// (2) another XML namespace(XMLSchema-instance) required in the layout 
//  extension.
//

const std::string& LayoutExtension::getXmlnsL3V1V1 ()
{
	static const std::string xmlns = "http://www.sbml.org/sbml/level3/version1/layout/version1";
	return xmlns;
}

const std::string& LayoutExtension::getXmlnsL2 ()
{
	static const std::string xmlns = "http://projects.eml.org/bcb/sbml/level2";
	return xmlns;
}

const std::string& LayoutExtension::getXmlnsXSI ()
{
	static const std::string xmlns = "http://www.w3.org/2001/XMLSchema-instance";
	return xmlns;
}

//
// Adds this LayoutExtension object to the SBMLExtensionRegistry class.
// LayoutExtension::init() function is automatically invoked when this
// object is instantiated.
//
static SBMLExtensionRegister<LayoutExtension> layoutExtensionRegistry;


static
const char* SBML_LAYOUT_TYPECODE_STRINGS[] =
{
    "BoundingBox"
  , "CompartmentGlyph"
  , "CubicBezier"
  , "Curve"
  , "Dimensions"
  , "GraphicalObject"
  , "Layout"
  , "LineSegment"
  , "Point"
  , "ReactionGlyph"
  , "SpeciesGlyph"
  , "SpeciesReferenceGlyph"
  , "TextGlyph"
  , "ReferenceGlyph"
  , "GeneralGlyph"

};

//------------- (END) -----------------------------------

// --------------------------------------------------------
//
// Instantiate SBMLExtensionNamespaces<LayoutExtension> 
// (LayoutPkgNamespaces) for DLL.
//
// --------------------------------------------------------

template class LIBSBML_EXTERN SBMLExtensionNamespaces<LayoutExtension>;


LayoutExtension::LayoutExtension ()
{
}


/*
 * Copy constructor.
 */
LayoutExtension::LayoutExtension(const LayoutExtension& orig)
: SBMLExtension(orig)
{
}


/*
 * Destroy this object.
 */
LayoutExtension::~LayoutExtension ()
{
}


/*
 * Assignment operator for LayoutExtension.
 */
LayoutExtension& 
LayoutExtension::operator=(const LayoutExtension& orig)
{
  SBMLExtension::operator=(orig);
  return *this;
}


/*
 * Creates and returns a deep copy of this LayoutExtension object.
 * 
 * @return a (deep) copy of this LayoutExtension object
 */
LayoutExtension* 
LayoutExtension::clone () const
{
  return new LayoutExtension(*this);  
}


const std::string& 
LayoutExtension::getName() const
{
  return getPackageName();
}


/*
 * Returns the URI (namespace) of the package corresponding to the combination of the given sbml level,
 * sbml version, and package version.
 * Empty string will be returned if no corresponding URI exists.
 *
 * @return a string of the package URI
 */
const std::string& 
LayoutExtension::getURI(unsigned int sbmlLevel, unsigned int sbmlVersion, unsigned int pkgVersion) const
{
  if (sbmlLevel == 3)
  {
    if (sbmlVersion == 1)
    {
      if (pkgVersion == 1)
      {
        return getXmlnsL3V1V1();
      }
    }
  }
  else if (sbmlLevel == 2)
  {
    return getXmlnsL2();
  }

  static std::string empty = "";

  return empty;
}


/*
 * Returns the SBML level with the given URI of this package.
 */
unsigned int 
LayoutExtension::getLevel(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
  {
    return 3;
  }
  else if (uri == getXmlnsL2())
  {
    return 2;
  }
  
  return 0;
}


/*
 * Returns the SBML version with the given URI of this package.
 */
unsigned int 
LayoutExtension::getVersion(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
  {
    return 1;
  }
  else if (uri == getXmlnsL2())
  {
    //
    // (NOTE) This may cause unexpected behaviour.
    //
    /* which indeed it does */
    return 1;
  }

  return 0;
}


/*
 * Returns the package version with the given URI of this package.
 */
unsigned int
LayoutExtension::getPackageVersion(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
  {
    return 1;
  }
  else if (uri == getXmlnsL2())
  {
    //  
    // (NOTE) This should be harmless but may cause some problem.
    //
    return 1;
  }

  return 0;
}


/*
 * Returns an SBMLExtensionNamespaces<class SBMLExtensionType> object 
 * (e.g. SBMLExtensionNamespaces<LayoutExtension> whose alias type is 
 * LayoutPkgNamespaces) corresponding to the given uri.
 * Null will be returned if the given uri is not defined in the corresponding package.
 */
SBMLNamespaces*
LayoutExtension::getSBMLExtensionNamespaces(const std::string &uri) const
{
  LayoutPkgNamespaces* pkgns = NULL;
  if ( uri == getXmlnsL3V1V1())
  {
    pkgns = new LayoutPkgNamespaces(3,1,1);    
  }  
  else if ( uri == getXmlnsL2())
  {
    //  
    // (NOTE) This should be harmless but may cause some problem.
    //
    pkgns = new LayoutPkgNamespaces(2);
  }  
  return pkgns;
}


/*
 * This method takes a type code of layout package and returns a string representing
 * the code.
 */
const char*
LayoutExtension::getStringFromTypeCode(int typeCode) const
{
  int min = SBML_LAYOUT_BOUNDINGBOX;
  int max = SBML_LAYOUT_GENERALGLYPH;

  if ( typeCode < min || typeCode > max)
  {
    return "(Unknown SBML Layout Type)";
  }

  return SBML_LAYOUT_TYPECODE_STRINGS[typeCode - min];
}


/** @cond doxygenLibsbmlInternal */
/*
 *
 * Initialization function of layout extension module which is automatically invoked 
 * by SBMLExtensionRegister class before main() function invoked.
 *
 */
void 
LayoutExtension::init()
{
  //-------------------------------------------------------------------------
  //
  // 1. Checks if the layout package has already been registered.
  //
  //-------------------------------------------------------------------------

  if (SBMLExtensionRegistry::getInstance().isRegistered(getPackageName()))
  {
    // do nothing;
    return;
  }

  //-------------------------------------------------------------------------
  //
  // 2. Creates an SBMLExtension derived object.
  //
  //-------------------------------------------------------------------------

  LayoutExtension layoutExtension;

  //-------------------------------------------------------------------------------------
  //
  // 3. Creates SBasePluginCreatorBase derived objects required for this extension. 
  //    The derived classes can be instantiated by using the following template class.
  //
  //    temaplate<class SBasePluginType> class SBasePluginCreator
  //
  //    The constructor of the creator class has two arguments:
  //
  //        (1) SBaseExtensionPoint : extension point to which the plugin object connected
  //        (2) std::vector<std::string> : a std::vector object that contains a list of URI
  //                                       (package versions) supported by the plugin object.
  //
  //    For example, three plugin classes (plugged in SBMLDocument, Model, and SpeciesReference) 
  //    are required for the layout extension (The plugin class for SpeciesReference is required
  //    only for SBML Level 2) .
  //
  //---------------------------------------------------------------------------------------

  std::vector<std::string> packageURIs;
  packageURIs.push_back(getXmlnsL3V1V1());
  packageURIs.push_back(getXmlnsL2());  

  // 
  // LayoutSpeciesReferencePlugin is used only for SBML Level 2
  //
  std::vector<std::string> L2packageURI;
  L2packageURI.push_back(getXmlnsL2());  

  SBaseExtensionPoint sbmldocExtPoint("core",SBML_DOCUMENT);
  SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);
  SBaseExtensionPoint sprExtPoint("core",SBML_SPECIES_REFERENCE);
  SBaseExtensionPoint msprExtPoint("core",SBML_MODIFIER_SPECIES_REFERENCE);

	SBasePluginCreator<LayoutSBMLDocumentPlugin, LayoutExtension> sbmldocPluginCreator(sbmldocExtPoint, packageURIs);
  SBasePluginCreator<LayoutModelPlugin,  LayoutExtension>           modelPluginCreator(modelExtPoint,packageURIs);
  SBasePluginCreator<LayoutSpeciesReferencePlugin, LayoutExtension> sprPluginCreator(sprExtPoint,L2packageURI);
  SBasePluginCreator<LayoutSpeciesReferencePlugin, LayoutExtension> msprPluginCreator(msprExtPoint,L2packageURI);

  //------------------------------------------------------------------------------------------
  //
  // 4. Adds the above SBasePluginCreatorBase derived objects to the SBMLExtension derived object.
  //
  //------------------------------------------------------------------------------------------

  layoutExtension.addSBasePluginCreator(&sbmldocPluginCreator);
  layoutExtension.addSBasePluginCreator(&modelPluginCreator);
  layoutExtension.addSBasePluginCreator(&sprPluginCreator);
  layoutExtension.addSBasePluginCreator(&msprPluginCreator);

  //-------------------------------------------------------------------------
  //
  // 5. Registers the SBMLExtension derived object to SBMLExtensionRegistry
  //
  //-------------------------------------------------------------------------

  int result = SBMLExtensionRegistry::getInstance().addExtension(&layoutExtension);

  if (result != LIBSBML_OPERATION_SUCCESS)
  {
#if 0
    std::cerr << "[Error] LayoutExtension::init() failed." << std::endl;
#endif
  }
}
/** @endcond */


/*
* Removes the L2 Namespace from a document. 
*
* This method should be overridden by all extensions that want to serialize
* to an L2 annotation.
*/
void LayoutExtension::removeL2Namespaces(XMLNamespaces* xmlns)  const
{
    for (int n = 0; n < xmlns->getNumNamespaces(); n++)
    {
      if (xmlns->getURI(n) == LayoutExtension::getXmlnsL2())
      {
        xmlns->remove(n);
      }
    }
}

/*
 * adds the L2 Namespace 
 *
 * This method should be overridden by all extensions that want to serialize
 * to an L2 annotation.
 */
void LayoutExtension::addL2Namespaces(XMLNamespaces* xmlns)  const
{
  if (!xmlns->containsUri( LayoutExtension::getXmlnsL2()))
    xmlns->add(LayoutExtension::getXmlnsL2(), "layout");
}


/*
* Adds the L2 Namespace to the document and enables the extension.
*
* If the extension supports serialization to SBML L2 Annotations, this 
* method should be overrridden, so it will be activated.
*/
void LayoutExtension::enableL2NamespaceForDocument(SBMLDocument* doc)  const
{
  if (doc->getLevel() == 2)
  {
    doc->enablePackage(LayoutExtension::getXmlnsL2(),"layout", true);
  }

}

bool 
LayoutExtension::isInUse(SBMLDocument *doc) const
{
  if (doc == NULL || doc->getModel() == NULL) return false;
  LayoutModelPlugin* plugin = (LayoutModelPlugin*)doc->getModel()->getPlugin("layout");
  if (plugin == NULL) return false;

  return (plugin->getNumLayouts() > 0);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Return error table entry. 
 */
packageErrorTableEntry
LayoutExtension::getErrorTable(unsigned int index) const
{
	return layoutErrorTable[index];
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Return error table index for this id. 
 */
unsigned int
LayoutExtension::getErrorTableIndex(unsigned int errorId) const
{
	unsigned int tableSize = sizeof(layoutErrorTable)/sizeof(layoutErrorTable[0]);
	unsigned int index = 0;

	for(unsigned int i = 0; i < tableSize; i++)
	{
		if (errorId == layoutErrorTable[i].code)
		{
			index = i;
			break;
		}

	}

	return index;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Return error offset. 
 */
unsigned int
LayoutExtension::getErrorIdOffset() const
{
	return 6000000;
}
/** @endcond */



#endif  /* __cplusplus */
LIBSBML_CPP_NAMESPACE_END

