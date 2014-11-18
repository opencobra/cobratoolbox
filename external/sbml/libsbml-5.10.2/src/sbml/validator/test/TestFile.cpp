/**
 * \file   TestFile.cpp
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

#include <cstdlib>

#if defined(WIN32) && !defined(CYGWIN)
#  include "tps/dirent.h"
#  include "tps/dirent.c"
#else
#  include <sys/types.h>
#  include <dirent.h>
#endif  /* WIN32 */

#include <iostream>
#include <sbml/common/libsbml-config-common.h>
#include "TestFile.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */


/**
 * TestFiles (e.g. in the test-data/ directory) have the following naming
 * convention:
 *
 *   ccccc-pass-00-nn.xml, or
 *   ccccc-fail-ff-nn.xml
 *
 *   ccccc-fail-ff-nn-xxxxx.xml
 *
 * Where:
 *
 *   ccccc  is the five digit constraint id the file is designed to test
 *
 *   pass   indicates the file must pass validation without error
 *
 *   fail   indicates the file must fail validation with extactly ff errors
 *          all with constraint id ccccc.
 *
 *   nn     is the sequence id (to allow multiple test files per constraint).
 *
 *   xxxxx  is the number of an additional constraint that this test fails
 *
 *
 * Offsets within mFilename:
 *
 *           1        1
 * 012345678901234567890123456
 * ccccc-pass-00-nn.xml
 * ccccc-fail-ff-nn.xml
 * ccccc-fail-ff-nn-xxxxx.xml
 */


std::string
TestFile::getFullname () const
{
  return mDirectory + "/" + mFilename;
}


unsigned int
TestFile::getConstraintId () const
{
  return atol( mFilename.substr(0, 5).c_str() );
}


unsigned int
TestFile::getSequenceId () const
{
  return atol( mFilename.substr(14, 2).c_str() );
}


unsigned int
TestFile::getNumFailures () const
{
  unsigned num = atol( mFilename.substr(11, 2).c_str() );
  if (mFilename.length() > 20)
    return num+1;
  else
    return num;
}

unsigned int
TestFile::getAdditionalFailId () const
{
  if (mFilename.length() > 20)
    return atol( mFilename.substr(17, 5).c_str() );
  else
    return 0;

}


/**
 * @return true if filename adheres to the TestFile naming convention,
 * false otherwise.
 */
bool
TestFile::isValid (const string& filename)
{
  return ((filename.length() == 20 && filename.substr(16, 4) == ".xml")
    || (filename.length() == 26 && filename.substr(22, 4) == ".xml"));
}


/**
 * @return the set of TestFiles in the given directory.
 *
 * You may optionally limit to the TestFiles returned to only those with
 * ConstraintIds in the range [begin, end] (if begin == end == 0, all
 * TestFiles in the given directory will be returned).
 */
set<TestFile>
TestFile::getFilesIn ( const string& directory,
                       unsigned int  begin,
                       unsigned int  end,
                       unsigned int  library)
{
  DIR*           dir;
  struct dirent* entry;
  set<TestFile>  result;

  dir = opendir( directory.c_str() );

  if (dir == NULL)
  {
    cerr << "Could not obtain a list of files in directory "
         << "[" << directory << "]." << endl;
    return result;
  }

  for (entry = readdir(dir); entry != NULL; entry = readdir(dir))
  {
    string filename(entry->d_name);

    if ( TestFile::isValid(filename) )
    {
      TestFile     file(directory, filename);
      unsigned int id = file.getConstraintId();

      //// leave out the following tests dependent on parser
      //if (library == 0)
      //{
      // // xerces bug in reading multibyte chars
      //  if (id == 10309) continue;

        // libxml bug for 2.6.16 on a Mac
	// more and more we are getting systems where we hit the libxml 
	// issue with these files so rather than try and find those systems 
	// we take them out for libxml and revisit the whole issue soon
#ifdef USE_LIBXML
      // unsigned int num = file.getSequenceId();

      if (id == 1013) continue;
      if (id == 1014) continue;
#endif

      // leave out model constraints moved to units
      if (id == 20702 || id == 20616
        || id == 20511 || id == 20512 || id == 20513
        || id == 20518)
        continue;
      //}
#ifdef LIBSBML_USE_LEGACY_MATH

      /* some files got renumbered with the change in ast code
       * only because they logged only one error instead
       * of previously logging two
       *
       * take these out of the test if the legacy math is used
       */
      unsigned int num = file.getSequenceId();
      if (id == 99224) 
      {
        switch(num)
        {
        case 1:
        case 2:
        case 3:
        case 7:
          if (file.getNumFailures() > 0)
            continue;
          break;
        default:
          break;
        }
      }
      else if (id == 10201)
      {
        if (num == 7 && file.getNumFailures() > 0) 
          continue;
      }

#endif

      if ((begin == 0 && end == 0) || (id >= begin && id <= end))
      {
        result.insert( TestFile(directory, filename) );
      }
    }
  }

  closedir(dir);

  return result;
}
