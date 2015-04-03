/**
 * \file   TestFile.h
 * \brief  Enscapsulates an XML file in the test-data/ directory
 * \author Ben Bornstein
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

#ifndef TestFile_h
#define TestFile_h


#ifdef __cplusplus


#include <set>
#include <string>
#include <sbml/common/libsbml-namespace.h>


/**
 * TestFiles (e.g. in the test-data/ directory) have the following naming
 * convention:
 *
 *   cccc-pass-00-nn.xml, or
 *   cccc-fail-ff-nn.xml
 *
 * Where:
 *
 *   cccc  is the four digit constraint id the file is designed to test
 *
 *   pass  indicates the file must pass validation without error
 *
 *   fail  indicates the file must fail validation with extactly ff errors
 *         all with constraint id cccc.
 *
 *   nn    is the sequence id (to allow multiple test files per constraint).
 */
class TestFile
{
public:

  const std::string& getFilename  () const { return mFilename;  }
  const std::string& getDirectory () const { return mDirectory; }
  
  std::string getFullname () const;

  unsigned int  getConstraintId     () const;
  unsigned int  getNumFailures      () const;
  unsigned int  getSequenceId       () const;
  unsigned int  getAdditionalFailId () const;

  /**
   * @return the set of TestFiles in the given directory.
   *
   * You may optionally limit to the TestFiles returned to only those with
   * ConstraintIds in the range [begin, end] (if begin == end == 0, all
   * TestFiles in the given directory will be returned).
   */
  static std::set<TestFile> getFilesIn ( const std::string& directory,
                                         unsigned int begin = 0,
                                         unsigned int end   = 0, 
                                         unsigned int library = 0);

  /**
   * Sort (and test equality) by filename.
   */
  bool operator < (const TestFile& rhs) const
  {
    return mFilename < rhs.mFilename;
  }


private:

  /**
   * Creates a new TestFile based on filename.
   */
  TestFile (const std::string& directory, const std::string& filename) :
    mDirectory(directory), mFilename(filename) { }

  /**
   * @return true if filename adheres to the TestFile naming convention,
   * false otherwise.
   */
  static bool isValid (const std::string& filename);


  std::string mDirectory;
  std::string mFilename;
};


#endif  /* __cplusplus */
#endif  /* TestFile_h  */

