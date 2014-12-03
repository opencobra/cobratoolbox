/**
 * @file    SBMLExtension.h
 * @brief   Definition of SBMLExtension, the core component of SBML package extension.
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
 *
 * @class SBMLExtension
 * @sbmlbrief{core} Core class for SBML Level 3 package plug-ins.
 * 
 * @ifnot clike @internal @endif@~
 *
 * SBMLExtension class (abstract class) is a core component of package extension
 * which needs to be extended by package developers. 
 * The class provides functions for getting common attributes of package extension 
 * (e.g., package name, package version, and etc.), functions for adding (registering) 
 * each instantiated SBasePluginCreator object, and a static function (defined in each 
 * SBMLExtension extended class) for initializing/registering the package extension 
 * when the library of the package is loaded.
 *
 * @section howto How to implement an SBMLExtension extended class for each package extension
 *
 * Package developers must implement an SBMLExtension extended class for
 * their packages (e.g. GroupsExtension class is implemented for groups extension).
 * The extended class is implemented based on the following steps:
 *
 * (NOTE: 
 *   "src/packages/groups/extension/GroupsExtension.{h,cpp}" and
 *   "src/packages/layout/extension/LayoutExtension.{h,cpp}" are
 *   example files in which SBMLExtension derived classes are implemented)
 *
 * <ol>
 *
 * <li> Define the following static functions in the extended class:
 *      (examples of groups extension are shown respectively)
 *   <ol>
 *     <li> <p>A string of package name (label) (The function name must be "getPackageName".)</p>
 *         
@verbatim
  const std::string& GroupsExtension::getPackageName ()
  {
	static const std::string pkgName = "groups";
	return pkgName;
  }
@endverbatim
 *     </li>
 *
 *     <li> <p>
 *        Methods returning an integer of Default SBML level, version, and package version
 *        (The method names must be "getDefaultLevel()", "getDefaultVersion()", and 
 *        "getDefaultPackageVersion()" respectively.)
 *        </p>
@verbatim
  unsigned int GroupsExtension::getDefaultLevel()
  {
	return 3;
  }  
  unsigned int GroupsExtension::getDefaultVersion()
  {
	return 1; 
  }
  unsigned int GroupsExtension::getDefaultPackageVersion()
  {
	return 1;
  }  
@endverbatim
 *     </li>
 *     <li> <p> Methods returning Strings that represent the URI of packages </p>
@verbatim
  const std::string& GroupsExtension::getXmlnsL3V1V1 ()
  {
	static const std::string xmlns = "http://www.sbml.org/sbml/level3/version1/groups/version1";
	return xmlns;
  }
@endverbatim 
 *     </li>
 *     <li> <p>Strings that represent the other URI needed in this package (if any) </p>
 *     </li>
 *   </ol> 
 * </li>
 *
 * <li> Override the following pure virtual functions
      <ul>
       <li> <code>virtual const std::string& getName () const =0</code>. This function returns the name of the package (e.g., "layout", "groups"). </li>
       <li> <code>virtual unsigned int getLevel (const std::string &uri) const =0</code>. This function returns the SBML level with the given URI of this package. </li>
       <li> <code>virtual unsigned int getVersion (const std::string &uri) const =0</code>. This function returns the SBML version with the given URI of this package. </li>
       <li> <code>virtual unsigned int getPackageVersion (const std::string &uri) const =0</code>. This function returns the package version with the given URI of this package.</li>
       <li> <code>virtual unsigned int getURI (unsigned int sbmlLevel, unsigned int sbmlVersion, unsigned int pkgVersion) const =0</code>. 
             This function returns the URI (namespace) of the package corresponding to the combination of the given sbml level, sbml version, and pacakege version</li>
       <li> <code>virtual SBMLExtension* clone () const = 0</code>. This function creates and returns a deep copy of this derived object.</li>
      </ul>
      <p>For example, the above functions are overridden in the groups
	package ("src/packages/groups/extension/GroupsExtension.cpp") as follows:</p>
@verbatim
const std::string&
GroupsExtension::getName() const
{
  return getPackageName();
}

unsigned int 
GroupsExtension::getLevel(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
  {
    return 3;
  }
  
  return 0;
}

unsigned int 
GroupsExtension::getVersion(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
  {
    return 1;
  }

  return 0;
}

unsigned int
GroupsExtension::getPackageVersion(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
  {
    return 1;
  }

  return 0;
}

const std::string& 
GroupsExtension::getURI(unsigned int sbmlLevel, unsigned int sbmlVersion, unsigned int pkgVersion) const
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

  static std::string empty = "";

  return empty;
}

GroupsExtension* 
GroupsExtension::clone () const
{
  return new GroupsExtension(*this);  
}
@endverbatim
 *
 * Constructor, copy Constructor, and destructor also must be overridden
 * if additional data members are defined in the derived class.
 *
 * </li>
 *
 * <li> <p>
 *  Define typedef and template instantiation code for the package specific SBMLExtensionNamespaces template class
 *  </p>
 *
 *   <ol>
 *     <li> typedef for the package specific SBMLExtensionNamespaces template class
 *       <p> For example, the typedef for GroupsExtension (defined in the groups package) is implemented in GroupsExtension.h as follows:</p>
@verbatim
  // GroupsPkgNamespaces is derived from the SBMLNamespaces class and used when creating an object of 
  // SBase derived classes defined in groups package.
  typedef SBMLExtensionNamespaces<GroupsExtension> GroupsPkgNamespaces;
@endverbatim
 *     </li>
 *
 *     <li> template instantiation code for the above typedef definition in the implementation file (i.e., *.cpp file).
 *       <p> For example, the template instantiation code for GroupsExtension is implemented in GroupsExtension.cpp 
 *           as follows:
 *       </p>
 *
@verbatim
  // Instantiate SBMLExtensionNamespaces<GroupsExtension> (GroupsPkgNamespaces) for DLL.
  template class LIBSBML_EXTERN SBMLExtensionNamespaces<GroupsExtension>;
@endverbatim
 *
 *     </li>
 *  </ol>
 *
 *  <p> The SBMLExtensionNamespaces template class is a derived class of
 *      SBMLNamespaces and can be used as an argument of constructors 
 *      of SBase derived classes defined in the package extensions.
 *      For example, a GroupsPkgNamespaces object can be used when creating a group 
 *      object as follows:
 *  </P>
@verbatim
   GroupPkgNamespaces gpns(3,1,1);  // The arguments are SBML Level, SBML Version, and Groups Package Version.

   Group g = new Group(&gpns);      // Creates a group object of L3V1 Groups V1.
@endverbatim
 *
 *   <p>
 *     Also, the GroupsPkgNamespaces object can be used when creating an
 *     SBMLDocument object with the groups package as follows:
 *   </p>
 *
@verbatim
   GroupsPkgNamespaces gpns(3,1,1);
   SBMLDocument* doc;

   doc  = new SBMLDocument(&gnps); // Creates an SBMLDocument of L3V1 with Groups V1.
@endverbatim
 *
 * </li>
 *
 * <li> Override the following pure virtual function which returns the SBMLNamespaces derived object 
@verbatim
       virtual SBMLNamespaces* getSBMLExtensionNamespaces (const std::string &uri) const =0
@endverbatim
 *    <p> For example, the function is overridden in GroupsExtension
 class as follows:</p>
@verbatim
SBMLNamespaces*
GroupsExtension::getSBMLExtensionNamespaces(const std::string &uri) const
{
  GroupsPkgNamespaces* pkgns = NULL;
  if ( uri == getXmlnsL3V1V1())
  {
    pkgns = new GroupsPkgNamespaces(3,1,1);    
  }  
  return pkgns;
}
@endverbatim
   </li>
 *  
 *
 *  <li> Define an enum type for representing the typecode of elements (SBase extended classes) defined in the package extension
 *
 *   <p>  For example, SBMLGroupsTypeCode_t for groups package is
 *  defined in GroupsExtension.h as follows: </p>
@verbatim
      typedef enum
      {
         SBML_GROUPS_GROUP  = 200
       , SBML_GROUPS_MEMBER = 201
      } SBMLGroupsTypeCode_t;
@endverbatim    
 *
 *  <p> <em>SBML_GROUPS_GROUP</em> corresponds to the Group class (&lt;group&gt;)
 * and <em>SBML_GROUPS_MEMBER</em> corresponds to the Member (&lt;member&gt;) class, respectively.
 *
 *
 *  <p> Similarly, SBMLLayoutTypeCode_t 
 *   for layout package is defined in LayoutExtension.h as follows: </p>
 *
@verbatim  
      typedef enum
      {
         SBML_LAYOUT_BOUNDINGBOX           = 100
       , SBML_LAYOUT_COMPARTMENTGLYPH      = 101
       , SBML_LAYOUT_CUBICBEZIER           = 102
       , SBML_LAYOUT_CURVE                 = 103
       , SBML_LAYOUT_DIMENSIONS            = 104
       , SBML_LAYOUT_GRAPHICALOBJECT       = 105
       , SBML_LAYOUT_LAYOUT                = 106   
       , SBML_LAYOUT_LINESEGMENT           = 107   
       , SBML_LAYOUT_POINT                 = 108    
       , SBML_LAYOUT_REACTIONGLYPH         = 109    
       , SBML_LAYOUT_SPECIESGLYPH          = 110    
       , SBML_LAYOUT_SPECIESREFERENCEGLYPH = 111
       , SBML_LAYOUT_TEXTGLYPH             = 112
      } SBMLLayoutTypeCode_t;
@endverbatim
 *
 *  <p>
 *   These enum values are returned by corresponding getTypeCode() functions.
 *   (e.g. SBML_GROUPS_GROUP is returned in Group::getTypeCode())
 *  </p>
 *
 *  <p>
 *   The value of each typecode can be duplicated between those of different 
 *   packages (In the above SBMLLayoutTypeCode_t and SBMLGroupsTypeCode_t types, 
 *   unique values are assigned to enum values, but this is not mandatory.)
 *  </p>
 *
 *  <p>
 *   Thus, to distinguish the typecodes of different packages, not only the return
 *   value of getTypeCode() function but also that of getPackageName()
 *   function should be checked as follows:
 *  </p>
@verbatim
          void example (const SBase *sb)
          {
            const std::string pkgName = sb->getPackageName();
            if (pkgName == "core") {
              switch (sb->getTypeCode()) {
                case SBML_MODEL:
                   ....
                   break;
                case SBML_REACTION:
                   ....
              }
            } 
            else if (pkgName == "layout") {
              switch (sb->getTypeCode()) {
                case SBML_LAYOUT_LAYOUT:
                   ....
                   break;
                case SBML_LAYOUT_REACTIONGLYPH:
                   ....
              }
            } 
            else if (pkgName == "groups") {
              switch (sb->getTypeCode()) {
                case SBML_GROUPS_GROUP:
                   ....
                   break;
                case SBML_GROUPS_MEMBER:
                   ....
              }
            }
            ...
          } 
@endverbatim
 *
 *  </li>
 *  <li> Override the following pure virtual function which returns a string corresponding to the given typecode:
 *  
@verbatim  
       virtual const char* SBMLExtension::getStringFromTypeCode(int typeCode) const;
@endverbatim 
 *
 *   <p> For example, the function for groups extension is implemented as follows: </p>
@verbatim  
static
const char* SBML_GROUPS_TYPECODE_STRINGS[] =
{
    "Group"
  , "Member"
};

const char* 
GroupsExtension::getStringFromTypeCode(int typeCode) const
{
  int min = SBML_GROUPS_GROUP;
  int max = SBML_GROUPS_MEMBER;

  if ( typeCode < min || typeCode > max)
  {
    return "(Unknown SBML Groups Type)";  
  }

  return SBML_GROUPS_TYPECODE_STRINGS[typeCode - min];
}
@endverbatim 
 *
 *  </li>
 *
 * <li> Implements a "static void init()" function in the derived class
 *
 * <p> In the init() function, initialization code which creates an instance of 
 *     the derived class and registering code which registers the instance to 
 *     SBMLExtensionRegistry class are implemented.
 * </p>
 * 
 * For example, the init() function for groups package is implemented as follows: 
@verbatim
void 
GroupsExtension::init()
{
  //-------------------------------------------------------------------------
  //
  // 1. Checks if the groups package has already been registered.
  //
  //-------------------------------------------------------------------------

  if ( SBMLExtensionRegistry::getInstance().isRegistered(getPackageName()) )
  {
    // do nothing;
    return;
  }

  //-------------------------------------------------------------------------
  //
  // 2. Creates an SBMLExtension derived object.
  //
  //-------------------------------------------------------------------------

  GroupsExtension groupsExtension;

  //-------------------------------------------------------------------------------------
  //
  // 3. Creates SBasePluginCreatorBase derived objects required for this 
  //    extension. The derived classes can be instantiated by using the following 
  //     template class.
  //
  //    temaplate<class SBasePluginType> class SBasePluginCreator
  //
  //    The constructor of the creator class has two arguments:
  //
  //        (1) SBaseExtensionPoint : extension point to which the plugin object connected
  //        (2) std::vector<std::string> : a std::vector object that contains a list of URI
  //                                       (package versions) supported by the plugin object.
  //
  //    For example, two plugin objects (plugged in SBMLDocument and Model elements) are 
  //    required for the groups extension.
  //
  //    Since only 'required' attribute is used in SBMLDocument by the groups package, and
  //    the 'required' flag must always be 'false', the existing
  //    SBMLDocumentPluginNotRequired class can be used as-is for the plugin.
  //
  //    Since the lists of supported package versions (currently only L3V1-groups-V1 supported )
  //    are equal in the both plugin objects, the same vector object is given to each 
  //    constructor.
  //
  //---------------------------------------------------------------------------------------

  std::vector<std::string> packageURIs;
  packageURIs.push_back(getXmlnsL3V1V1());

  SBaseExtensionPoint sbmldocExtPoint("core",SBML_DOCUMENT);
  SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);

  SBasePluginCreator<SBMLDocumentPluginNotRequired, GroupsExtension> sbmldocPluginCreator(sbmldocExtPoint,packageURIs);
  SBasePluginCreator<GroupsModelPlugin,   GroupsExtension> modelPluginCreator(modelExtPoint,packageURIs);

  //--------------------------------------------------------------------------------------
  //
  // 3. Adds the above SBasePluginCreatorBase derived objects to the SBMLExtension derived object.
  //
  //--------------------------------------------------------------------------------------

  groupsExtension.addSBasePluginCreator(&sbmldocPluginCreator);
  groupsExtension.addSBasePluginCreator(&modelPluginCreator);

  //-------------------------------------------------------------------------
  //
  // 4. Registers the SBMLExtension derived object to SBMLExtensionRegistry
  //
  //-------------------------------------------------------------------------

  int result = SBMLExtensionRegistry::getInstance().addExtension(&groupsExtension);

  if (result != LIBSBML_OPERATION_SUCCESS)
  {
    std::cerr << "[Error] GroupsExtension::init() failed." << std::endl;
  }
}
@endverbatim
 *    </p> 
 * </li>
 *
 * <li> Instantiate a global SBMLExtensionRegister variable in appropriate 
 *      implementation file
 *       
 * <p> For example, the global variable for the groups extension is instantiated in GroupsExtension.cpp as follows: </p>
@verbatim
  static SBMLExtensionRegister<GroupsExtension> groupsExtensionRegister;
@endverbatim
 *    The init() function is invoked when the global variable is instantiated,
 *    by which initialization and registering the package extension are performed.
 * </li>
 *
 *
 * </ol>
 * 
 */

#ifndef SBMLExtension_h
#define SBMLExtension_h


#ifndef EXTENSION_CREATE_NS
#define EXTENSION_CREATE_NS(type,variable,sbmlns)\
  type* variable;\
  {\
      XMLNamespaces* xmlns = sbmlns->getNamespaces();\
      variable = dynamic_cast<type*>(sbmlns);\
      if (variable == NULL)\
      {\
       variable = new type(sbmlns->getLevel(), sbmlns->getVersion());\
       for (int i = 0; i < xmlns->getNumNamespaces(); i++)\
       {\
         if (!variable->getNamespaces()->hasURI(xmlns->getURI(i)))\
           variable->getNamespaces()->add(xmlns->getURI(i), xmlns->getPrefix(i));\
       }\
      }\
      else { variable = new type(*variable); }\
  }
#endif

#include <sbml/common/libsbml-config-common.h>

#include <sbml/extension/SBasePluginCreatorBase.h>
#include <sbml/extension/SBaseExtensionPoint.h>
#include <sbml/extension/ASTBasePlugin.h>

  /** @cond doxygenLibsbmlInternal */
#ifndef SWIG
typedef struct {
  const char * ref_l3v1;
} packageReferenceEntry;


typedef struct {
  unsigned int code;
  const char*  shortMessage;
  unsigned int category;
  unsigned int l3v1_severity;
  const char*  message;
  packageReferenceEntry reference;
} packageErrorTableEntry;

#endif
  /** @endcond */

#ifdef __cplusplus

#include <vector>

LIBSBML_CPP_NAMESPACE_BEGIN

//
//
// (NOTICE)
//
// How to register this object to SBMLExtensionRegistry.
//
//  - Package developers must create a derived class of SBMLExtension class
//    and implement a "static void init()" function in the derived class.
//  - In the init() function, developers implements initialization code
//    which creates an instance of the derived class and registers the
//    instance to SBMLExtensionRegistry class.
//  - The static init function() is automatically invoked by instantiating
//    a global SBMLExtensionRegister variable in appropriate implementation
//    file (e.g. LayoutExtension.cpp) as follows:
// 
//      SBMLExtensionRegister<SBMLExtensionSUBCLASS> object;
//
//   (!!! The global object MUST NOT be defined in a header file !!!)
//
//
class LIBSBML_EXTERN SBMLExtension
{
public:

/** @cond doxygenLibsbmlInternal */
  typedef std::vector<std::string>           SupportedPackageURIList;
  typedef std::vector<std::string>::iterator SupportedPackageURIListIter;
/** @endcond */

  //
  //  (NOTICE) 
  //
  //   Package developers MUST define the following static methods
  //   in the derived class:
  //
  //     (1) Method returning Strings that represent the URI of packages
  //          (e.g., LayoutExtension::getXmlnsL3V1(); )
  // 
  //     (2) A method returning a string of the package name (label) 
  //         The method name must be "getPackageName()".
  //          (e.g. LayoutExtension::getPackageName();)
  //
  //     (3) Methods returning integers of Default SBML level, version, and package version
  //         The method names must be "getDefaultLevel()", "getDefaultVersion()", and 
  //         "getDefaultPackageVersion()" respectively.
  //
  //          (e.g. LayoutExtension::getDefaultLevel(); 
  //                LayoutExtension::getDefaultVersion(); 
  //                LayoutExtension::getDefaultPackageVersion(); )

  //
  //  (NOTICE) 
  //
  //   Package developers MUST define the following typedef for the package specific
  //   SBMLExtensionNamespaces template class after the definition of the derived class 
  //   (for example, please see the bottom of LayoutExtension.h) .
  //
  //    (1) typedef for SBMLExtensionNamespaces<SBMLExtensionType>
  //        (e.g.,  typedef SBMLExtensionNamespaces<LayoutExtension> LayoutPkgNamespaces; )
  //      
  //   Package developers also must implement a template instantiation code for the above 
  //   typedef definition in the implementation file (i.e. *.cpp file).
  //   For example, the template instantiation code for LayoutExtension is implemented
  //   in LayoutExtension.cpp as follows:
  //
  //      template class LIBSBML_EXTERN SBMLExtensionNamespaces<LayoutExtension>;
  //

  //
  //  (NOTICE) 
  //
  //  Package developers MUST define an enum type for representing the typecode of
  //  elements defined in their package extensions.
  //  For example, the following enum type is defined by groups package in GroupExtension.h
  //
  //    typedef enum
  //    {
  //       SBML_GROUPS_GROUP  = 200
  //     , SBML_GROUPS_MEMBER = 201
  //    } SBMLGroupsTypeCode_t;
  //
  //  Package developers also MUST override the following pure virtual function which returns 
  //  a string corresponding to the given typecode:
  //
  //     virtual const char* SBMLExtension::getStringFromTypeCode(int typeCode) const;
  //


  /**
   * Constructor.
   */
  SBMLExtension ();


  /**
   * Copy constructor.
   */
  SBMLExtension(const SBMLExtension&);


  /**
   * Destroy this object.
   */
  virtual ~SBMLExtension ();


  /**
   * Assignment operator for SBMLExtension.
   */
  SBMLExtension& operator=(const SBMLExtension&);

#ifndef SWIG
  /**
   * 
   * Adds the given SBasePluginCreatorBase object to this package
   * extension.
   *
   * @param sbaseExt the SBasePluginCreatorBase object bound to 
   * some SBML element and creates a corresponding SBasePlugin object 
   * of this package extension.
   */
  int addSBasePluginCreator(const SBasePluginCreatorBase* sbaseExt);


  /**
   *
   * Returns an SBasePluginCreatorBase object of this package extension
   * bound to the given extension point.
   *
   * @param extPoint the SBaseExtensionPoint to which the returned 
   * SBasePluginCreatorBase object bound.
   *
   * @return an SBasePluginCreatorBase object of this package extension 
   * bound to the given extension point.
   */
  SBasePluginCreatorBase* getSBasePluginCreator(const SBaseExtensionPoint& extPoint);


  /**
   *
   * Returns an SBasePluginCreatorBase object of this package extension
   * bound to the given SBMLTyptCode_t.
   *
   * @param code the SBMLTypeCode_t to which the returned 
   * SBasePluginCreatorBase object bound.
   *
   * @return an SBasePluginCreatorBase of this package extension bound to the 
   * given SBMLTyptCode_t.
   */
  const SBasePluginCreatorBase* getSBasePluginCreator(const SBaseExtensionPoint& extPoint) const;


  /**
   * Returns an SBasePluginCreatorBase object of this package extension 
   * with the given index.
   *
   * @param i the index of the returned SBasePluginCreatorBase object for
   * this package extension.
   *
   * @return an SBasePluginCreatorBase object of this package extension 
   * with the given index.
   */
  SBasePluginCreatorBase* getSBasePluginCreator(unsigned int i);


  /**
   * Returns an SBasePluginCreatorBase of this package extension with the 
   * given index.
   *
   * @param i the index of the returned SBasePluginCreatorBase object of 
   * this package extension.
   *
   * @return an SBasePluginCreatorBase of this package extension with the
   * given index.
   */
  const SBasePluginCreatorBase*  getSBasePluginCreator(unsigned int i) const;


#ifndef LIBSBML_USE_LEGACY_MATH
  /**
   * Adds the given ASTBasePlugin object to this package
   * extension.
   *
   * @param astPlugin the ASTBasePlugin object 
   * of this package extension.
   */
  int setASTBasePlugin(const ASTBasePlugin* astPlugin);


  /**
   * Returns an ASTBasePlugin of this package extension.
   *
   * @return an ASTBasePlugin of this package extension.
   */
  const ASTBasePlugin* getASTBasePlugin() const;
  
  
  /**
   * Returns an ASTBasePlugin of this package extension.
   *
   * @return an ASTBasePlugin of this package extension.
   */
  ASTBasePlugin* getASTBasePlugin();



  /**
  * Predicate returning @c true if this package extension has
  * an ASTBasePlugin attribute set.
  *
  * @return @c true if the ASTBasePlugin of
  * this package extension is set, @c false otherwise.
  */
  bool isSetASTBasePlugin() const;


#endif /* LIBSBML_USE_LEGACY_MATH */

#endif // SWIG

  /**
   * Returns the number of SBasePlugin objects stored in this object.
   *
   * @return the number of SBasePlugin objects stored in this object.
   */
  int getNumOfSBasePlugins() const;

  /**
   * Returns the number of supported package Namespace (package versions) of this 
   * package extension.
   *
   * @return the number of supported package Namespace (package versions) of this 
   * package extension.
   */
  unsigned int getNumOfSupportedPackageURI() const;


  /**
   * Returns a flag indicating, whether the given URI (package version) is 
   * supported by this package extension.
   *
   * @return true if the given URI (package version) is supported by this 
   * package extension, otherwise false is returned.
   */
  bool isSupported(const std::string& uri) const;


  /**
   *
   * Returns the ith URI (the supported package version)
   *
   * @param i the index of the list of URI (the list of supporeted package versions)
   * @return the URI of supported package version with the given index.
   */
  const std::string& getSupportedPackageURI(unsigned int i) const;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function 
   *           in their derived class.
   *
   * Creates and returns a deep copy of this SBMLExtension object.
   *
   * @return a (deep) copy of this SBase object
   */
  virtual SBMLExtension* clone () const = 0;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function 
   *           in their derived class.
   *
   * Returns the name of this package (e.g. "layout", "multi").
   *
   * @return the name of package extension
   */
  virtual const std::string& getName() const = 0;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function 
   *           in their derived class.
   *
   * Returns the uri corresponding to the given SBML level, SBML version, and package version.
   *
   * @param sbmlLevel the level of SBML
   * @param sbmlVersion the version of SBML
   * @param pkgVersion the version of package
   *
   * @return a string of the package URI
   */
  virtual const std::string& getURI(unsigned int sbmlLevel, unsigned int sbmlVersion, 
                                    unsigned int pkgVersion) const = 0;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function 
   *           in their derived class.
   *
   * Returns the SBML level associated with the given URI of this package.
   *
   * @param uri the string of URI that represents a versions of the package
   * @return the SBML level associated with the given URI of this package.
   */
  virtual unsigned int getLevel(const std::string &uri) const = 0;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function 
   *           in their derived class.
   *
   * Returns the SBML version associated with the given URI of this package.
   *
   * @param uri the string of URI that represents a versions of the package
   * @return the SBML version associated with the given URI of this package.
   */
  virtual unsigned int getVersion(const std::string &uri) const = 0;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function 
   *           in their derived class.
   *
   * Returns the package version associated with the given URI of this package.
   *
   * @param uri the string of URI that represents a versions of this package
   * @return the package version associated with the given URI of this package.
   */
  virtual unsigned int getPackageVersion(const std::string &uri) const = 0;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function 
   *           in their derived class.
   *
   * This method takes a type code of this package and returns a string 
   * representing the code.
   */
  virtual const char* getStringFromTypeCode(int typeCode) const = 0;


  /**
   *  (NOTICE) Package developers MUST OVERRIDE this pure virtual function in 
   *           their derived class.
   *
   * Returns an SBMLExtensionNamespaces<class SBMLExtensionType> object 
   * (e.g. SBMLExtensionNamespaces<LayoutExtension> whose alias type is 
   * LayoutPkgNamespaces) corresponding to the given uri.
   * Null will be returned if the given uri is not defined in the corresponding 
   * package.
   *
   * @param uri the string of URI that represents one of versions of the package
   * @return an SBMLExtensionNamespaces<class SBMLExtensionType> object. NULL
   *         will be returned if the given uri is not defined in the corresponding 
   *         package. 
   */
  virtual SBMLNamespaces* getSBMLExtensionNamespaces(const std::string &uri) const = 0;


  /**
   * enable/disable this package.
   * Returned value is the result of this function.
   *
   * @param isEnabled the bool value: true (enabled) or false (disabled)
   *
   * @return true if this function call succeeded, otherwise false is returned.
   */
  bool setEnabled(bool isEnabled);  


  /**
   * Check if this package is enabled (true) or disabled (false).
   *
   * @return true if this package is enabled, otherwise false is returned.
   */
  bool isEnabled() const;


  /**
   * Removes the L2 Namespaces. 
   *
   * This method should be overridden by all extensions that want to serialize
   * to an L2 annotation.
   */
  virtual void removeL2Namespaces(XMLNamespaces* xmlns)  const;


  /**
   * Adds all L2 Extension namespaces to the namespace list. 
   * 
   * This method should be overridden by all extensions that want to serialize
   * to an L2 annotation.
   */
  virtual void addL2Namespaces(XMLNamespaces *xmlns) const;


  /**
   * Adds the L2 Namespace to the document and enables the extension.
   *
   * If the extension supports serialization to SBML L2 Annotations, this 
   * method should be overrridden, so it will be activated.
   */
  virtual void enableL2NamespaceForDocument(SBMLDocument* doc)  const;


  /** 
   * Indicates whether this extension is being used by the given SBMLDocument.
   *
   * The default implementation returns true. This means that when a document
   * had this extension enabled, it will not be possible to convert it to L2
   * as we cannot make sure that the extension can be converted.
   * 
   * @param doc the SBML document to test. 
   * 
   * @return a boolean indicating whether the extension is actually being used
   *         by the document. 
   */
  virtual bool isInUse(SBMLDocument *doc) const;


  /** @cond doxygenLibsbmlInternal */
  /*
   * functions for use with error logging
   */
  virtual unsigned int getErrorTableIndex(unsigned int errorId) const;

#ifndef SWIG
  virtual packageErrorTableEntry getErrorTable(unsigned int index) const;
#endif
  virtual unsigned int getErrorIdOffset() const;

  unsigned int getSeverity(unsigned int index, unsigned int pkgVersion) const;

  unsigned int getCategory(unsigned int index) const;

  std::string getMessage(unsigned int index, unsigned int pkgVersion, 
                         const std::string& details) const;

  std::string getShortMessage(unsigned int index) const;


  /** @endcond */

protected:
  /** @cond doxygenLibsbmlInternal */

  bool                                 mIsEnabled;
  SupportedPackageURIList              mSupportedPackageURI;
  std::vector<SBasePluginCreatorBase*> mSBasePluginCreators;

#ifndef LIBSBML_USE_LEGACY_MATH
  ASTBasePlugin*                       mASTBasePlugin;
#endif /* LIBSBML_USE_LEGACY_MATH */
  /** @endcond */


private:
  /** @cond doxygenLibsbmlInternal */

  friend class SBMLExtensionRegistry;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

  
#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a deep copy of the given SBMLExtension_t structure
 * 
 * @param ext the SBMLExtension_t structure to be copied
 * 
 * @return a (deep) copy of the given SBMLExtension_t structure.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBMLExtension_t*
SBMLExtension_clone(SBMLExtension_t* ext);

/**
 * Frees the given SBMLExtension_t structure
 * 
 * @param ext the SBMLExtension_t structure to be freed
 * 
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_free(SBMLExtension_t* ext);

/**
 * Adds the given SBasePluginCreatorBase_t structure to this package
 * extension.
 *
 * @param ext the SBMLExtension_t structure to be freed
 * @param sbaseExt the SBasePluginCreatorBase_t structure bound to 
 * some SBML element and creates a corresponding SBasePlugin_t structure 
 * of this package extension.
 * 
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_addSBasePluginCreator(SBMLExtension_t* ext, 
      SBasePluginCreatorBase_t *sbaseExt );

/**
 * Returns an SBasePluginCreatorBase_t structure of this package extension
 * bound to the given extension point.
 *
 * @param ext the SBMLExtension_t structure 
 * @param extPoint the SBaseExtensionPoint_t to which the returned 
 * SBasePluginCreatorBase_t structure bound.
 *
 * @return an SBasePluginCreatorBase_t structure of this package extension 
 * bound to the given extension point, or @c NULL for invalid extension of 
 * extension point.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBasePluginCreatorBase_t *
SBMLExtension_getSBasePluginCreator(SBMLExtension_t* ext, 
      SBaseExtensionPoint_t *extPoint );

/**
 * Returns an SBasePluginCreatorBase_t structure of this package extension 
 * with the given index.
 *
 * @param ext the SBMLExtension_t structure 
 * @param index the index of the returned SBasePluginCreatorBase_t structure for
 * this package extension.
 *
 * @return an SBasePluginCreatorBase_t structure of this package extension 
 * with the given index, or @c NULL for an invalid extension structure.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBasePluginCreatorBase_t *
SBMLExtension_getSBasePluginCreatorByIndex(SBMLExtension_t* ext, 
      unsigned int index);

/**
 * Returns the number of SBasePlugin_t structures stored in the structure.
 *
 * @param ext the SBMLExtension_t structure 
 *
 * @return the number of SBasePlugin_t structures stored in the structure, 
 * or LIBSBML_INVALID_OBJECT. 
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_getNumOfSBasePlugins(SBMLExtension_t* ext);

/**
 * Returns the number of supported package namespaces (package versions) 
 * for this package extension.
 *
 * @param ext the SBMLExtension_t structure 
 *
 * @return the number of supported package namespaces (package versions) 
 * for this package extension or LIBSBML_INVALID_OBJECT. 
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_getNumOfSupportedPackageURI(SBMLExtension_t* ext);

/**
 * Returns a flag indicating, whether the given URI (package version) is 
 * supported by this package extension.
 *
 * @param ext the SBMLExtension_t structure 
 * @param uri the package uri
 *
 * @return true (1) if the given URI (package version) is supported by this 
 * package extension, otherwise false (0) is returned.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_isSupported(SBMLExtension_t* ext, const char* uri);


/**
 * Returns the package URI (package version) for the given index.
 *
 * @param ext the SBMLExtension_t structure 
 * @param index the index of the supported package uri to return
 *
 * @return the package URI (package version) for the given index or NULL.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getSupportedPackageURI(SBMLExtension_t* ext, unsigned int index);


/**
 * Returns the name of the package extension. (e.g. "layout", "multi").
 *
 * @param ext the SBMLExtension_t structure 
 *
 * @return the name of the package extension. (e.g. "layout", "multi").
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getName(SBMLExtension_t* ext);

/**
 * Returns the uri corresponding to the given SBML level, SBML version, 
 * and package version for this extension.
 *
 * @param ext the SBMLExtension_t structure
 * @param sbmlLevel the level of SBML
 * @param sbmlVersion the version of SBML
 * @param pkgVersion the version of package
 *
 * @return a string of the package URI
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getURI(SBMLExtension_t* ext, unsigned int sbmlLevel, 
      unsigned int sbmlVersion, unsigned int pkgVersion);

/**
 * Returns the SBML level associated with the given URI of this package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents a versions of the package
 *
 * @return the SBML level associated with the given URI of this package.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
unsigned int
SBMLExtension_getLevel(SBMLExtension_t* ext, const char* uri);

/**
 * Returns the SBML version associated with the given URI of this package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents a versions of the package
 *
 * @return the SBML version associated with the given URI of this package.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
unsigned int
SBMLExtension_getVersion(SBMLExtension_t* ext, const char* uri);

/**
 * Returns the package version associated with the given URI of this package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents a versions of the package
 *
 * @return the package version associated with the given URI of this package.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
unsigned int
SBMLExtension_getPackageVersion(SBMLExtension_t* ext, const char* uri);

/**
 * This method takes a type code of this package and returns a string 
 * representing the code.
 * 
 * @param ext the SBMLExtension_t structure
 * @param typeCode the typeCode supported by the package
 * 
 * @return the string representing the given typecode, or @c NULL in case an 
 * invalid extension was provided. 
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getStringFromTypeCode(SBMLExtension_t* ext, int typeCode);

/**
 * Returns an SBMLNamespaces_t structure corresponding to the given uri.
 * NULL will be returned if the given uri is not defined in the corresponding 
 * package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents one of versions of the package
 * 
 * @return an SBMLNamespaces_t structure corresponding to the uri. NULL
 *         will be returned if the given uri is not defined in the corresponding 
 *         package or an invalid extension structure was provided. 
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBMLNamespaces_t*
SBMLExtension_getSBMLExtensionNamespaces(SBMLExtension_t* ext, const char* uri);

/**
 * Enable/disable this package. 
 *
 * @param ext the SBMLExtension_t structure
 * @param isEnabled the value to set : true (1) (enabled) or false (0) (disabled)
 *
 * @return true (1) if this function call succeeded, otherwise false (0)is returned.
 * If the extension is invalid, LIBSBML_INVALID_OBJECT will be returned. 
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_setEnabled(SBMLExtension_t* ext, int isEnabled);

/**
 * Check if this package is enabled (true/1) or disabled (false/0).
 *
 * @param ext the SBMLExtension_t structure
 *
 * @return true if the package is enabled, otherwise false is returned.
 * If the extension is invalid, LIBSBML_INVALID_OBJECT will be returned. 
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_isEnabled(SBMLExtension_t* ext);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLExtension_h */

