class ostringstream(ostream):
    """Wrapper class for the C++ standard file stream <code>ofstream</code>.

    The C++ <code>ostringstream</code> ('output string stream') provides an
    interface for writing data to strings as output streams.  This Python
    class, <code>ostringstream</code>, wraps the C++
    <code>ostringstream</code> and provides an interface to it.

    This class may be useful because some libSBML methods accept an argument
    for indicating where to send text string output.  An example is the
    SBMLDocument#printErrors() method.  The methods use
    C++ style streams and not Python stream objects.  The
    <code>ostringstream</code> object exists to bridge the Python and
    underlying native implementation.  It is a simple wrapper around the
    underlying stream object.
    """

    def __init__(self):
        """
        <span class='variant-sig-heading'>Method variant with the following signature</span>:
         <pre class='signature'>__init__(self) -> string</pre>

        Constructor for ostringstream objects.
        """

    def str(self, *args):
        """
        This method has multiple variants; they differ in the arguments
         they accept.  Each variant is described separately below.

        @par
        <hr>
        <span class='variant-sig-heading'>Method variant with the following signature</span>:
         <pre class='signature'>str(ostringstream self) -> string</pre>

        Returns the copy of the string object currently associated
        with this <code>ostringstream</code> buffer.

        @return a copy of the string object for this stream.

        @par
        <hr>
        <span class='variant-sig-heading'>Method variant with the following signature</span>:
         <pre class='signature'>str(ostringstream self, string s)</pre>

        Sets string @p s to the string object currently assosiated with
        this stream buffer.

        @param s the string to write to this stream.
        """
