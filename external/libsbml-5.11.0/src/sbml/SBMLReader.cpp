/**
 * @file    SBMLReader.cpp
 * @brief   Reads an SBML Document into memory
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

#include <sbml/xml/XMLError.h>
#include <sbml/xml/XMLErrorLog.h>
#include <sbml/xml/XMLInputStream.h>

#include <sbml/SBMLErrorLog.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/Model.h>
#include <sbml/SBMLReader.h>

#include <sbml/compress/CompressCommon.h>
#include <sbml/compress/InputDecompressor.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new SBMLReader and returns it. 
 */
SBMLReader::SBMLReader ()
{
}


/*
 * Destorys this SBMLReader.
 */
SBMLReader::~SBMLReader ()
{
}


/*
 * Reads an SBML document from the given file.  If filename does not exist
 * or is not an SBML file, an error will be logged.  Errors can be
 * identified by their unique ids, e.g.:
 *
 * <code>
 *   SBMLDocument* d = reader.readSBML(filename);
 *
 *   if (d->getNumErrors() > 0)\n
 *   {\n
 *     if (d->getError(0)->getId() == SBML_READ_ERROR_FILE_NOT_FOUND)\n
 *     if (d->getError(0)->getId() == SBML_READ_ERROR_NOT_SBML)\n
 *   }\n
 * </code>
 *
 * If the filename ends with @em .gz, the file will be read as a @em gzip file.
 * Similary, if the filename ends with @em .zip or @em .bz2, the file will be
 * read as a @em zip or @em bzip2 file, respectively. Otherwise, the fill will be
 * read as an uncompressed file.
 * If the filename ends with @em .zip, only the first file in the archive will
 * be read if the zip archive contains two or more files.
 *
 * To read a gzip/zip file, underlying libSBML needs to be linked with zlib
 * at compile time. Also, underlying libSBML needs to be linked with bzip2 
 * to read a bzip2 file. File unreadable error will be logged if a compressed 
 * file name is given and underlying libSBML is not linked with the corresponding 
 * required library.
 * SBMLReader::hasZlib() and SBMLReader::hasBzip2() can be used to check 
 * whether libSBML is linked with each library.
 * 
 * @return a pointer to the SBMLDocument read.
 */
SBMLDocument*
SBMLReader::readSBML (const std::string& filename)
{
  return readInternal(filename.c_str(), true);
}


/*
 * Reads an SBML document from the given filename.
 */
SBMLDocument*
SBMLReader::readSBMLFromFile (const std::string& filename)
{
  return readInternal(filename.c_str(), true);
}


/*
 * Reads an SBML document from the given XML string.
 *
 * If the string does not begin with XML declaration:
 *
 *   <?xml version='1.0' encoding='UTF-8'?>
 *
 * it will be prepended.
 *
 * This method will log a fatal error if the XML string is not SBML.  See
 * the method documentation for readSBML(filename) for example error
 * checking code.
 *
 * @return a pointer to the SBMLDocument read.
 */
SBMLDocument*
SBMLReader::readSBMLFromString (const std::string& xml)
{
  if (&xml == NULL) return NULL;

  const static string dummy_xml ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");  
  
  if (!strncmp(xml.c_str(), dummy_xml.c_str(), 14))
  {
    return readInternal(xml.c_str(), false);
  }
  else
  {
    const std::string temp = (dummy_xml + xml);
    return readInternal(temp.c_str(), false);
  }
  
  
}


/*
 * Predicate returning @c true if
 * libSBML is linked with zlib.
 *
 * @return @c true if libSBML is linked with zlib, @c false otherwise.
 */
bool 
SBMLReader::hasZlib() 
{
  return LIBSBML_CPP_NAMESPACE ::hasZlib();
}


/*
 * Predicate returning @c true if
 * libSBML is linked with bzip2.
 *
 * @return @c true if libSBML is linked with bzip2, @c false otherwise.
 */
bool 
SBMLReader::hasBzip2() 
{
  return LIBSBML_CPP_NAMESPACE ::hasBzip2();
}


/** @cond doxygenLibsbmlInternal */
static bool
isCriticalError(const unsigned int errorId)
{
  switch (errorId)
  {
  case InternalXMLParserError:
  case UnrecognizedXMLParserCode:
  case XMLTranscoderError:
  case BadlyFormedXML:
  case InvalidXMLConstruct:
  case UnclosedXMLToken:
  case XMLTagMismatch:
  case BadXMLPrefix:
  case MissingXMLAttributeValue:
  case BadXMLComment:
  case XMLUnexpectedEOF:
  case UninterpretableXMLContent:
  case BadXMLDocumentStructure:
  case InvalidAfterXMLContent:
  case XMLExpectedQuotedString:
  case XMLEmptyValueNotPermitted:
  case MissingXMLElements:
  case BadXMLDeclLocation:
    return true;

  default:
    return false;
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Used by readSBML() and readSBMLFromString().
 */
SBMLDocument*
SBMLReader::readInternal (const char* content, bool isFile)
{
  SBMLDocument* d = new SBMLDocument();
  if (isFile) {
    d->setLocationURI(string("file:") + content);
  }

  if (isFile && content != NULL && (util_file_exists(content) == false))
  {
    d->getErrorLog()->logError(XMLFileUnreadable);
  }
  else 
  {
    XMLInputStream stream(content, isFile, "", d->getErrorLog());

    if (stream.peek().isStart() && stream.peek().getName() != "sbml")
    {
      // the root element ought to be an sbml element. 
      d->getErrorLog()->logError(NotSchemaConformant);
	  return d;
    }
	
    d->read(stream);
    
    if (stream.isError())
    {
      // If we encountered an error, some parsers will report it sooner
      // than others.  Unfortunately, those that fail sooner do it in an
      // opaque call, so we can't change the behavior.  Since we don't want
      // different parsers to report different validation errors, we bring
      // all parsers back to the same point.

      d->setModel(NULL);

      for (unsigned int i = 0; i < d->getNumErrors(); ++i)      
      {
        if (isCriticalError(d->getError(i)->getErrorId()))
        {
          // If we find even one critical error, all other errors are
          // suspect and may be bogus.  Remove them.

          for (int n = d->getNumErrors()-1; n >= 0; n--)      
            if (!isCriticalError(d->getError(n)->getErrorId()))
            {
              d->getErrorLog()->remove(d->getError(n)->getErrorId());
            }

          break;
        }
      }
    }
    else
    {
      // Low-level XML errors will have been caught in the first read,
      // before we even attempt to interpret the content as SBML.  Here
      // we want to start checking some basic SBML-level errors.

      if (stream.getEncoding() == "")
      {
        d->getErrorLog()->logError(MissingXMLEncoding);
      }
      else if (strcmp_insensitive(stream.getEncoding().c_str(), "UTF-8") != 0)
      {
        d->getErrorLog()->logError(NotUTF8);
      }

      if (stream.getVersion() == "")
      {
        d->getErrorLog()->logError(BadXMLDecl);
      }
      else if (strcmp_insensitive(stream.getVersion().c_str(), "1.0") != 0)
      {
        d->getErrorLog()->logError(BadXMLDecl);
      }

      if (d->getModel() == NULL)
      {
        d->getErrorLog()->logError(MissingModel, 
                                   d->getLevel(), d->getVersion());
      }
      else if (d->getLevel() == 1)
      {
	// In Level 1, some listOfElements were required.

        if (d->getModel()->getNumCompartments() == 0)
        {
          d->getErrorLog()->logError(NotSchemaConformant,
				     d->getLevel(), d->getVersion(), 
            "An SBML Level 1 model must contain at least one <compartment>.");
        }

        if (d->getVersion() == 1)
        {
          if (d->getModel()->getNumSpecies() == 0)
          {
            d->getErrorLog()->logError(NotSchemaConformant,
				       d->getLevel(), d->getVersion(), 
            "An SBML Level 1 Version 1 model must contain at least one <species>.");
          }
          if (d->getModel()->getNumReactions() == 0)
          {
            d->getErrorLog()->logError(NotSchemaConformant,
				       d->getLevel(), d->getVersion(), 
            "An SBML Level 1 Version 1 model must contain at least one <reaction>.");
          }
        }
      }
    }
  }
  return d;
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
SBMLReader_t *
SBMLReader_create ()
{
  return new (nothrow) SBMLReader;
}


LIBSBML_EXTERN
void
SBMLReader_free (SBMLReader_t *sr)
{
  delete sr;
}


LIBSBML_EXTERN
SBMLDocument_t *
SBMLReader_readSBML (SBMLReader_t *sr, const char *filename)
{
  if (sr != NULL)
    return (filename != NULL) ? sr->readSBML(filename) : sr->readSBML("");
  else
    return NULL;
}


LIBSBML_EXTERN
SBMLDocument_t *
SBMLReader_readSBMLFromFile (SBMLReader_t *sr, const char *filename)
{
  if (sr != NULL)
    return (filename != NULL) ? sr->readSBML(filename) : sr->readSBML("");
  else
    return NULL;
}


LIBSBML_EXTERN
SBMLDocument_t *
SBMLReader_readSBMLFromString (SBMLReader_t *sr, const char *xml)
{
  if (sr != NULL)
    return (xml != NULL) ? sr->readSBMLFromString(xml) :
                         sr->readSBMLFromString("");
  else
    return NULL;
}


LIBSBML_EXTERN
int
SBMLReader_hasZlib (void)
{
  return static_cast<int>( SBMLReader::hasZlib() );
}


LIBSBML_EXTERN
int
SBMLReader_hasBzip2 (void)
{
  return static_cast<int>( SBMLReader::hasBzip2() );
}


LIBSBML_EXTERN
SBMLDocument_t *
readSBML (const char *filename)
{
  SBMLReader sr;
  return (filename != NULL) ? sr.readSBML(filename) : sr.readSBML("");
}


LIBSBML_EXTERN
SBMLDocument_t *
readSBMLFromFile (const char *filename)
{
  SBMLReader sr;
  return (filename != NULL) ? sr.readSBML(filename) : sr.readSBML("");
}


LIBSBML_EXTERN
SBMLDocument_t *
readSBMLFromString (const char *xml)
{
  SBMLReader sr;
  return (xml != NULL) ? sr.readSBMLFromString(xml) : sr.readSBMLFromString("");
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

