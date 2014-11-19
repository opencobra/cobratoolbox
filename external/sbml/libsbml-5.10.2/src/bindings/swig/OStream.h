/**
 * @file    OStream.h
 * @brief   Definition of wrapper classes for C++ standard output streams.
 * @author  Akiya Jouraku
 * 
 *<!-----------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 *
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------>
 *
 * @class OStream
 *
 * Wrapper class for the C++ standard streams <code>cout</code>,
 * <code>cerr</code>, and <code>clog</code>.
 *
 * A few libSBML methods accept an argument for indicating where to send
 * text string output.  An example is the SBMLDocument::printErrors(OStream
 * stream) method. However, the methods use C++ style streams and not Java
 * stream objects.  The OStream object exists to bridge the Java and
 * underlying native implementation.  It is a simple wrapper around the
 * underlying stream object and provides a few basic methods for
 * manipulating it.
 * 
 * @class OFStream
 *
 * Wrapper class for the C++ standard file stream <code>ofstream</code>.
 *
 * The C++ <code>ofstream</code> ("output file stream") provides an
 * interface for writing data to files as output streams.  This class,
 * OFStream, wraps the C++ <code>ofstream</code> and provides an OStream
 * interface to it.  The file to be associated with the stream can be
 * specified as a parameter to the constructors in this class.
 *
 * This class may be useful because some libSBML methods accept an argument
 * for indicating where to send text string output.  An example is the
 * SBMLDocument::printErrors(OStream stream) method.  The methods use C++ style streams
 * and not Java stream objects.  The OStream object exists to bridge the
 * Java and underlying native implementation.  It is a simple wrapper
 * around the underlying stream object and provides a few basic methods for
 * manipulating it.
 *
 * @class OStringStream
 *
 * Wrapper class for the C++ standard stream <code>ostringstream</code>.
 * 
 * The C++ <code>ostringstream</code> ("output string stream class")
 * provides an interface to manipulating strings as if they were output
 * streams.  This class class, OStringStream, wraps the
 * <code>ostringstream</code> and provides an OStream interface to it.
 * 
 * This class may be useful because some libSBML methods accept an argument
 * for indicating where to send text string output.  An example is the 
 * SBMLDocument::printErrors(OStream stream) method.  The methods use
 * C++ style streams and not Java stream objects.  The OStream object
 * exists to bridge the Java and underlying native implementation.  It is a
 * simple wrapper around the underlying stream object and provides a few
 * basic methods for manipulating it.
 */

#ifndef OStream_h
#define OStream_h

#include <iostream>
#include <fstream>
#include <sstream>

#include <sbml/xml/XMLExtern.h>

class LIBLAX_EXTERN OStream 
{
  protected:
    std::ostream* Stream;

  public:

    /**
     * Enumeration listing the possible types of streams to create.
     * <p>
     * This is used by the constructor for this class.  The names
     * of the enumeration members are hopefully self-explanatory.
     */
    enum StdOSType {COUT, CERR, CLOG};


    /**
      * Creates a new OStream object with one of standard output stream objects.
      * 
      * @param sot a value from the StdOSType enumeration(COUT, CERR, or CLOG) 
			* indicating the type of stream to create.
      */
    OStream (StdOSType sot = COUT); 


    /**
     * Destructor.
     */
    virtual ~OStream (); 


    /**
     * Returns the stream object.
     * <p>
     * @return the stream object
     */
    virtual std::ostream* get_ostream ();  


    /**
     * Writes an end-of-line character on this tream.
     */
    void endl ();
  
};
  

class LIBLAX_EXTERN OFStream : public OStream 
{
  public:
    /**
     * Creates a new OFStream object for a file.
     * <p>
     * This opens the given file @p filename with the @p is_append flag
     * (default is <code>false</code>), and creates an OFStream object
     * instance that associates the file's content with an OStream object.
     * <p>
     * @param filename the name of the file to open
     * @param is_append whether to open the file for appending (default:
     * <code>false</code>, meaning overwrite the content instead)
     * 
     * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif
     */
    OFStream (const std::string& filename, bool is_append = false); 

  
    /**
     * Destructor.
     */
    virtual ~OFStream ();


    /**
     * Opens a file and associates this stream object with it.
     * <p>
     * This method opens a given file @p filename with the given
     * @p is_append flag (whose default value is <code>false</code>),
     * and associates <i>this</i> stream object with the file's content.
     * <p>
     * @param filename the name of the file to open
     * @param is_append whether to open the file for appending (default:
     * <code>false</code>, meaning overwrite the content instead)
     * 
     * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif
     */
    void open (const std::string& filename, bool is_append = false);
  

    /**
     * Closes the file currently associated with this stream object.
     */
    void close ();
  

    /**
     * Returns <code>true</code> if this stream object is currently
     * associated with a file.
     * <p>
     * @return <code>true</code> if the stream object is currently
     * associated with a file, <code>false</code> otherwise
     */
    bool is_open (); 
  
};
  

class LIBLAX_EXTERN OStringStream : public OStream 
{
  public:
    /**
     * Creates a new OStringStream object
     */
    OStringStream (); 
  

    /**
     * Returns the copy of the string object currently assosiated 
     * with this <code>ostringstream</code> buffer.
     * <p>
     * @return a copy of the string object for this stream
     */
    std::string str (); 
  

    /**
     * Sets string @p s to the string object currently assosiated with
     * this stream buffer.
     * <p>
     * @param s the string to write to this stream
     */
    void str (const std::string& s);
  

    /**
     * Destructor.
     */
    virtual ~OStringStream (); 
  
};

#endif // OStream_h

