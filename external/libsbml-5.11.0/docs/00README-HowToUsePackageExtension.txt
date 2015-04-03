================================================================================
How to use package extensions in user's code.
================================================================================

This documentation describes the summary of how to manipulate an SBML 
document with package extensions in user's code.

------------------------------------------------------------
Table of contents:

  1. Required header files
  2. Read/Write an SBML document with package extensions 
  3. Get SBML elements of package extensions
  4. Creates an SBML document with package extensions
  5. Compile a program using package extensions
------------------------------------------------------------

--------------------------------------------------------------------------------
1. Required header files
--------------------------------------------------------------------------------

   To use a package extension in your program, header files of the following 
   classes need to be included:
   
       (1) SBMLExtension derived class of the package

           (e.g. GroupsExtension class is the derived class of the groups 
                 package.)

       (2) one or more SBasePlugin derived classes of the package   

           (e.g. GroupsModelPlugin class is the derived class of the groups 
                 package which is plugged in the Model class of the SBML core.)

       (3) one or more SBase derived classes of the package
   
           (e.g. Group, ListOfGroups, Member, and ListOfMembers are the SBase
                 derived classes of the groups package.)

   Each pacakge extension provides a single header file which serves to include 
   most of the above header files in a similar fashion to the SBMLTypes.h file
   in libSBML core. 
   For example, GroupsExtensionTypes.h is provided by the groups package.
   So, basically, the following two inclusions are sufficient for a program using 
   the groups package extension.

       #include "sbml/SBMLTypes.h"
       #include "sbml/groups/GroupsExtensionTypes.h"

   Similarly, the following two inclusions are sufficient for a program using 
   the layout package extension.

       #include "sbml/SBMLTypes.h"
       #include "sbml/layout/LayoutExtensionTypes.h"

--------------------------------------------------------------------------------
2. Read/Write an SBML document with package extensions 
--------------------------------------------------------------------------------

   An SBML document with package extensions can be read from a file or an 
   in-memory character string by the following existing two global functions :

       1. SBMLDocument* readSBML(const char* filename)   
       2. SBMLDocument* readSBMLFromString(const char* xml)

   If the SBML document contains an unknown package extension (e.g. a libSBML
   extension for the package is not linked), there are two possible
   outcomes.  If the 'required' attribute of the package in the SBMLDocument 
   object is 'false' then the elements/attributes of the unknown package are 
   preserved by libSBML but it makes no attempt to interpret them.  If the
   'required' attribute is true, reading the document fails and an error is 
   logged.

   To write an SBML document with package extensions to a named file or a 
   character string, the following existing two global functions can be used:

       1. int   writeSBML(const SBMLDocument* d, const char* filename)   
       2. char* writeSBMLFromString(const SBMLDocument *d)

   Note that if the given SBMLDocument object contains information about an 
   unknown package extension that has been preserved by the libSBML read 
   functions, then the elements/attributes of the unknown package are also 
   written to the file or string as-is.


--------------------------------------------------------------------------------
3. Get SBML elements of package extensions
--------------------------------------------------------------------------------

   In libSBML-5, elements/attributes of each package extension need to be 
   accessed via each SBasePlugin derived object which is plugged in an SBML 
   element to be extended.

   For example, two SBasePlugin derived classes, SBMLDocumentPlugin and 
   GroupsModelPlugin, are used by the groups extension. 
   SBMLDocumentPlugin, which is plugged in the sbml element, is a common plugin 
   class for pacakge extensions which use only 'required' attribute in the 
   SBMLDocument class, and thus the class is basically not used in user's 
   code (**). 
   On the other hand, GroupsModelPlugin, which is plugged into the model element, 
   provides public functions for manipulating the top level element of the 
   extension (ListOfGroups) such as getGroup(), addGroup(), createGroup(), 
   removeGroup(), getNumGroups() and etc.

     ---------------------------------------------------------------------------
     (**) 'required' attribute of each package extension in <sbml> element 
           can be accessed via functions in SBMLDocument class: 
           getPkgRequired(string), setPkgRequired(string,bool), and 
           isSetPkgRequired(string).
           Thus, SBMLDocumentPlugin class is not directly used for manipulating
	   the attribute in user's code.
     ---------------------------------------------------------------------------

   Each plugin object is internally automatically created and plugged in the 
   extended SBML element when the SBML element is created by its constructor with 
   information of the package extension (the information is an xmlns attribute of 
   the package extension which is contained in an SBMLNamespaces object).

   The following example code shows how to get a group and a member object of the
   groups extension from an input SBMLDocument object:

      ========================================================================

      #include <iostream>

      #include "sbml/SBMLTypes.h"
      #include "sbml/groups/GroupsExtensionTypes.h"

      using namespace std;

      int main(int argc, char* argv[])
      {
        SBMLDocument *document = readSBML("groups_example1.xml")
  
        Model *model = document->getModel();

        //
        // Get a GroupsModelPlugin object plugged in the model object.
        //
        // The type of the returned value of SBase::getPlugin() function is 
        // SBasePlugin*, and thus the value needs to be cast for the 
        // corresponding derived class.
        //
        GroupsModelPlugin* mplugin;
        mplugin = static_cast<GroupsModelPlugin*>(model->getPlugin("groups"));

        //
        // get a Group object via GroupsModelPlugin object.
        //
        Group* group = mplugin->getGroup(0);

        cout << "Group id: "      << group->getId()      << endl;
        cout << "Group SBOTerm: " << group->getSBOTerm() << endl;

        //
        // get a Member object via the Group object.	
        //
        Member* member = group->getMember(0);

        std::cout << "Member symbol: " << member->getSymbol() << std::endl;
        
        delete document;
      }

      (error check code is omitted in the example code.)
      ===========================================================================

--------------------------------------------------------------------------------
4. Create an SBML document with package extensions
--------------------------------------------------------------------------------

   To create an SBML document with package extensions, an SBMLNamespaces object
   with the xmlns attributes of the package extensions needs to be passed to
   the constructor of the SBMLDocument class, by which plugin objects of the
   package extensions are automatically internally created and plugged into the 
   corresponding SBML elements as above mentioned.

   For example, an SBMLDocument object with group and layout packages can be
   created as follows:

      ===========================================================================

      //
      // Creates an SBMLNamespaces with Layout Level 3 Version 1 Package Version1
      // and Groups Level 3 Version 1 Package Version 1
      //
      SBMLNamespaces sbmlns(3,1);
      sbmlns.addPkgNamespace("layout",1);
      sbmlns.addPkgNamespace("groups",1);

      //
      // Creates an SBML Level 3 Version 1 document with layout and group Version 1.
      //
      SBMLDocument document(&sbmlns);

      ===========================================================================

   The above code for creating an SBMLNamespaces object can be replaced with one 
   of the following other styles.

      ===========================================================================
       (1) Create an SBMLNamespace object with the given SBML level, version,
           one of package names, package version, and then adds a namespace
           of another package to the object. 

           SBMLNamespaces sbmlns(3,1,"layout",1);
           sbmlns.addPkgNamespace("groups",1);

       OR

           SBMLNamespaces sbmlns(3,1,"groups",1);
           sbmlns.addPkgNamespace("layout",1);

      (2) Create a GroupsPkgNamespaces (*) object with the given SBML level, 
          version, and package version and then adds a namespace of another 
          package to the object.

             GroupsPkgNamespaces sbmlns(3,1,1);
             sbmlns.addPkgNamespace("layout",1);

           ----------------------------------------------------------------------
           (*) GroupPkgNamespaces is an SBMLNamespace derived class for the groups 
               package. The class is basically used when creating an SBase derived 
               object defined in the groups package (e.g. Group, Member) by the
               constructor.
           ----------------------------------------------------------------------

      (3) Create a LayoutPkgNamespaces (**) object with the given SBML level, 
          version, and package version and then adds a namespace of another package 
          to the object.

             LayoutPkgNamespaces sbmlns(3,1,1);
             sbmlns.addPkgNamespace("groups",1);

           ----------------------------------------------------------------------
            (**) LayoutPkgNamespaces is an SBMLNamespace derived class for the 
                 layout package. The class is basically used for creating an SBase 
                 derived object defined in the layout package.
           ----------------------------------------------------------------------
      ===========================================================================    


   The following example code shows how to create an SBMLDocument with elements of 
   the groups extension:


      ========================================================================
      #include <iostream>

      #include "sbml/SBMLTypes.h"
      #include "sbml/groups/GroupsExtensionTypes.h"

      using namespace std;

      int main(int argc, char* argv[])
      {
        // SBMLNamespaces of SBML Level 3 Version 1 with Groups Version 1
        SBMLNamespaces sbmlns(3,1,"groups",1);

        // create the L3V1 document with groups package
        SBMLDocument document(&sbmlns);	

        // create the Model 
 
        Model *model = document.createModel();

        // create the Compartment

        Compartment* compartment = model->createCompartment();
        compartment->setId("cytosol");
        compartment->setConstant(true);

        // create the Species

        Species* species = model->createSpecies();
        species->setId("ATPc");
        species->setCompartment("cytosol");
        species->setInitialConcentration(1);
        species->setHasOnlySubstanceUnits(false);
        species->setBoundaryCondition(false);
        species->setConstant(false);

        //
        // Get a GroupsModelPlugin object plugged in the model object.
        //
        // The type of the returned value of SBase::getPlugin() function is 
        // SBasePlugin*, and thus the value needs to be casted for the 
        // corresponding derived class.
        //
        GroupsModelPlugin* mplugin;
        mplugin = static_cast<GroupsModelPlugin*>(model->getPlugin("groups"));

        //
        // Creates a Group object via GroupsModelPlugin object.
        //
        Group* group = mplugin->createGroup();

        group->setId("ATP");
        group->setSBMLTerm("SBO:0000252");

        Member* member = group->createMember();
        member->setSymbol("ATPc");

        writeSBML(&document, "groups_example.xml");
      }

      (error check code is omitted in the example code.)
      ===========================================================================
    
   If you want to read an SBML file without a package extension and want to
   add package extensions to the SBML document later, then SBase::enablePackage() 
   function needs to be invoked via the SBMLDocument object.  The function has 
   arguments (1) the URI of the package, (2) the prefix of the package, and 
   (3) "true".
   For example, groups package can be enabled by the function as follows:

      ===========================================================================    
      SBMLDocument *document = readSBML("sbmlcore-only.xml");

      //
      // enable (add) the groups package (L3V1 groups V1) 
      //
      string pkgURI = GroupsExtension::XmlnsL3V1V1;
      document->enablePackage(pkgURI,"groups",true)
      ===========================================================================

   Similarly, if you want to remove package extensions from the SBML document,
   then SBase::enablePackage() function needs to be invoked with "false" value 
   via the SBMLDocument object as follows:

      ===========================================================================    
      SBMLDocument *document = readSBML("sbml-with-groups.xml");

      //
      // disable (remove) the groups package (L3V1 groups V1) 
      //
      string pkgURI = GroupsExtension::XmlnsL3V1V1;
      document->enablePackage(pkgURI,"groups",false)
      ===========================================================================


--------------------------------------------------------------------------------
5. Compile a program using package extensions
--------------------------------------------------------------------------------

  A program which uses package extensions must be linked with not only a shared 
  library of the SBML core package but also those of the package extensions.
  For example, if the shared library files of the SBML core package, the layout 
  package, and the groups package are provided as separate files (e.g. libsbml.so 
  (core), libsbml-layout.so (layout), and libsbml-groups.so (groups) on Linux), 
  then a program (e.g. example.cpp) which manipulates those packages are compiled 
  with linker flags (-lsbml -lsbml-layout -lsbml-groups) as follows:

    g++ -o example example.cpp -lsbml -lsbml-layout -lsbml-groups

  --------------------------------------------------------------------------------
  (NOTE1) To build the shared library files of layout and/or groups extensions, 
          the libSBML-5 needs to be built with "--enable-layout" and/or
          "--enable-groups" configure options.
          
  --------------------------------------------------------------------------------
  
