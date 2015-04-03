===========================================================================
Summary of extension support classes in libSBML-5 (2010-01-15)
===========================================================================

This documentation describes the summary of the extension support 
classes which are used by package developers for creating their
package extensions.

  ---------------------------------------------------------------------------
  (NOTE) 

   Most of APIs used by package developers are only following classes.

     1) SBMLExtension
     2) SBasePlugin
     3) SBaseExtensionPoint
     4) SBMLExtensionNamespaces
     5) SBMLExtensionException

   The following classes are also used by package developers but basically 
   only little code is needed when using these classes in each package, 
   because (1) each class below is a template class or a common class which 
   is basically defined/instantiated by only one line, and (2) basically 
   they are internally used in extension support classes and SBase class, 
   and thus package developers don't have to modify or extend the internal 
   implementation.
   
      1) SBasePluginCreator
      2) SBMLExtensionRegistry
      3) SBMLExtensionRegister
      4) SBMLDocumentPlugin

   Package developers must implement not only extension support classes 
   described below but also SBase derived classes of elements defined
   in their packages. For example, Group, ListOfGroups, Member, and 
   ListOfMembers classes are implemented in the groups extension (These classes 
   are implemented in "src/packages/groups/sbml/").
   ----------------------------------------------------------------------------

1) SBMLExtension class

   SBMLExtension class (abstract class) is a core component of each package extension.
   The feature of this class is as follows:

       (1) provides pure virtual functions for getting common attributes
           (e.g. the name (label) of package, default level, version, and 
            package_version, URI of package versions, a string corresponding
            to the typecode of element, and etc.),

       (2) stores SBasePluginCreatorBase derived objects (factory objects)
           for creating corresponding SBasePlugin derived objects (described
           later),

       (3) provides functions for adding/getting the SBasePluginCreatorBase 
           derived objects,

    Package developers must implement a derived class of the SBMLExtension class; 
    and must implement (1) pure virtual functions in the SBMLExtension class and 
    (2) the following static functions in the derived class:

       (1) defines common static functions (e.g. the name (label) of package, 
           default level, version, and package_version, URI of package versions, 
           and etc.),
	
       (2) provides static init() function that registers the package extension to  
           the SBMLExtensionRegistry class.
          (the static init() function is actually implemented in each SBMLExtension
           derived class implemented by package developers.)
	   
    The detailed information (what virtual functions must be overridden, what static
    data member must be implemented and etc.) is described in the header file of the
    class ( "src/extension/SBMLExtension.h" )


2) SBasePlugin class

   In libSBML-5, each SBase derived object contains zero or more SBasePlugin
   derived objects of package extensions. SBasePlugin derived class defines 
   additional attributes and/or top-level elements of its package extension 
   which are directly added to the target element (e.g. <listOfLayouts> element 
   in the layout extension is directly added to the Model element), and 
   provides functions for reading/writing/creating/setting/getting them.
   
   SBasePlugin class defines basic virtual functions for reading/writing/
   checking additional attributes and/or top-level elements which should or 
   must be overridden by subclasses like SBase class and its derived classes.
   
   Package developers must implement a new SBasePlugin derived class for 
   each element (e.g. SBMLDocument, Model, ...) to which additional attributes 
   and/or top-level elements of the package extension are added.

   To implement reading/writing functions for attributes and/or top-level 
   elements (e.g. readAttributes, writeElements) of the SBsaePlugin derived 
   class, package developers should or must override the corresponding virtual 
   functions provided in the SBasePlugin class.
   
   To implement package-specific creating/getting/manipulating functions of the 
   SBasePlugin derived class (e.g. getListOfLayouts(), createLyout(), getLayout(), 
   and etc in the Model element for layout package), package developers must newly 
   implement such functions (as they like) in the derived class.

   SBasePlugin class defines other virtual functions of internal implementations
   (setSBMLDocument(), connectToParent(), and enablePackageInternal() functions).
   These functions should or must be overridden by subclasses in which one or
   more top-level elements are defined.

   For example, the following three SBasePlugin derived classes are implemented in 
   the layout extension:

     1) SBMLDocuementPlugin class (*) for SBMLDocument element 

         - 'required' attribute is added to SBMLDocument object.

	 -------------------------------------------------------------------
         (*) A common SBasePlugin derived class for SBMLDocument class.
             Package developers can use this class as-is if no additional 
             elements/attributes (except for 'required' attribute) is 
             needed for the SBMLDocument class in their packages, otherwise
             package developers must implement a new SBMLDocumentPlugin
             derived class.
	 -------------------------------------------------------------------

     2) LayoutModelPlugin class for Model element 

        - 'listOfLayouts' element is added to Model object.

        - The following virtual functions for reading/writing/checking
          are overridden: (type of arguments and return values are omitted)

            - createObject()    : (read elements)
            - readOtherXML()    : (read elements in annotation of SBML L2)
            - writeElements()   : (write elements)

        - The following virtual functions of internal implementations
          are overridden: (type of arguments and return values are omitted)

            - setSBMLDocument()
            - connectToParent()
            - enablePackageInternal()

        - The following creating/getting/manipulating functions are newly 
          implemented: (type of arguments and return values are omitted)

           - getListOfLayouts() 
           - getLayout ()      
           - addLayout()
           - createLayout()
           - removeLayout()
           - getNumLayouts()

	   
     3) LayoutSpeciesReferencePlugin class for SpeciesReference element

        - 'id' attribute is internally added to SpeciesReference object
           only for SBML L2V1

        - The following virtual functions for reading/writing/checking
          are overridden: (type of arguments and return values are omitted)

          - readOtherXML()
          - writeAttributes()

   In summary, each package extension must define a set of SBaesPlugin
   derived classes. 
   The set of SBasePlugin derived objects are created and registered by 
   the SBMLExtension (described later) derived class of the package.


3) SBaseExtensionPoint class

  SBaseExtensionPoint class consists of a package name and a typecode of
  the SBase subclass, which represents an extension point to which an 
  SBasePlugin object is connected.

  For example, an SBaseExtensionPoint object for an LayoutModelPlugin object
  (a plugin object of the layout extension which is connected to the Model
  element of the SBML core package) can be created as follows:


     SBaseExtensionPoint modelextp("core", SBML_MODEL);


  Similarly, an SBaseExtensionPoint object for some plugin object connected
  to the Layout element of the layout extension can be created as follows:


     SBaseExtensionPoint layoutextp("layout", SBML_LAYOUT_LAYOUT);


  For example, package developers use this class in init() function of each
  SBMLExtension derived class for initializing each extension.


4) SBasePluginCreatorBase and SBasePluginCreator classes

   The SBasePlugin derived objects are internally/dynamically created and added 
   to the target SBML element (e.g. Model element for the LayoutModelPlugin object)
   if the package extension is required when creating an SBML element.
   
      -----------------------------------------------------------------------------
      (example)

         SBMLNamespaces sbmlns(3,1,"layout",1); <--- SBML L3V1 Core with Layout V1
         Model model(&sbmlns);     

       LayoutModelPlugin object (SBML L3V1 Layout V1) is 
       internally/dynamically created and added to the Model object 
       ("model") when the "model" object is constructed in the above
       example code.

           SBMLNamespaces sbmlns(3,1);   <--- SBML L3V1 Core 
           Model model(&sbmlns);    

       Other hand, no SBasePlugin derived objects are created/added
       when no package extensions are specified as the above code.
      -----------------------------------------------------------------------------

   The creation is internally performed by an SBasePluginCreatorBase derived 
   class (a factory class for SBasePlugin derived object) by invoking its 
   "createPlugin()" function.

       --------------------------------------------------------------------
       The corresponding code is internally implemented in the constructors 
       of SBase and SBMLDocument classes that accept SBMLNamespaces object.
       --------------------------------------------------------------------

   Although package developers must implement such derived class for each 
   SBasePlugin derived class, the derived classes can be easily implemented 
   (by only one line) by using the template class "SBasePluginCreator" which 
   is the derived class of the SBasePluginCreatorBase.

       ---------------------------------------------------------------------
       An example code defining the SBasePluginCreator classes can be shown
       in init() functions in "src/packages/layout/LayoutExtension.cpp" and
       "src/packages/groups/GroupExtension.cpp")
       ---------------------------------------------------------------------

5) SBMLExtensionNamespaces class

   SBMLExtensionNamespaces is a template class and derived from SBMLNamespaces class.
   Package developers must define its own SBMLNamespaces derived class from this template
   class by defining a typedef declaration for their templated class as follows:
   
      typedef SBMLExtensionNamespaces<LayoutExtension> LayoutPkgNamespaces   

     (this code is implemented in "src/packages/layout/extension/LayoutExtension.h")

   Also, package developers must implement a template instantiation code for the above 
   typedef definition in the implementation file (i.e. *.cpp file).
   For example, the template instantiation code for LayoutExtension is as follows:
  
        template class LIBSBML_EXTERN SBMLExtensionNamespaces<LayoutExtension>;

     (this code is implemented in "src/packages/layout/extension/LayoutExtension.cpp")

 
   The purpose of this class is as follows:

     1) To add information of package version
     2) To avoid passing an invalid SBMLNamespaces object to the constructors
        of SBase derived classes of package extensions at runtime.

   Each SBase derived class of package extensions should implement a constructor
   that accepts its SBMLNamespaces derived class.


6) SBMLExtensionRegistry class

    SBMLExtensionRegistry class is a common registry class that stores SBMLExtension
    derived objects registered by package extensions (i.e. stores the information of
    list of package extensions and factory objects of each package extension).
    This class provide the following features:

       (1) registering a package extension (performed by each package extension)
           (adding an SBMLExtension derived class of package extension)
	      
       (2) returning an SBMLExtension derived object for callers to get common 
           properties (e.g. the name of package, default level, version, 
           package_version, and URI of package versions) of the target package 
           extension.

       (3) returning an SBasePluginCreatorBase derived object for callers (basically 
           the caller is SBase class) to internally add an SBasePlugin object of the 
           target package extension (basically when creating an SBase object with 
           the package extension)

       (4) enabling/disabling the registered package extensions.

       (5) getting the number of registered package extensions.


    At least, package developers must use this class for implementing init() function 
    in their SBMLExtension derived class for registering their packages to this class
    as follows:


       int result = SBMLExtensionRegistry::getInstance().addExtension(&layoutExtension);


    Only one object of this class can be instantiated (i.e. singleton design pattern).


7) SBMLExtensionRegister class
         
    SBMLExtensionRegister class is a template class for automatically 
    registering each package extension to the SBMLExtensionRegistry class
    before main() routine invoked.
    This class is very simple and easy to be used as follows (by only one line):


       static SBMLExtensionRegister<LayoutExtension> layoutExtensionRegistry;


    How to use this class is described in SBMLExtension.h.

8) SBMLExtensionException class

    SBMLExtensionException class is a exception class which can be thrown 
    when an exception about pacakge extension occurs (e.g. required package
    is not registered).

    Currently, the exception can be thrown in the following functions if
    the required package is not registered:
    
       1) the constructor of SBMLNamespaces 
       2) the constructor of SBMLExtensionNamespaces

===========================================================================

written by Akiya Jouraku
