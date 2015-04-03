===========================================================================
Changes in SBase class in libSBML-5   (2010-01-16)
===========================================================================

This documentation describes the changes in SBase class, which is one
of the most important classes in libSBML, in libSBML-5 for package 
developers.

  --------------------------------------------
  Table of contents:

    1. Added data members in SBase class
    2. Added member functions in SBase class
    3. Modified member functions in SBase class
    4. Added internal class in SBase.h
  --------------------------------------------

---------------------------------------------------------------------------
1. Added data members in SBase class
---------------------------------------------------------------------------

   1) std::vector<SBasePlugin*> mPlugins

      SBasePlugin derived objects of package extensions will be stored 
      in mPlugins.
    
      An SBasePlugin derived object will be added to this vector if the 
      corresponding xmlns attribute is given when creating an SBase
      derived object by the constructor accepting SBMLNamespaces as follows:
    
             SBMLNamespaces sbmlns(3,1,"layout",1);
             Model model(&sbmlns);

                OR

             SBMLNamespaces sbmlns(3,1);
             sbmlns.addNamespace("layout",1);
             Model model(&sbmlns);

                OR

             LayoutPkgNamespaces sbmlns(3,1,1);
             Model model(&sbmlns);

      ----------------------------------------------------------------------
      In the above each example code, LayoutModelPlugin object will be
      added to mPlugins of the Model object.
      ----------------------------------------------------------------------


   2) std::string mURI
    
      The namespace in which this SBase object is defined.
      This variable can be publicly accessible by getElementNamespace() function.
    
      For example, mURI of elements defined in L3 Core (or defined in Level 2
      or before) will be the URI defined in the corresponding SBML specification
      (e.g. "http://www.sbml.org/sbml/level3/version1" for L3V1 Core); and mURI
      will be "http://www.sbml.org/sbml/level3/version1/layout/version1" for
      elements defined in layout extension L3V1-V1.
      The purpose of this data member is to explicitly distinguish elements in 
      the core package and extension packages.
     
      From the implementation point of view, currently, this variable is needed 
      by SBase::getPrefix() function to identify if the prefix needs to be added 
      when printing elements of some package extension.
 

   3) XMLAttributes mAttributesOfUnknownPkg

      An XMLAttributes object containing attributes of unknown pacakges.


   4) XMLNode  mElementsOfUnknownPkg

      An XMLNode object containing elements of unknown pacakges.

---------------------------------------------------------------------------
2. Added member functions in SBase class
---------------------------------------------------------------------------

   1) SBasePlugin* getPlugin(const std::string& package);

      Returns a plugin object (extension interface) of package extension
      with the given package name (e.g. "layout") or 
      URI (e.g. LayoutExtension::XmlnsL3V1).
 
      This function is needed to manipulate additional attributes or
      top-level elements of corresponding package extension in this object.

      For example, a <layout> element (defined in layout extension) which is
      added to a <model> element can be created and received as follows: 

        ----------------------------------------------------------------------
        Model * model;

          ... // read an SBML model from a file and set the model to the "model"
          ... // variable.

        LayoutModelPlugin* mplugin;
        mplugin= static_cast<LayoutModelPlugin*>(model->getPlugin("layout"));

        if (!mplugin)
        {
           // error handling code (layout extension is not registered)
        }

        Layout* layout = mplugin->createLayout();  <--- CREATE
        ...
        layout = mplugin->getLayout(0);            <--- GET		
        ----------------------------------------------------------------------


  2) int getNumPlugins() const

     Returns the number of plugin objects added to this SBase derived object.

     (In other words, the return value is the number of package extensions
      added to this object.)


  3) int setElementNamespace(const std::string &uri)

     Sets an XML namespace in which this element defined.

     For example, all elements defined in SBML Level 3 Version 1 Core
     must set the namespace to "http://www.sbml.org/sbml/level3/version1/core";
     all elements that defined in Layout Extension Version 1 for SBML Level 3
     Version 1 Core must set the namespace to
     "http://www.sbml.org/sbml/level3/version1/layout/version1/"


     ------------------------------------------------------------
     (NOTE)

       Package developers must invoke this function in the constructors
       of SBase derived classes that accept its namespace object as follows:

          ----------------------------------------------------------
           setElementNamespace(layoutns->getURI());
 
           ("layoutns" is a pointer of LayoutPkgNamespaces object)
          ----------------------------------------------------------

     ------------------------------------------------------------


   4) bool isPkgEnabled(const std::string& pkgName) const

      Predicate returning true or false depending on whether the
      given package (pkgName) is enabled with this SBase derived object.


   5) bool isPkgURIEnabled(const std::string& pkgURI) const

      Predicate returning true or false depending on whether the
      given package (pkgURI) is enabled with this SBase derived object.
    

   6) getElementNamespace()

      Return the XML namespace (URI) in which this element defined.
      (The detail is described in the additional data member (std::string mURI) )


   7) std::string getPrefix() const;

      Return the prefix of this element.

     ------------------------------------------------------------
     (NOTE)

      An empty string will be returned if this object is located
      in default namespace.

      By default, all SBase derived objects defined in SBML core
      are located in default namespace, and thus getPrefix() 
      returns an empty string for the elements.

      Regarding SBase derived objects defined in package extensions,
      they are located in non-default namespaces (e.g. xmlns:layout="..."),
      and thus the corresponding prefix (e.g. "layout" for elements
      defined in layout extension) will be returned.
      
      However, if  SBMLDocument::enableDefaultNS(..) function
      of an SBMLDocument object is invoked with "true" flag for
      the specified package extension (e.g.  d->enableDefaultNS("layout",true) ),
      then all elements of the specified packges are located in
      default namespace as follows:


        <model>
	  ...
          <listOfLayouts xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns="http://www.sbml.org/sbml/level3/version1/layout/version1">
            <layout id="Glycolysis_Layout">
              ...
            </layout>
          </listOfLayouts>
          ...	  
        </model>	  


          (i.e. xmlns="..." attribute is added to the top-level element of
                the package extension)


      Thus, an empty string will be returned for the specified
      package extension.
     ------------------------------------------------------------


   8) unsigned int getPackageVersion () const;

      Returns the version of package to which this element belongs to.
      0 will be returned if this element belongs to Core package.


  ------------------------------------------------------------
   (**The following functions are internal implementation**)
  ------------------------------------------------------------

   9) virtual SBase* createExtensionObject (XMLInputStream& stream)
     

     Create, store, and then return an SBase derived object of package 
     extensions corresponding to the next XMLToken in the XMLInputStream.
      
     This function is invoked in SBase::read (XMLInputStream& stream)
     function when reading an SBML model from a file/string.

     ------------------------------------------------------------
     (NOTE)

      Basically, subclass doesn't have to override this function.
      ------------------------------------------------------------


  10) virtual void writeExtensionElements (XMLOutputStream& stream) const

      Writes out contained additional SBML objects of package extensions 
      (added to this SBase derived object) as XML elements.

      Currently, this function is invoked in writeElements() functions 
      of all SBase derived classes defined in SBML Core (i.e. Model, Reaction,
      Species, and ...) as follows:


           SBase::writeExtensionElements(stream);


     ------------------------------------------------------------
     (NOTE)

      Basically, 

        (1) subclasses don't have to override this function, and
        (2) package developers don't have to invoke this function in
            writeElements() functions of their SBase derived classes.
     ----------------------------------------------------------------


  11) virtual void readExtensionAttributes (const XMLAttributes& attributes)

      Read additional attributes of package extensions (added to this SBase 
      derived class) from the given XMLAttributes set into their specific fields.

      Currently, this function is invoked in readAttributes() functions of all 
      SBase derived classes defined in SBML core as follows:


          SBase::readExtensionAttributes(attributes);


     ------------------------------------------------------------
     (NOTE)

       Basically, 
         (1) subclasses don't have to override this function, and
         (2) package developers don't have to invoke this function in
             readAttributes() functions of their SBase derived classes.
     ------------------------------------------------------------


  12) virtual void writeExtensionAttributes (XMLOutputStream& stream) const

      Write additional attributes of package extensions (added to this SBase
      derived class) to the XMLOutputStream.

      Currently, this function is invoked in writeAttributes() functions of all 
      SBase derived classes defined in SBML core as follows:
   

         SBase::writeExtensionAttributes(stream);


     ----------------------------------------------------------------
     (NOTE)

        Basically, 
          (1) subclasses don't have to override this function, and
          (2) package developers don't have to invoke this function in
              writeAttributes() functions of their SBase derived classes.
     ----------------------------------------------------------------


  13) virtual void writeXMLNS (XMLOutputStream& stream) const
  
      Subclasses should override this method to write their xmlns 
      attriubutes (if any) to the XMLOutputStream.

      Currently, this function is overridden in the following classes:

         1) SBMLDocument  (top-level element of SBML Core)
         2) ListOfLayouts (top-level element of layout extension)
         3) ListOfGroups  (top-level element of group extension)

     ------------------------------------------------------------
     (NOTE)
  
     In summary, each SBase derived class that represents a top-level 
     element of its pacakge extension must override this function.
     ------------------------------------------------------------


  14) virtual void addExpectedAttributes(ExpectedAttributes& attributes);

      Add expected attributes of the corresponding SBase or SBase derived 
      objects.
      This function is invoked from corresponding readAttributes()
      function and added expected attributes are checked in the function.

      Subclasses should override this method to set the list of expected 
      attributes. Also, subclass must invoke the addExpectedAttributes()
      function of its parent class if the subclass override this function
      as follows:


          SBase::addExpectedAttributes(attributes);


     -----------------------------------------------------------------------
     (NOTE)

      In SBase::addExpectedAttributes() function, the following attributes
      are added, and thus basically subclass doen't have to add the attributes:

         - metaid   (SBML Level 2 or later)       
         - sboTerm  (SBML Level 2 Version 3 or later)
  
     The purpose of this function is to provide extensibility about
     readAttributes() function. 
     -----------------------------------------------------------------------


  15) void storeUnknownExtAttribute(const std::string& element,
                                   const XMLAttributes& xattr,
                                   unsigned int index);

      Stores the given attribute to the list of ignored attributes 
      (mAttributesOfUnknownPkg) if the given attribute belongs to some 
      unknown package extension.
      Unknown attribute error will be logged if the "required" attribute
      of the package is "true" in SBMLDocument element.
   
      The stored attributes will be written out as-is when writing the
      SBMLDocument to a string or a file (i.e. Attributes and elements of
      unknown package extensions will not be lost when reading/writing
      a file/sting containing them.)
   
      This function is invoked in SBase::readAttributes() function.


  16) bool storeUnknownExtElement(XMLInputStream &stream)

      Stores the element of next token if the element belongs to some
      unknown package extension. Unknown element error will be logged if
      the "required" attribute of the package is "true" in SBMLDocument
      element.
   
      The stored elements will be written out as-is when writing the
      SBMLDocument to a string or a file (i.e. Attributes and elements of
      unknown package extensions will not be lost when reading/writing
      a file/sting containing them.)

      This function is invoked in SBase::read() function.


  17) SBase::setSBMLNamespacesAndOwn(SBMLNamespaces * sbmlns)

      Sets the given SBMLnamespaces (derived) object to this object
      and ownes the given object (i.e. the ownership of the given object
      moves from the caller to this object).

      ----------------------------------------------------------------------
      (NOTE)

      The purpose of this function is only for internal use by the
      constructors of SBase subclasses in extension packages that
      accept arguments of SBML Level, Version, and Package Version.
      ----------------------------------------------------------------------


  18) SBase::connectToParent(SBase* parent)     

      Sets the parent SBML object of this SBML object 
      (Creates a child-parent relationship by the child).
      This function is called when a child element is set/added/created 
      by its parent element (e.g. by setXXX, addXXX, createXXX, and 
      connectToChild functions of the parent element)


  19) virtual SBase::connectToChild(SBase* parent)     

      Sets this SBML object to child SBML objects (if any).
      (Creates a child-parent relationship by the parent)

      Subclasses must override this function if they define one ore more 
      child elements.
      Basically, this function needs to be called in constructor, 
      copy constructor, assignment operator.
      

---------------------------------------------------------------------------
3. Modified member functions in SBase class
---------------------------------------------------------------------------

   1) virtual void readAttributes (const XMLAttributes& attributes,
                                   const ExpectedAttributes& attributes);

      The second argument of expected attributes has been added.
      Be sure to call parents implementation of this method as follows:
      

         SBase::readAttributes(attributes,expectedAttributes);

	 
      Previously, expected attributes have been locally created and checked
      in each readAttributes() fuction of each SBase derived class.

      However, this breaks extensibility on checking expected attributes
      , because additional attributes in a derived class of package extension
      can be identified as an unknown attribute in existing implementation.



   2) SBase (SBMLNamespaces* sbmlns, SBMLTypeCode_t typeCode = SBML_UNKNOWN)

      Creates a new SBase object with the given SBMLNamespaces and SBMLTypeCode_t.
      (The second argument has been added as a default argument.)

      --------------------------------------------------------------------------------
      (NOTE)

      The second argument (SBMLTypeCode_t) is internaly used to identify
      the target element to which an SBasePlugin derived object will be added.

      In this constructor, an SBasePlugin derived object will be created and 
      added to mPlugins (a vector of SBasePlugin*) if a corresponding XMLNamespace 
      of a package extension is contained in the given SBMLNamespaces object.
      --------------------------------------------------------------------------------


   3) setId(), getId(), unSetId(), isSetId()
      setName(), getName(), unSetName(), isSetName()

      ---------------------------------------------------------------------------
      (NOTE)   

      These functions have been modified as virtual functions like liSBML 3.x
      (1) to provide backward compatiblitity, and (2) to reduce implementation
      cost for us and package developers.

      Basically, these functions must be overridden by a subclass if the subclass
      requires the corresponding attributes ("id" and/or "name")

      SBase::setId(), SBase::unsetId(), SBase::setName(), and SBase::unsetName()
      functions do nothing and just returns an error code (LIBSBML_OPERATION_FAILED).

      SBase::getId() and SBase::geName() function always returns an empty string.

      SBase::isSetId() and SBase::isSetName() function always returns "false".


      (These functions may need to be modified)
      ---------------------------------------------------------------------------


---------------------------------------------------------------------------
4. Added internal class in SBase.h
---------------------------------------------------------------------------
  
  The following internal class (ExpectedAttributes) has been added in SBase.h
  to be used in the modified SBase::readAttribute(..) function and the added 
  SBase::addExpectedAttributes(..) function.
   
  ---------------------------------------------------------------------------
  class ExpectedAttributes
  {
  public:

    ExpectedAttributes()
    {}

    ExpectedAttributes(const ExpectedAttributes& orig)
      : mAttributes(orig.mAttributes)
    {}

    void add(const std::string& attribute) { mAttributes.push_back(attribute); }

    std::string get(unsigned int i) const
    {
      return (mAttributes.size() < i) ? mAttributes[i] : "";
    }

    bool hasAttribute(const std::string& attribute) const
    {
      return ( std::find(mAttributes.begin(), mAttributes.end(), attribute)
               != mAttributes.end() );
    }

    private:
    std::vector<std::string> mAttributes;
  };
  ---------------------------------------------------------------------------


===========================================================================

