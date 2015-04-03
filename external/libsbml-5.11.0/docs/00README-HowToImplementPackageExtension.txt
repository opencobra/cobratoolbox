================================================================================
Summary of how to implement a package extension (2010-01-16)
================================================================================

This documentation describes the summary of how to implement a package
extension for libSBML-5.
Please see 00README-ExtensionSupportClasses.txt for the summary of 
extension supported classes.

 (Note that since libSBML-5 is currently in development stage
 the API described in this documentation may be changed in the future.)

--------------------------------------------------------------
Table of contents:

  1. Implement an SBMLExtension derived class
  2. Implement SBase derived classes of the package extension 
  3. Implement one or more SBasePlugin derived classes 
  4. Implement a forward declaration file 
  5. Implement a header file which includes all SBML types 
     defined in the extension
  6. Defines a macro value of the package extension 
  7. How to import a source tree of a package extension into 
     the source tree of libSBML-5
--------------------------------------------------------------

--------------------------------------------------------------------------------          
1. Implement an SBMLExtension derived class
--------------------------------------------------------------------------------

  Firstly, an SBMLExtension derived class for your package needs to be implemented 
  based on the following steps.

  ----------------------------------------------------------------------
  (NOTE) 

    "src/pacakges/groups/extension/GroupsExtension.{h,cpp}" and
    "src/pacakges/layout/extension/LayoutExtension.{h,cpp}" are
    example files in which SBMLExtension derived classes are implemented.
  ----------------------------------------------------------------------

   --------------------------------------------------------------------------------
   1-1) Define the following static functions in the extended class
   --------------------------------------------------------------------------------
     
      1] A string of package name (label) 

        const std::string& GroupsExtension::getPackageName ()
        {
            static const std::string pkgName = "groups";
            return pkgName;
        }

         --------------------------------------------------
         (NOTE) The function name must be "getPackageName"
         --------------------------------------------------
   
      2] Methods returning an integer of Default SBML level, version, 
	     and package version ()

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

         --------------------------------------------------
         (NOTE) The method names must be "getDefaultLevel()", 
		        "getDefaultVersion()", and "getDefaultPackageVersion()" 
		        respectively.
         --------------------------------------------------

      3] Methods returning Strings that represent the URI of packages

	     const std::string& GroupsExtension::getXmlnsL3V1V1 ()
         {
	       static const std::string xmlns = 
		       "http://www.sbml.org/sbml/level3/version1/groups/version1";
	       return xmlns;
         }
	     ...
         ...
  
      4] Other URI needed in this package (if any)


   --------------------------------------------------------------------------------
   1-2) Define a typedef of the SBMLNamespaces derived template class of the package
        extension and then instantiates the template.
   --------------------------------------------------------------------------------

      For example, GroupsPkgNamespaces is defined by using the template 
      class in GroupsExtension.h and instantiated in GroupsExtension.cpp 
      as follows:


       (GroupsExtension.h)

          typedef SBMLExtensionNamespaces<GroupsExtension> GroupsPkgNamespaces;

       (GroupsExtension.cpp)

          template class LIBSBML_EXTERN SBMLExtensionNamespaces<GroupsExtension>;


      Similarly, LayoutPkgNamespaces is defined and instantiated as follows:


        (LayoutExtension.h)

          typedef SBMLExtensionNamespaces<LayoutExtension> LayoutPkgNamespaces;

        (LayoutExtension.cpp)

          template class LIBSBML_EXTERN SBMLExtensionNamespaces<LayoutExtension>;


      The SBMLNamespaces derived class can be used as an argument of constructors 
      of SBase derived classes defined in the package extensions.
      For example, a GroupsPkgNamespaces object can be used when creating a group 
      object as follows:


          GroupPkgNamespaces gpns(3,1,1);  // The arguments are SBML Level, 
                                           // SBML Version, and Groups Package Version.

          Group *g = new Group(&gpns);     // Creates a group object of L3V1 Groups V1.

      
       Also, the GroupsPkgNamespaces object can be used when creating an
       SBMLDocument object with the groups package as follows:


           GroupsPkgNamespaces gpns(3,1,1);
           SBMLDocument* doc;

           doc  = new SBMLDocument(&gnps); // Creates an SBMLDocument of L3V1 with 
                                           // Groups V1

   --------------------------------------------------------------------------------
   1-3) Define an enum type for each SBase derived classes defined in the package 
        extension
   --------------------------------------------------------------------------------

      (How to implement SBase derived classes of the package extension
        is described later)

      For example, SBMLLayoutTypeCode_t for the layout extension, SBMLGroupTypeCode_t 
      for group extension are defined in LayoutExtension.h and GroupsExtension.h 
      as follows:
      
        (LayoutExtension.h)

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


        (GroupsExtension.h)

           typedef enum
           {
              SBML_GROUPS_GROUP  = 200
            , SBML_GROUPS_MEMBER = 201
           } SBMLGroupsTypeCode_t;

      
      These enum values are returned by corresponding getTypeCode() functions.
      (e.g. SBML_GROUPS_GROUP is returned in Group::getTypeCode())

      The value of each typecode can be duplicated between those of different 
      packages.
      (In the above SBMLayoutTypeCode_t and SBMLGroupsTypeCode_t types, unique 
       values are assigned to enum values, but this is not mandatory.)

      Thus, to distinguish the typecodes of different packages, not only the return
      value of getTypeCode() but also that of getPackageName() must be checked 
      as follows:


          void example (const SBase *sb)
          {
            cons std::string pkgName = sb->getPackageName();
            if (pkgName == "core")
            {
              switch (sb->getTypeCode())
              {
                case SBML_MODEL:
                   ....
                   break;
                case SBML_REACTION:
                   ....
              }
            } 
            else if (pkgName == "layout")
            {
              switch (sb->getTypeCode())
              {
                case SBML_LAYOUT_LAYOUT:
                   ....
                   break;
                case SBML_LAYOUT_REACTIONGLYPH:
                   ....
              }
            } 
            ...
          } 


   --------------------------------------------------------------------------------
   1-4) Define a list of typecode strings, which is used in getStringFromTypeCode() 
        function
   --------------------------------------------------------------------------------

      For example, a list of typecode strings for groups extension
      is defined as follows (in GroupsExtension.cpp):

           static
           const char* SBML_GROUPS_TYPECODE_STRINGS[] =
           {
               "Group"
             , "Member"
           };


   --------------------------------------------------------------------------------
   1-5) Override the following virtual functions 
   --------------------------------------------------------------------------------
   
      - clone() 

      - getName() const 

      - getURI(unsigned int sbmlLevel, unsigned int sbmlVersion, 
               unsigned int pkgVersion) const 

      - unsigned int getLevel(const std::string &uri) 

      - unsigned int getPackageVersion(const std::string &uri)

      - getSBMLExtensionNamespaces(const std::string&)

      - getStringFromTypeCode(int typecode) const

     ----------------------------------------------------------------------
      (NOTE) Constructor, Copy Constructor, destructor must be overridden
             if additional data members are defined.
      ----------------------------------------------------------------------
 
   --------------------------------------------------------------------------------
   1-6) Define a static init() function
   --------------------------------------------------------------------------------

      init() is a function that creates an instance of the SBMLExtension
      derived class and registers the object to the SBMLExtensionRegistry
      class.
      init() function is automatically invoked before main() routine.

      For example, the static init() function of GroupsExtension is implemented
      in GroupsExtension.cpp as follows:


           void 
           GroupsExtension::init()
           {
             //----------------------------------------------------------------------
             //
             // 1. Check if the groups package has already been registered.
             //
             //----------------------------------------------------------------------
           
             if (SBMLExtensionRegistry::getInstance().isRegistered(getPackageName()))
             {
               // do nothing;
               return;
             }
           
             //----------------------------------------------------------------------
             //
             // 2. Create an SBMLExtension derived object.
             //
             //----------------------------------------------------------------------
           
             GroupsExtension groupsExtension;
           
             //----------------------------------------------------------------------
             //
             // 3. Create SBasePluginCreatorBase derived objects required for this 
             //    extension. The derived classes can be instantiated by using the 
             //    following template class.
             //
             //    template<class SBasePluginType> class SBasePluginCreator
             //
             //    The constructor of the creator class has two arguments:
             //
             //        (1) SBaseExtensionPoint
             //            extension point to which the plugin object connected
             //                                  
             //        (2) std::vector<std::string> 
             //            a std::vector object that contains a list of URI 
             //            (package versions) supported by the plugin object.
             //                                       
             //    For example, two plugin objects (plugged in SBMLDocument and Model 
             //    elements) are required for the groups extension.
             //
             //    Since only 'required' attribute is used in SBMLDocument by the groups 
             //    package, existing SBMLDocumentPlugin class can be used as-is for the 
             //    plugin.
             //
             //    Since the lists of supported package versions (currently only 
             //    L3V1-groups-V1 supported ) are equal in the both plugin objects, 
             //    the same vector object is given to each constructor.
             //--------------------------------------------------------------------------
           
             std::vector<std::string> packageURIs;
             packageURIs.push_back(getXmlnsL3V1V1());
           
             SBaseExtensionPoint sbmldocExtPoint("core",SBML_DOCUMENT);
             SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);
           
             SBasePluginCreator<SBMLDocumentPlugin, GroupsExtension> \
                    sbmldocPluginCreator(sbmldocExtPoint,packageURIs);

             SBasePluginCreator<GroupsModelPlugin, GroupsExtension> \
                     modelPluginCreator(modelExtPoint,packageURIs);
           
             //-------------------------------------------------------------------------------
             //
             // 3. Add the above SBasePluginCreatorBase derived objects to the SBMLExtension 
             // derived object.
             //
             //-------------------------------------------------------------------------------
           
             groupsExtension.addSBasePluginCreator(&sbmldocPluginCreator);
             groupsExtension.addSBasePluginCreator(&modelPluginCreator);
           
             //-------------------------------------------------------------------------
             //
             // 4. Register the SBMLExtension derived object to SBMLExtensionRegistry
             //
             //-------------------------------------------------------------------------
           
             int result = SBMLExtensionRegistry::getInstance().addExtension(&groupsExtension);
           
             if (result != LIBSBML_OPERATION_SUCCESS)
             {
               std::cerr << "[Error] GroupsExtension::init() failed." << std::endl;
             }



   --------------------------------------------------------------------------------
    1-7) Define a static global object (an instance of SBMLExtensionRegister template
         class) 
   --------------------------------------------------------------------------------

       Add an SBMLExtension derived object to the SBMLExtensionRegistry class
       by defining an instance of SBMLExtensionRegister template class as follows:
       (The example below in implemnted in GroupsExtension.cpp)


         static SBMLExtensionRegister<GroupsExtension> groupsExtensionRegistry;


       The above init() function is automatically invoked when this object is 
       instantiated before main() routine called.


--------------------------------------------------------------------------------
2. Implement SBase derived classes of the package extension
--------------------------------------------------------------------------------

Secondly, SBase derived classes for your package need to be implemented
based on the following steps:

   --------------------------------------------------------------------------------  
   2-1) Identify elements defined in the package extension
   --------------------------------------------------------------------------------

   For example, the following elements are defined in the groups package:

     1) Group
     2) Member
     3) ListOfMembers

   --------------------------------------------------------------------------------
   2-2) Identify which subelements and/or attributes are defined in each element
   --------------------------------------------------------------------------------

   For example, the following subelements and attributes are defined in 
   the Group element in the groups package.

     [subelements]

       1. ListOfMembers  mMembers  ('listOfMembers' element)

     [attributes]

       1. std::string         mId  ('id'   attribute)
       2. std::string       mName  ('name' attribute)


   --------------------------------------------------------------------------------
   2-3) Implement each SBase derived class
   --------------------------------------------------------------------------------

     ----------------------------------------------------------------------------
     2-3-1) Define protected data members that store identified subelements 
            and/or attributes 
     ----------------------------------------------------------------------------

       For example, the following protected data members are defined in
       Group class ('src/packages/groups/sbml/Group.h'):


               class LIBSBML_EXTERN Group : public SBase
               {
               protected:
                 std::string   mId;
                 std::string   mName;
                 ListOfMembers mMembers;

                 ....
                                  
               };    

         Basically, the attribute data will have one of the types "std::string", 
         "double", "int", or "bool", and the type of the element data will be 
         ListOf derived classes or SBase derived classes.
 
         The data members must be properly initialized in the constructor, and must 
         be properly copied in the copy constructor and assignment operator.

     ----------------------------------------------------------------------------
     2-3-2) Define the following two constructors
     ----------------------------------------------------------------------------
 
          ----------------------------------------------------------------------
          1) a constructor that accepts three arguments: 
             (1) SBML Level, (2) SBML Version, and (3) Package Version
          ----------------------------------------------------------------------

           For example, this type of constructor of Group class is implemented 
           in 'src/packages/groups/sbml/Group.cpp' as follows:


               Group::Group (unsigned int level, unsigned int version, 
                             unsigned int pkgVersion)
                 : SBase (level,version)   // <-- invokes parent's constructor
                  ,mId("")
                  ,mName("")
                  ,mMembers(level,version,pkgVersion)
               {
                 // set an SBMLNamespaces derived object (GroupsPkgNamespaces) of 
                 //this package.
                 setSBMLNamespacesAndOwn(new GroupsPkgNamespaces(level,version,
                                                                 pkgVersion));
                  
                 // connects child elements to this element.
                 connectToChild(); 
               }


           ----------------------------------------------------------------------  
           (NOTE) 

             - default level, default version, and default pacakge version
               should be given as default arguments.
               (This may change in the future release).

             - the corresponding constructor of the parent class must be properly 
               invoked by using initializer of the constructor.
         
             - setSBMLNamespacesAndOwn() function must be invoked with a newly
	           created SBMLNamespaces derived object with the given level, version,
               and package version.

             - connectToChild() function must be invoked if the element has one
               or more child elements.
           ----------------------------------------------------------------------  

           For example, an instance of the SBase derived object is created by this
           constructor as follows:

   
               Layout layout(3,1,1);


          -----------------------------------------------------------------------
          2) a constructor that accepts an SBMLNamespaces derived object
          -----------------------------------------------------------------------
           For example, this type of constructor of Group class is implemented 
           in 'src/packages/groups/sbml/Group.cpp' as follows:
           (GroupsPkgNamespaces is the type of SBMLNamespaces derived class for
            groups package)


               Group::Group(GroupsPkgNamespaces* groupsns)
                : SBase(groupsns)
                 ,mId("")
                 ,mName("")
                 ,mMembers(groupsns)
               {
                 // set the element namespace of this object
                 setElementNamespace(groupsns->getURI());

                 // connect child elements to this element
                 connectToChild();

                 // load pacakge extensions bound with this object (if any)
                 loadPlugins(groupsns);
               }

           ----------------------------------------------------------------------  
           (NOTE) 

             - SBMLNamespaces and its derived class throws an SBMLExtensionException
               if the given combination is invalid (undefined).

             - the corresponding constructor of the parent class must be properly 
               invoked by initializer.
         
             - setElementNamespace() function must be invoked with the URI
               of the package in the constructor.

             - connectToChild() function must be invoked if the element has one
               or more child elements.

             - loadPlugins() function should be invoked if the element can be
               extended by other package extensions.
           ----------------------------------------------------------------------  

           For example, an instance of the SBase derived object is created by 
           this constructor as follows:
	
   
               try
               {
                 LayputPkgNamespaces layoutns(3,1,1);
                 Layout              layout(&layoutns); 
               }
               catch (SBMLExtensionException e)
               {
                 cerr << "Caught " << e.what() << endl;
               }


       ===========================================================================
       (NOTE) 
 
       In the layout extension, additional constructors that accept one or more 
       attributes of the element have been implemented for backward compatibility
       (support for L2 model).
       (validation check of the given arguments of attributes are not performed.)
       ===========================================================================

    ----------------------------------------------------------------------------
    2-3-3) Override the following functions in the SBase class 
    ----------------------------------------------------------------------------

          - Copy Constructor

          - Assignment operator (operator=)

          - clone() function
            (basically implemented by using the copy constructor)


    ----------------------------------------------------------------------------
    2-3-4) Override the following virtual functions if one or more attributes 
           (except for those defined in its ancestors) are defined in this 
           element
    ----------------------------------------------------------------------------       

          - addExpectedAttributes()

          - readAttributes()

          - hasRequiredAttributes()

          ----------------------------------------------------------------------
          (NOTE) 

            - corresponding function of the parent class must be invoked
	          in  addExpectedAttributes() and readAttributes() functions
              as follows:


                Group::addExpectedAttributes(ExpectedAttributes& attributes)
                {
                   SBase::addExpectedAttributes(attributes);
                   ....
                }


               void
               Group::readAttributes (const XMLAttributes& attributes,
                                      const ExpectedAttributes& expectedAttributes)
               {
                 SBase::readAttributes(attributes,expectedAttributes);
                  ...
               }
         
                (SBase class is a parent of Group class.)


            - the following attributes don't need to be added in 
              the addExpectedAttributes() function because they are added
              in SBase::addExpectedAttributes() function.

                1) metaid  (L2V1 or later)
                2) sboTerm (L2V3 or later)


            - "src/packages/groups/sbml/{Group,Member}.{h,cpp}" are simple example
               files in which these functions are implemented.
          ----------------------------------------------------------------------


    ----------------------------------------------------------------------------
    2-3-5] Override the following virtual functions if one or more subelements 
           are defined in this element
    ----------------------------------------------------------------------------       

          - createObject()

          - writeElements()

          - hasRequiredElements()

          - setSBMLDocument()

          - enablePackageInternal()
	   
          - connectToChild()

          ----------------------------------------------------------------------
          (NOTE) 

            - corresponding function of the parent class must be invoked
	          in writeElements(), setSBMLDocument(), and enablePackageInternal()
              functions

            - 'src/packages/groups/sbml/{Group,Member}.{h,cpp} are simple example
               files in which these functions are implemented.
          ----------------------------------------------------------------------


    ----------------------------------------------------------------------------
    2-3-6] Override the following virtual functions if the element is a top-level 
           element of the package
    ----------------------------------------------------------------------------           

            - writeXMLNS()
      
          ----------------------------------------------------------------------
	  (NOTE) 

            - For example, this function is implemented in the following top-level
              elements:

                 1) SBMLDocument   (SBML Core)
                 2) ListOfLayouts  (Layout extension)
                 3) ListOfGroups   (Groups extension)


            - In package extensions, writeXMLNS() function writes an xmlns="..."
              attribute if the top-level element of the package extension 
              belongs to default XML namespace.
              This behaviour can be enabled/disabled by the following function:

                SBMLDocument::enableDefaultNS(const std::string& package, bool flag)
          ----------------------------------------------------------------------


      ----------------------------------------------------------------------------           
      2-3-7] Override the following virtual functions if 'id' attribute is defined 
             in the element
      ---------------------------------------------------------------------------- 

           1) setId()

           2) getId()

           3) isSetId()

           4) unsetId()

          ----------------------------------------------------------------------
	  (NOTE) 

            - Basically, implementation of these functions are almost the same
              between elements defining the 'id' attribute

            - setId() function can be easily implemented as follows (one line):

                 return SyntaxChecker::checkAndSetSId(id,mId);
          ----------------------------------------------------------------------

      ---------------------------------------------------------------------------- 
      2-3-8] Override the following virtual functions if 'name' attribute is defined 
             in the element
      ---------------------------------------------------------------------------- 

           1) setName()

           2) getName()

           3) isSetName()

           4) unsetName()

          ----------------------------------------------------------------------
	  (NOTE) 

            - Basically, implementation of these functions are almost the same
              between elements defining the 'id' attribute
          ----------------------------------------------------------------------


      ---------------------------------------------------------------------------- 
      2-3-9]  Add function calls of loadPlugins() in the constructor which accepts 
              an SBMLNamespaces derived class for supporting package extensions.
      ---------------------------------------------------------------------------- 

            (loadPlugins() doesn't need to be invoked in an abstract class.) 

      ---------------------------------------------------------------------------- 
      2-3-10]  Add function calls of connectToChild() in constructor, 
               copy constructor, and assignment operator.
      ---------------------------------------------------------------------------- 

      ---------------------------------------------------------------------------- 
      2-3-11] Implement additional (package developer-defined) functions for
              manipulating the attributes and/or subelements
      ---------------------------------------------------------------------------- 

        For example, getMember(), addMember(), getNumMembers(), createMember(),
        removeMember() and etc. are implemented in Group class of the groups package.

          ----------------------------------------------------------------------
	  (NOTE) 

           - when implementing setXXXX(const XXXX&) / addXXXX(const XXXX&) 
             functions that set/add the given SBase derived object, the following
             check should be done for the given object:

	           1) check if the given object is not NULL

               2) check if the SBML Level, Version, and Package Version 
                  of the given object matches those of target element

               3) check if an object with the id of the given object
                  already exists (i.e. checks an error of duplicated object id


           - one of status codes, which is defined in 

                "src/common/operationReturnValues.h"

             should be returned based on the result of functions except for
	         getter functions and functions returning a bool value


           -  In setXXXX(const XXXX&) function,  connectToParent() function 
              must be invoked if the given object is valid.

               (for detail, please check existing implementation such as
                setKineticLaw() function in  "src/sbml/Reaction.cpp")

          ----------------------------------------------------------------------

--------------------------------------------------------------------------------
3. Implement one or more SBasePlugin derived classes 
--------------------------------------------------------------------------------

Thirdly, SBasePlugin derived classes for the pacakge needs to be implemented.

   ------------------------------------------------------------------------------
   3-1) Identify which core SBML elements (e.g. Model, Reaction,..) to be extended 
        (i.e. adding attributes and/or elements) for your package extensions.
   ------------------------------------------------------------------------------

    For example, the following SBML elementes are extended by groups and layout
    packages, respectively:


      1) groups package

          1. SBMLDocument
              - Add 'required' attribute

          2. Model
              - Add 'listOfGroups' element 


      2) layout package

          1. SBMLDocument
              - Add 'required' attribute

          2. Model
              - Add 'listOfLayouts' element 

          3. SpeciesReferences (only for L2V1 for backward compatibility)
              - Add 'id' attribute
     
   ------------------------------------------------------------------------------
   3-2) Implement SBasePlugin derived objects for each identified 
        core SBML element based on the following policy:
   ------------------------------------------------------------------------------

       For example, to extend the identified classes, the following SBasePlugin 
       derived classes are newly implemnted in the groups and layout packages:

          1) groups

              - LayoutModelPlugin 
              - LayoutSpeciesReferencesPlugin

          2) groups

              - GroupsModelPlugin

         ----------------------------------------------------------------------
         (NOTE) Package developers can use existing SBMLDocumentPlugin class
                as-is for extending the SBMLDocument class if only 'required' 
                attribute is added the class in their packages, otherwise package 
                developers must implement a new SBMLDocumentPlugin derived class 
                for extending the SBMLDocument class.

                Since the both of groups and layout packages require only 
                'required' attribute for extending the SBMLDocument class, 
                the SBMLDocumentPlugin is used as-is for the packages.
         ----------------------------------------------------------------------


      ----------------------------------------------------------------------------
      3-2-1] Define additional protected data members that store additional 
             elements and/or attributes if one ore more elemnets and/or attributes 
             are added to the target core element.
      -----------------------------------------------------------------------------
         
         Basically, the attribute data will have one of the types "std::string", 
         "double", "int", or "bool", and the type of the element data will be 
         ListOf derived classes or SBase derived classes.
 
         The additional data members must be properly initialized in the constructor,
         and must be properly copied in the copy constructor and assignment operator.

         For example, the following data member is defined in the GroupsModelPlugin 
         class (in GroupsModelPlugin.h):

             ListOfGroups mGroups;

      -----------------------------------------------------------------------------
      3-2-2] Override the following functions in the SBasePlugin class
      -----------------------------------------------------------------------------

            - Constructor 
              ( SBasePlugin(const std::string& uri, const std::string &prefix) )

            - Copy Constructor

            - Assignment operator (operator=)

            - clone() (virtual) function 
              (basically implemented by using the copy constructor)


          ----------------------------------------------------------------------
          (NOTE) 'src/extension/SBMLDocumentPlugin.{h,cpp} is a simple example
                  files in which these functions are implemented.
          ----------------------------------------------------------------------

      -----------------------------------------------------------------------------
      3-2-3] Override the following virtual functions if one or more attributes 
             are added to the target core element
      -----------------------------------------------------------------------------

          - addExpectedAttributes()

          - readAttributes()

          - hasRequiredAttributes()

      -----------------------------------------------------------------------------
      3-2-4] Override the following virtual functions if one or more top-level 
             elements are added to the target core element
      -----------------------------------------------------------------------------

          - createObject()

          - writeElements()

          - hasRequiredElements()

          - setSBMLDocument()
 
          - connectToParent()

          - enablePackageInternal()

          ----------------------------------------------------------------------
          (NOTE) 'src/packages/groups/extension/GroupsModelPlugin.{h,cpp}' and
                 'src/packages/layout/extension/LayoutModelPlugin.{h,cpp}'
                  are example files in which the functions are implemented.
          ----------------------------------------------------------------------

      -----------------------------------------------------------------------------
      3-2-5] The following virtual functions must be overridden if one or more 
             additional xmlns attributes need to be added to the target element
      -----------------------------------------------------------------------------

          - writeXMLNS()
      
          ----------------------------------------------------------------------
	  (NOTE) Currently, no example files implementing this function
          ----------------------------------------------------------------------

      -----------------------------------------------------------------------------
       3-2-6] Implement additional (package developer-defined) functions for
              manipulating the additional attributes and/or top-level elements
      -----------------------------------------------------------------------------
          
          For example, the following manipulation functions are implemented in 
          LayoutModelPlugin class (a class for the extension of the model element 
          in layout package) for manipulating the additional <listOfLayouts> element
          in the list element:


              1) const ListOfLayouts* getListOfLayouts() const
              2) ListOfLayouts*       getListOfLayouts()
              3) Layout*              getLayout(unsigned int index)
              4) Layout*              getLayout(const std::string &sid)
              5) int                  addLayout(const Layout* layout)
              6) Layout*              createLayout()
              7) Layout*              removeLayout(unsigned int n)
              8) int                  getNumLayouts() const


          Similarly, the following manipulation functions are implemented in 
          GroupsModelPlugin class (a class for the extension of the model element 
          in groups package) for manipulating the additional <listOfGroups> element
          in the list element:


              1) const ListOfGroups* getListOfGroups() const
              2) ListOfGroups*       getListOfGroups()
              3) Group*              getGroup(unsigned int index)
              4) Group*              getGroup(const std::string &sid)
              5) int                 addGroup(const Group* group)
              6) Group*              createGroup()
              7) Group*              removeGroup(unsigned int n)
              8) int                 getNumGroups() const
            

--------------------------------------------------------------------------------
4. Implement a forward declaration file
--------------------------------------------------------------------------------

A header file in which forward declarations for all classes defined in the
package extension should be implemented.

For example, please see "src/common/sbmlfwd.h" (forward declaration of SBML Core),  
"src/packages/groups/common/groupsfwd.h" (forward declaration of Groups package), 
and "src/packages/layout/common/layoutfwd.h" (forward declaration of Layout package)

--------------------------------------------------------------------------------
5. Implement a header file which includes all SBML types defined in the extension
--------------------------------------------------------------------------------

A header file in which all SBML types defined in the extension should be implemented.
For example, please see "src/packages/groups/common/GroupsExtensionTypes.h" of the
groups extension and "src/packages/layout/common/LayoutExtensionTypes.h" of the
layout extension.

--------------------------------------------------------------------------------------
6. Defines a macro vaule of the package extension 
--------------------------------------------------------------------------------------

   (NOTE) A new package extension can be implemented and built outside the 
          source tree of libSBML. So, this step is not mandatory if you don't
          want to import your package extension into the source tree of libSBML.


USE_%%PACKAGE_NAME%% macro variable needs to be defined in the following files:
     
    1]  "src/common/libsbml-config-unix.h.in"
    2]  "src/common/libsbml-config-win.h"

       (%%PACKAGE_NAME%% is a place holder of the package name.
        For example, USE_LAYOUT is defined for the layout package.)

--------------------------------------------------------------------------------     
7. How to import a source tree of a package extension into the source 
   tree of libSBML-5
--------------------------------------------------------------------------------     

   (NOTE) A new package extension can be implemented and built outside the 
          source tree of libSBML. So, this step is not mandatory if you don't 
          want to import your package extension into the source tree of libSBML.

   -----------------------------------------------------------------------------
   7-1) Add configurations for make system in the current libSBML-5
   -----------------------------------------------------------------------------

    (The following example configuration is that of groups extension)

      ----------------------------------------------------------------------
      7-1-1) configure.ac
      ----------------------------------------------------------------------

        1) Add --enable-XXXX 


          =========================================================================
          dnl -------------------------------------------------------
          dnl Groups extension
          dnl -------------------------------------------------------
  
          AC_ARG_ENABLE([groups],
          AC_HELP_STRING([--enable-groups@<:@=ARG@:>@],
                         [Build the SBML groups extension (default=no)]),
            [enable_groups=$enableval],
            [enable_groups=no])
  
          if test "$enable_group" != no; then
            AC_DEFINE([USE_GROUPS], 1, [Define to 1 to build the SBML groups extension.])
            AC_SUBST(USE_GROUPS, 1)
          fi
          =========================================================================


        2) Add AC_CONFIG_FILES for additional Makefile.in files


          =========================================================================
          AC_CONFIG_FILES([src/packages/groups/Makefile])
          AC_CONFIG_FILES([src/packages/groups/common/Makefile])
          AC_CONFIG_FILES([src/packages/groups/extension/Makefile])
          AC_CONFIG_FILES([src/packages/groups/sbml/Makefile])
          =========================================================================

  
        3) Add the code for noticing the enabled package

   
          ===========================================================================
           if test "$enable_groups" != "no" ; then
             echo "  Using groups extension  = yes"
           fi
          ===========================================================================


        4) Run a shell script "autogen.sh" in the top directory of the libsbml-5
           as follows (for updating configure script):

              % ./autogen.sh
         
      ----------------------------------------------------------------------
      7-1-2) src/packages/Makefile.in
      ----------------------------------------------------------------------

        Add the name of package to 'subdirs' variable based on existing code.

   -----------------------------------------------------------------------------
   7-2) Create a directory tree of the package
   -----------------------------------------------------------------------------

      -----------------------------------------------------------------------------
      7-2-1) Create a top directory of the package in "src/packages/"
      -----------------------------------------------------------------------------

        Currently, "src/packages/groups" (groups package) and 
        "src/packages/layout" (layout package) exist in the directory.


      -----------------------------------------------------------------------------
      7-2-2) Create the following sub directories in the "src/packages/PKGNAME"
      -----------------------------------------------------------------------------

        1) common

           common header and/or class files (e.g. sbmlfwd.h) are located

        2) extension

           SBMLExtension and SBasePlugin derived classes of the package 
           extension are located

        3) sbml

           SBase derived classes of the package extension are located.

        4) util (if needed)

           Utility class files are located (e.g. LayoutAnnotation.{h,cpp} in
           layout package).

        5) other directories (if needed)


   -----------------------------------------------------------------------------
   7-3) Create Makefile.in in each sub directory based on existing 
        Makefile.in in layout or groups extensions
   -----------------------------------------------------------------------------

================================================================================

   
  
