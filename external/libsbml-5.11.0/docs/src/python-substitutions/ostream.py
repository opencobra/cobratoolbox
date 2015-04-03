class ostream(_object):
    """Wrapper class for the C++ standard stream <code>ostream</code>.

    The C++ <code>ostream</code> provides an interface for writing data to
    the standard C++ output streams named <code>cout</code>,
    <code>cerr</code> and <code>clog</code>.  This Python class,
    <code>ostream</code>, wraps the C++ <code>ostream</code> and provides an
    interface to it.  The file to be associated with the stream can be
    specified as a parameter to the constructors in this class.

    This class may be useful because some libSBML methods accept an argument
    for indicating where to send text string output.  An example is the
    SBMLDocument#printErrors() method.  The methods use C++
    style streams and not Python stream objects.  The ostream object exists
    to bridge the Python and underlying native implementation.  It is a
    simple wrapper around the underlying stream object.

    """
    def __init__(self):
        """
        <span class='variant-sig-heading'>Method variant with the following signature</span>:
         <pre class='signature'>__init__(self) -> string</pre>

        Constructor for ostream objects.
        """
