/**
 * @file    SBMLWriter.cpp
 * @brief   Writes an SBML Document to file or in-memory string
 * @author  Ben Bornstein
 * 
 * <!--------------------------------------------------------------------------
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
 * ---------------------------------------------------------------------- -->*/

#include <ios>
#include <iostream>
#include <fstream>
#include <sstream>

#include <sbml/common/common.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/SBMLError.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLWriter.h>

#include <sbml/compress/CompressCommon.h>
#include <sbml/compress/OutputCompressor.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new SBMLWriter.
 */
SBMLWriter::SBMLWriter ()
{
}


/*
 * Destroys this SBMLWriter.
 */
SBMLWriter::~SBMLWriter ()
{
}


/*
 * Sets the name of this program. i.\ e.\ the one about to write out the
 * SBMLDocument.  If the program name and version are set
 * (setProgramVersion()), the following XML comment, intended for human
 * consumption, will be written at the beginning of the document:
 *
 *   <!-- Created by <program name> version <program version>
 *   on yyyy-MM-dd HH:mm with libsbml version <libsbml version>. -->
 */
int
SBMLWriter::setProgramName (const std::string& name)
{
  if (&(name) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else  
  {
    mProgramName = name;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the version of this program. i.\ e.\ the one about to write out the
 * SBMLDocument.  If the program version and name are set
 * (setProgramName()), the following XML comment, intended for human
 * consumption, will be written at the beginning of the document:
 *
 *   <!-- Created by <program name> version <program version>
 *   on yyyy-MM-dd HH:mm with libsbml version <libsbml version>. -->
 */
int
SBMLWriter::setProgramVersion (const std::string& version)
{
  if (&(version) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else  
  {
    mProgramVersion = version;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Writes the given SBML document to filename.
 *
 * If the filename ends with @em .gz, the file will be compressed by @em gzip.
 * Similary, if the filename ends with @em .zip or @em .bz2, the file will be
 * compressed by @em zip or @em bzip2, respectively. Otherwise, the fill will be
 * uncompressed.
 * If the filename ends with @em .zip, a filename that will be added to the
 * zip archive file will end with @em .xml or @em .sbml. For example, the filename
 * in the zip archive will be @em test.xml if the given filename is @em test.xml.zip
 * or @em test.zip. Also, the filename in the archive will be @em test.sbml if the
 * given filename is @em test.sbml.zip.
 *
 * @note To create a gzip/zip file, underlying libSBML needs to be linked with zlib at 
 * compile time. Also, underlying libSBML needs to be linked with bzip2 to create a 
 * bzip2 file.
 * File unwritable error will be logged and @c false will be returned if a compressed 
 * file name is given and underlying libSBML is not linked with the corresponding 
 * required library.
 * SBMLWriter::hasZlib() and SBMLWriter::hasBzip2() can be used to check whether
 * underlying libSBML is linked with the library.
 *
 * @return true on success and false if the filename could not be opened
 * for writing.
 */
bool
SBMLWriter::writeSBML (const SBMLDocument* d, const std::string& filename)
{
  std::ostream* stream = NULL;

  try
  {
    // open an uncompressed XML file.
    if ( string::npos != filename.find(".xml", filename.length() - 4) )
    {
      stream = new(std::nothrow) std::ofstream(filename.c_str());
    }
    // open a gzip file
    else if ( string::npos != filename.find(".gz", filename.length() - 3) )
    {
     stream = OutputCompressor::openGzipOStream(filename);
    }
    // open a bz2 file
    else if ( string::npos != filename.find(".bz2", filename.length() - 4) )
    {
      stream = OutputCompressor::openBzip2OStream(filename);
    }
    // open a zip file
    else if ( string::npos != filename.find(".zip", filename.length() - 4) )
    {
      std::string filenameinzip = filename.substr(0, filename.length() - 4);
  
      if ( ( string::npos == filenameinzip.find(".xml",  filenameinzip.length() - 4) ) &&
           ( string::npos == filenameinzip.find(".sbml", filenameinzip.length() - 5) )
         )
      {
        filenameinzip += ".xml";
      }


#if defined(WIN32) && !defined(CYGWIN)
      char sepr = '\\';
#else
      char sepr = '/';
#endif
      size_t spos = filenameinzip.rfind(sepr, filenameinzip.length() - 1);
      if( spos != string::npos )
      {
        filenameinzip = filenameinzip.substr(spos + 1, filenameinzip.length() - 1);
      }

      
      stream = OutputCompressor::openZipOStream(filename, filenameinzip);
    }
    else
    {
      stream = new(std::nothrow) std::ofstream(filename.c_str());
    }
  }
  catch ( ZlibNotLinked& )
  {
    // libSBML is not linked with zlib.
    XMLErrorLog *log = (const_cast<SBMLDocument *>(d))->getErrorLog();
    std::ostringstream oss;
    oss << "Tried to write " << filename << ". Writing a gzip/zip file is not enabled because "
        << "underlying libSBML is not linked with zlib."; 
    log->add(XMLError( XMLFileUnwritable, oss.str(), 0, 0) );
    return false;
  } 
  catch ( Bzip2NotLinked& )
  {
    // libSBML is not linked with bzip2.
    XMLErrorLog *log = (const_cast<SBMLDocument *>(d))->getErrorLog();
    std::ostringstream oss;
    oss << "Tried to write " << filename << ". Writing a bzip2 file is not enabled because "
        << "underlying libSBML is not linked with bzip2."; 
    log->add(XMLError( XMLFileUnwritable, oss.str(), 0, 0) );
    return false;
  } 


  if ( stream == NULL || stream->fail() || stream->bad())
  {
    SBMLErrorLog *log = (const_cast<SBMLDocument *>(d))->getErrorLog();
    log->logError(XMLFileUnwritable);
    return false;
  }

   bool result = writeSBML(d, *stream);
   delete stream;

   return result;

}


/*
 * Writes the given SBML document to the output stream.
 *
 * @return true on success and false if one of the underlying parser
 * components fail (rare).
 */
bool
SBMLWriter::writeSBML (const SBMLDocument* d, std::ostream& stream)
{
  bool result = false;

  try
  {
    stream.exceptions(ios_base::badbit | ios_base::failbit | ios_base::eofbit);
    XMLOutputStream xos(stream, "UTF-8", true, mProgramName, 
                                               mProgramVersion);
    d->write(xos);
    stream << endl;

    result = true;
  }
  catch (ios_base::failure&)
  {
    SBMLErrorLog *log = (const_cast<SBMLDocument *>(d))->getErrorLog();
    log->logError(XMLFileOperationError);
  }

  return result;
}


/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given SBML document to an in-memory string and returns a
 * pointer to it.  The string is owned by the caller and should be freed
 * (with free()) when no longer needed.
 *
 * @return the string on success and 0 if one of the underlying parser
 * components fail (rare).
 */
LIBSBML_EXTERN
char*
SBMLWriter::writeToString (const SBMLDocument* d)
{
  ostringstream stream;
  writeSBML(d, stream);

  return safe_strdup( stream.str().c_str() );
}


LIBSBML_EXTERN
char*
SBMLWriter::writeSBMLToString (const SBMLDocument* d)
{
  return writeToString(d);
}
/** @endcond */


LIBSBML_EXTERN
bool
SBMLWriter::writeSBMLToFile (const SBMLDocument* d, const std::string& filename)
{
  return writeSBML(d, filename);
}


/*
 * Predicate returning @c true if
 * underlying libSBML is linked with zlib.
 *
 * @return @c true if libSBML is linked with zlib, @c false otherwise.
 */
bool 
SBMLWriter::hasZlib() 
{
  return LIBSBML_CPP_NAMESPACE ::hasZlib();
}


/*
 * Predicate returning @c true if
 * underlying libSBML is linked with bzip2.
 *
 * @return @c true if libSBML is linked with bzip2, @c false otherwise.
 */
bool 
SBMLWriter::hasBzip2() 
{
  return LIBSBML_CPP_NAMESPACE ::hasBzip2();
}


#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
SBMLWriter_t *
SBMLWriter_create ()
{
  return new(nothrow) SBMLWriter;
}


LIBSBML_EXTERN
void
SBMLWriter_free (SBMLWriter_t *sw)
{
  delete sw;
}


LIBSBML_EXTERN
int
SBMLWriter_setProgramName (SBMLWriter_t *sw, const char *name)
{
  if (sw != NULL)
    return (name == NULL) ? sw->setProgramName("") : sw->setProgramName(name);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
SBMLWriter_setProgramVersion (SBMLWriter_t *sw, const char *version)
{
  if (sw != NULL)
    return (version == NULL) ? sw->setProgramVersion("") :
                             sw->setProgramVersion(version);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
SBMLWriter_writeSBML ( SBMLWriter_t         *sw,
                       const SBMLDocument_t *d,
                       const char           *filename )
{
  if (sw == NULL || d == NULL) 
    return 0;
  else
    return (filename != NULL) ? 
      static_cast<int>( sw->writeSBML(d, filename) ) : 0;
}


LIBSBML_EXTERN
int
SBMLWriter_writeSBMLToFile ( SBMLWriter_t         *sw,
                       const SBMLDocument_t *d,
                       const char           *filename )
{
  if (sw == NULL || d == NULL) 
    return 0;
  else
    return (filename != NULL) ? 
      static_cast<int>( sw->writeSBML(d, filename) ) : 0;
}


LIBSBML_EXTERN
char *
SBMLWriter_writeSBMLToString (SBMLWriter_t *sw, const SBMLDocument_t *d)
{
  if (sw == NULL || d == NULL) 
    return 0;
  else
    return sw->writeToString(d);
}


LIBSBML_EXTERN
int
SBMLWriter_hasZlib ()
{
  return static_cast<int>( SBMLWriter::hasZlib() );
}


LIBSBML_EXTERN
int
SBMLWriter_hasBzip2 ()
{
   return static_cast<int>( SBMLWriter::hasBzip2() );
}


LIBSBML_EXTERN
int
writeSBML (const SBMLDocument_t *d, const char *filename)
{
  SBMLWriter sw;
  if (d == NULL || filename == NULL)
    return 0;
  else
    return static_cast<int>( sw.writeSBML(d, filename) );
}


LIBSBML_EXTERN
int
writeSBMLToFile (const SBMLDocument_t *d, const char *filename)
{
  SBMLWriter sw;
  if (d == NULL || filename == NULL)
    return 0;
  else
    return static_cast<int>( sw.writeSBML(d, filename) );
}


LIBSBML_EXTERN
char *
writeSBMLToString (const SBMLDocument_t *d)
{
  SBMLWriter sw;
  if (d == NULL)
    return NULL;
  else
    return sw.writeToString(d);
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

