package org.sbml.libsbml;

/**
 * Exceptions class for libSBML object constructors.
 * <p>
 * <em style='color: #555'>
 * This class of objects is defined by libSBML only and has no direct
 * equivalent in terms of SBML components.
 * </em>
 * <p>
 * This class makes it possible to catch exceptions thrown by some libSBML
 * constructors in the XML interface layer.  Callers can use the class
 * in code such as the following example:
 * <div class='fragment'><pre>
XMLAttributes x;
<em>... do things with XMLAttributes object x ...</em>

XMLAttributes xcopy;
try
{
    xcopy = new XMLAttributes(x);
}
catch (XMLConstructorException e)
{
    String errmsg = e.getMessage();
}
</pre></div>
 * <p>
 * Not all libSBML object classes throw this exception; the cases are
 * limited to the classes that create SBML objects (e.g.,
 * {@link Compartment}, {@link Species}, etc.) and {@link SBMLDocument}.
 */
public class XMLConstructorException extends java.lang.IllegalArgumentException
{
    /**
     * Constructor; version taking a message argument.
     * <p>
     * @param message The exception message.
     */
    public XMLConstructorException(String message) {}


    /**
     * Constructor; version taking no arguments.
     */
    public XMLConstructorException() {}


    /**
     * Destructor for this list.
     * <p>
     * Callers can use this method to delete this object explicitly
     * after it is no longer needed.
     */
    public synchronized void delete() { }
}
