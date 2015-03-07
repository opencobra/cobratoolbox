package org.sbml.libsbml;

/**
 * <span class='pkg-marker pkg-color-layout'><a href='group__layout.html'>layout</a></span>
 *
 * Class to store SBML Level, Version, and XML namespace for the
 * SBML Layout (&ldquo;layout&rdquo;) package.
 * <p>
 * <em style='color: #555'>
 * This class of objects is defined by libSBML only and has no direct
 * equivalent in terms of SBML components.  This class is not prescribed by
 * the SBML specifications, although it is used to implement features
 * defined in SBML.
 * </em>
 * <p>
 * SBML Level&nbsp;3 &ldquo;packages&rdquo; add features on top of SBML
 * Level&nbsp;3 Core.  When a model definition uses an SBML package, it must
 * declare the Level and Version of SBML Core and the Version of the package
 * being used.  The package name, the SBML Level and Version, and the package
 * Version correspond uniquely to an XML namespace added to the XML encoding
 * of the SBML model.
 * <p>
 * LibSBML Level&nbsp;3 <em>extensions</em> are implementations of support
 * for SBML Level&nbsp;3 packages.  Each package is implemented as a separate
 * extension.  To allow software applications to query the level and version
 * information of an extension's package implementation, libSBML uses
 * specialized object classes.  For the extension implementing the SBML
 * &ldquo;layout&rdquo; package, the object class is {@link
 * LayoutPkgNamespaces}.  (This class is a specialization of a common base
 * class called <code>SBMLExtensionNamespaces</code> that is not exposed in
 * the libSBML programming language interfaces other than C++.)
 * <p>
 * Objects of class {@link LayoutPkgNamespaces} can be passed to constructors
 * of SBML components defined by &ldquo;layout&rdquo; in order to ensure that
 * the correct component structure is created.  This is necessary because
 * different versions of an SBML Level&nbsp;3 package may introduce
 * differences in the definition of the components defined by the package.
 * (For example, later editions of a package may introduce new attributes on
 * a component that are not present in earlier editions of the package
 * specification.)
 * <p>
 * @see FbcPkgNamespaces
 * @see LayoutPkgNamespaces
 * @see QualPkgNamespaces
 */
public class LayoutPkgNamespaces {

    /**
     * Creates a new {@link LayoutPkgNamespaces} object.
     * <p>
     * @warning Note that the internal implementation of the list nodes uses
     * C++ objects.  If callers use this constructor to create the list
     * object deliberately, those objects are in a sense "owned" by the caller
     * when this constructor is used. Callers need to remember to call
     * {@link #delete()} on this list object after it is no longer
     * needed or risk leaking memory.
     */
    public LayoutPkgNamespaces() { }


    /**
     * Creates and returns a deep copy of this {@link LayoutPkgNamespaces}.
     * <p>
     * @return a (deep) copy of this {@link LayoutPkgNamespaces}.
     */ 
    public LayoutPkgNamespaces cloneObject() {}


    /**
     * Destroys this object.
     * <p>
     * If a caller created this list using the {@link #LayoutPkgNamespaces()}
     * constructor, the caller should use this method to delete this list
     * object after it is no longer in use.
     */
    public synchronized void delete() { }


    /**
     * Returns a string representing the package's XML namespace.
     * <p>
     * @return a string representing the XML namespace that reflects the
     * SBML Level and Version, and the package Version.
     */
    public String getURI() { }


    /**
     * Returns the package's version number.
     * <p>
     * @return an integer, the version number for the SBML Level&nbsp;3
     * Layout package implemented by the libSBML
     * extension.
     */
    public long getPackageVersion() { }


    /**
     * Returns the short-form name or label for the package.
     * <p>
     * @return the short-form name of the SBML Level&nbsp;3 package, which in
     * this case, will be &ldquo;layout&rdquo;.
     */ 
     public String getPackageName() { }
}
