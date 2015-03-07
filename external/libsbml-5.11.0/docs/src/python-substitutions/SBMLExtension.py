class SBMLExtension(_object):
    """
    @htmlinclude pkg-marker-core.html Core class for SBML Level 3 package plug-ins.
   
    @htmlinclude not-sbml-warning.html

    The SBMLExtension class is a component of the libSBML package
    extension mechanism.  It is an abstract class that is extended by
    each package extension implementation.

    @section sbmlextension-l2-special Special handling for SBML Level&nbsp;2

    @par
    Due to the historical background of the SBML %Layout package, libSBML
    implements special behavior for that package: it @em always creates a
    %Layout plugin object for any SBML Level&nbsp;2 document it reads in,
    regardless of whether that document actually uses %Layout constructs.  This
    is unlike the case for SBML Level&nbsp;3 documents that use %Layout; for
    them, libSBML will @em not create a plugin object unless the document
    actually declares the use of the %Layout package (via the usual Level&nbsp;3
    namespace declaration for Level&nbsp;3 packages).

    This has the following consequence.  If an application queries for the
    presence of %Layout in an SBML Level&nbsp;2 document by testing only for
    the existence of the plugin object, <strong>it will always get a positive
    result</strong>; in other words, the presence of a %Layout extension
    object is not an indication of whether a read-in Level&nbsp;2 document
    does or does not use SBML %Layout.  Instead, callers have to query
    explicitly for the existence of layout information.  An example of such a
    query is the following code:

    @code{.py}
    # Assume 'doc' below is an SBMLDocument object.
    m = doc.getModel()
    if m != None:
        layoutPlugin = m.getPlugin('layout')
        if layoutPlugin != None:
            numLayouts = layoutPlugin.getNumLayouts()
            # If numLayouts is greater than zero, then the model uses Layout.
    @endcode

    The special, always-available Level&nbsp;2 %Layout behavior was motivated
    by a desire to support legacy applications.  In SBML Level&nbsp;3, the
    %Layout package uses the normal SBML Level&nbsp;3 scheme of requiring
    declarations on the SBML document element.  This means that upon reading a
    model, libSBML knows right away whether it contains layout information.
    In SBML Level&nbsp;2, there is no top-level declaration because layout is
    stored as annotations in the body of the model.  Detecting the presence of
    layout information when reading a Level&nbsp;2 model requires parsing the
    annotations.  For efficiency reasons, libSBML normally does not parse
    annotations automatically when reading a model.  However, applications
    that predated the introduction of Level&nbsp;3 %Layout and the updated
    version of libSBML never had to do anything special to enable parsing
    layout; the facilities were always available for every Level&nbsp;2 model
    as long as libSBML was compiled with %Layout support.  To avoid burdening
    developers of legacy applications with the need to modify their software,
    libSBML provides backward compatibility by always preloading the %Layout
    package extension when reading Level&nbsp;2 models.  The same applies to
    the creation of Level&nbsp;2 models: with the plugin-oriented libSBML,
    applications normally would have to take deliberate steps to activate
    package code, instantiate objects, manage namespaces, and so on.  LibSBML
    again loads the %Layout package plugin automatically when creating a
    Level&nbsp;2 model, thereby making the APIs available to legacy
    applications without further work on their part.

    """
    def getNumOfSBasePlugins(self):
        """
        getNumOfSBasePlugins(SBMLExtension self) -> int

        Returns the number of SBasePluginCreatorBase objects stored in this
        object.

        @return the total number of SBasePluginCreatorBase objects stored in
        this SBMLExtension-derived object.

        """
        pass

    def getNumOfSupportedPackageURI(self):
        """
        getNumOfSupportedPackageURI(SBMLExtension self) -> unsigned int

        Returns the number of supported package namespace URIs.

        @return the number of supported package XML namespace URIs of this
        package extension.

        """
        pass

    def isSupported(self, *args):
        """
        isSupported(SBMLExtension self, string uri) -> bool

        Returns @c True if the given XML namespace URI is supported by this
        package extension.

        @return @c True if the given XML namespace URI (equivalent to a package
        version) is supported by this package extension, @c False otherwise.

        """
        pass

    def getSupportedPackageURI(self, *args):
        """
        getSupportedPackageURI(SBMLExtension self, unsigned int n) -> string

        Returns the nth XML namespace URI.

        @param n the index number of the namespace URI being sought.
        @return a string representing the XML namespace URI understood to be
        supported by this package.  An empty string will be returned if there is
        no nth URI.

        """
        pass

    def clone(self):
        """
        clone(SBMLExtension self) -> SBMLExtension

        Creates and returns a deep copy of this SBMLExtension object.

        @return a (deep) copy of this SBMLExtension object.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def getName(self):
        """
        getName(SBMLExtension self) -> string

        Returns the nickname of this package.

        This returns the short-form name of an SBML Level&nbsp;3 package
        implemented by a given SBMLExtension-derived class.  Examples of
        such names are 'layout', 'fbc', etc.

        @return a string, the nickname of SBML package.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def getURI(self, *args):
        """
        getURI(SBMLExtension self, unsigned int sbmlLevel, unsigned int sbmlVersion, unsigned int pkgVersion) -> string

        Returns the XML namespace URI for a given Level and Version.

        @param sbmlLevel the SBML Level.
        @param sbmlVersion the SBML Version.
        @param pkgVersion the version of the package.

        @return a string, the XML namespace URI for the package for the given
        SBML Level, SBML Version, and package version.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def getLevel(self, *args):
        """
        getLevel(SBMLExtension self, string uri) -> unsigned int

        Returns the SBML Level associated with the given XML namespace URI.

        @param uri the string of URI that represents a version of the package.

        @return the SBML Level associated with the given URI of this package.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def getVersion(self, *args):
        """
        getVersion(SBMLExtension self, string uri) -> unsigned int

        Returns the SBML Version associated with the given XML namespace URI.

        @param uri the string of URI that represents a version of the package.

        @return the SBML Version associated with the given URI of this package.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def getPackageVersion(self, *args):
        """
        getPackageVersion(SBMLExtension self, string uri) -> unsigned int

        Returns the package version associated with the given XML namespace URI.

        @param uri the string of URI that represents a version of this package.

        @return the package version associated with the given URI of this package.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def getStringFromTypeCode(self, *args):
        """
        getStringFromTypeCode(SBMLExtension self, int typeCode) -> char const *

        Returns a string representation of a type code.

        This method takes a numerical type code @p typeCode for a component
        object implemented by this package extension, and returns a string
        representing that type code.

        @param typeCode the type code to turn into a string.

        @return the string representation of @p typeCode.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def getSBMLExtensionNamespaces(self, *args):
        """
        getSBMLExtensionNamespaces(SBMLExtension self, string uri) -> SBMLNamespaces

        Returns a specialized SBMLNamespaces object corresponding to a given
        namespace URI.

        LibSBML package extensions each define a subclass of
        @if clike SBMLExtensionNamespaces @else SBMLNamespaces@endif@~.
        @if clike This object has the form
        @verbatim
        SBMLExtensionNamespaces<class SBMLExtensionType>
        @endverbatim
        For example, this kind of object for the Layout package is
        @verbatim
        SBMLExtensionNamespaces<LayoutExtension>
        @endverbatim
        @endif@~
        The present method returns the appropriate object corresponding
        to the given XML namespace URI in argument @p uri.

        @param uri the namespace URI that represents one of versions of the
        package implemented in this extension.

        @return an @if clike SBMLExtensionNamespaces @else SBMLNamespaces @endif@~ 
        object, or @c None if the given @p uri is not defined in the
        corresponding package.

        @note
        This is a method that package extension implementations must override.
        See the libSBML documentation on extending libSBML to support SBML
        packages for more information on this topic.

        """
        pass

    def setEnabled(self, *args):
        """
        setEnabled(SBMLExtension self, bool isEnabled) -> bool

        Enable or disable this package.

        @param isEnabled flag indicating whether to enable (if @c True) or
        disable (@c False) this package extension.

        @return @c True if this call succeeded; @c False otherwise.

        """
        pass

    def isEnabled(self):
        """
        isEnabled(SBMLExtension self) -> bool

        Returns @c True if this package is enabled.

        @return @c True if this package is enabled, @c False otherwise.

        """
        pass

    def isInUse(self, *args):
        """
        isInUse(SBMLExtension self, SBMLDocument doc) -> bool

        Indicates whether this extension is being used by the given SBMLDocument.

        The default implementation returns @c True.  This means that when a
        document had this extension enabled, it will not be possible to convert
        it to SBML Level&nbsp;2 as we cannot make sure that the extension can be
        converted.

        @param doc the SBML document to test.

        @return a boolean indicating whether the extension is actually being
        used by the document.

        """
        pass
