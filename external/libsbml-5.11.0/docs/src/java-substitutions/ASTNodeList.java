package org.sbml.libsbml;

/**
 * Class for managing lists of {@link ASTNode} objects.
 * <p>
 * <em style='color: #555'>
 * This class of objects is defined by libSBML only and has no direct
 * equivalent in terms of SBML components.
 * </em>
 * <p>
 * This class is necessary because of programming language differences
 * between Java and the underlying C++ core of libSBML's implementation.
 * It would of course be preferable to have a common list type for all
 * lists returned by libSBML (e.g., lists of {@link ASTNode} objects, lists
 * of {@link CVTerm} objects, etc.).  However, this is currently impossible
 * to achieve given the way the underlying C++ lists are implemented.  (The
 * basic problem concerns the lack of an equivalent to <code>void *</code>
 * pointers in Java.)
 * <p>
 * As a result of this incompatibility, libSBML must implement the Java
 * versions of the lists in another way.  The approach taken is to
 * define specialized list types for each kind of object that needs
 * a list; that is, {@link ASTNodeList} for {@link ASTNode} objects,
 * {@link CVTermList} for {@link CVTerm} objects, and a few others.
 * These list objects provide the same kind of functionality that
 * the underlying C++ generic lists provide (such as <code>get()</code>,
 * <code>add()</code>, <code>remove()</code>, etc.), yet still
 * maintain the strong data typing requiring by Java.
 * <p>
 * @see ASTNode#getListOfNodes()
 */
public class ASTNodeList {

    /**
     * Explicit constructor for this list.
     * <p>
     * In most circumstances, callers will obtain an {@link ASTNodeList}
     * object from a call to a libSBML method that returns the list.
     * However, the constructor is provided in case callers need to
     * construct the lists themselves.
     * <p>
     * @warning Note that the internal implementation of the list nodes uses
     * C++ objects.  If callers use this constructor to create the list
     * object deliberately, those objects are in a sense "owned" by the caller
     * when this constructor is used. Callers need to remember to call
     * {@link #delete()} on this list object after it is no longer
     * needed or risk leaking memory.
     */
    public ASTNodeList() { }


    /**
     * Destructor for this list.
     * <p>
     * If a caller created this list using the {@link #ASTNodeList()}
     * constructor, the caller should use this method to delete this list
     * object after it is no longer in use.
     */
    public synchronized void delete() { }


    /**
     * Adds the given {@link ASTNode} object <code>item</code> to this
     * list.
     * <p>
     * @param item the {@link ASTNode} object to add to add
     */
    public void add(ASTNode item) { }


    /**
     * Returns the <em>n</em>th ASTNode object from this list.
     * <p>
     * If the index number <code>n</code> is greater than the size of the list
     * (as indicated by {@link #getSize()}), then this method returns
     * <code>null</code>.
     * <p>
     * @param n the index number of the item to get, with indexing
     * beginning at number <code>0</code>.
     * <p>
     * @return the nth item in this {@link ASTNodeList} items.
     * <p>
     * @see #getSize()
     */
    public ASTNode get(long n) { }


    /**
     * Adds the {@link ASTNode} object <code>item</code> to the beginning
     * of this list.
     * <p>
     * @param item a pointer to the item to be prepended.
     * <p>
     */
    public void prepend(ASTNode item) { }


    /**
     * Removes the <em>n</em>th {@link ASTNode} object from this list and
     * returns it.
     * <p>
     * Callers can use {@link #getSize()} to find out the length of the list.
     * If <code>n > </code>{@link #getSize()}, this method returns
     * <code>null</code> and does not delete anything.
     * <p>
     * @param n the index number of the item to remove
     * <p>
     * @return the item indexed by <code>n</code>
     * </p>
     * @see #getSize()
     */
    public ASTNode remove(long n) { }


    /**
     * Returns the number of items in this list.
     * <p>
     * @return the number of elements in this list.
     */
    public long getSize() { }

}
