class DateList(_object):
    """
  
    Class for managing lists of Date objects.
   
    @htmlinclude not-sbml-warning.html
   
    This class is necessary because of programming language differences
    between Python and the underlying C++ core of libSBML's implementation.
    It would of course be preferable to have a common list type for all
    lists returned by libSBML (e.g., lists of Date objects, lists of
    Date objects, etc.).  However, this is currently impossible to
    achieve given the way the underlying C++ lists are implemented.
   
    As a result of this incompatibility, libSBML must implement the Python
    versions of the lists in another way.  The approach taken is to define
    specialized list types for each kind of object that needs a list; that
    is, DateList for Date objects, DateList for Date objects, and
    a few others.  These list objects provide the same kind of
    functionality that the underlying C++ generic lists provide (such as
    <code>get()</code>, <code>add()</code>, <code>remove()</code>, etc.).
   
    @see ModelHistory#getListModifiedDates()
    """

    def __init__(self):
          """
          __init__(self) -> string
    
          Explicit constructor for this list.
    
          In most circumstances, callers will obtain an DateList object
          from a call to a libSBML method that returns the list.  However,
          the constructor is provided in case callers need to construct the
          lists themselves.
          """
          pass

    def add(self, *args):
        """
        add(Date item)
    
        Adds the given Date object <code>item</code> to this list.
        
        @param item the Date object to add to add
        """
        pass

    def get(self, *args):
        """
        get() -> Date

        Returns the <em>n</em>th Date object from this list.
        
        If the index number <code>n</code> is greater than the size of the list
        (as indicated by #getSize()), then this method returns
        <code>None</code>.
        
        @param n the index number of the item to get, with indexing
        beginning at number <code>0</code>.
        
        @return the nth item in this DateList items.
        
        @see #getSize()
        """
        pass

    def prepend(self, *args):
        """
        prepend(Date item)

        Adds the Date object <code>item</code> to the beginning of this list.

        @param item a pointer to the item to be prepended.
        """
        pass
  
    def remove(self, *args):
        """
        remove(long n) -> Date

        Removes the <em>n</em>th Date object from this list and
        returns it.
        
        Callers can use #getSize() to find out the length of the list.
        If <code>n > </code>#getSize(), this method returns
        <code>None</code> and does not delete anything.
        
        @param n the index number of the item to remove
        
        @return the item indexed by <code>n</code>
        
        @see #getSize()
        """
        pass
  
    def getSize(self):
        """
        getSize() -> long

        Returns the number of items in this list.
        
        @return the number of elements in this list.
        """
        pass
