/**
 * \file    TestPackage.h
 * \brief   Mock Package for testing purposes
 * \author  Frank T. Bergmann <fbergman@caltech.edu>
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

#ifndef LIBSBML_EXTENSION_TEST_TESTPACKAGE
#define LIBSBML_EXTENSION_TEST_TESTPACKAGE

#ifdef __cplusplus

#include <sbml/common/extern.h>
#include <sbml/SBMLTypeCodes.h>

#include <sbml/SBMLErrorLog.h>
#include <sbml/Model.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/SBMLExtensionNamespaces.h>
#include <sbml/extension/SBMLExtensionRegister.h>
#include <sbml/extension/SBasePlugin.h>

#include <vector>

LIBSBML_CPP_NAMESPACE_BEGIN

class  TestExtension : public SBMLExtension
{
public:

	static const std::string& getPackageName ();
	static unsigned int getDefaultLevel();
	static unsigned int getDefaultVersion();
	static unsigned int getDefaultPackageVersion();
	static const std::string&  getXmlnsL3V1V1  () ;

	TestExtension(); 
	TestExtension(const TestExtension&);
	virtual ~TestExtension ();
	TestExtension& operator=(const TestExtension&);
	virtual TestExtension* clone () const;
	virtual const std::string& getName() const;
	
	virtual const std::string& getURI(
		unsigned int sbmlLevel, 
		unsigned int sbmlVersion, 
		unsigned int pkgVersion) const;

	virtual unsigned int getLevel(const std::string &uri) const;
	virtual unsigned int getVersion(const std::string &uri) const;
	virtual unsigned int getPackageVersion(const std::string &uri) const;
	virtual SBMLNamespaces* getSBMLExtensionNamespaces(const std::string &uri) const;
	virtual const char* getStringFromTypeCode(int typeCode) const;
	static void init();

};

typedef SBMLExtensionNamespaces<TestExtension> TestPkgNamespaces; 

typedef enum
{
   SBML_TEST_TEST  = 200
} SBMLGroupsTypeCode_t;



class TestModelPlugin : public SBasePlugin
{
public:

	  TestModelPlugin (const std::string &uri, const std::string &prefix,
                    TestPkgNamespaces *groupsns);
      TestModelPlugin(const TestModelPlugin& orig);
	  virtual ~TestModelPlugin ();
	  TestModelPlugin& operator=(const TestModelPlugin& orig);
	  virtual TestModelPlugin* clone () const;
	  virtual SBase* createObject (XMLInputStream& stream);
	  virtual void writeElements (XMLOutputStream& stream) const;
	  virtual bool hasRequiredElements() const ;

	  virtual void setSBMLDocument (SBMLDocument* d);
	  virtual void connectToParent (SBase *sbase);

	  virtual void enablePackageInternal(const std::string& pkgURI,
                                     const std::string& pkgPrefix, bool flag);

};
LIBSBML_CPP_NAMESPACE_END
#endif //__cplusplus
#endif //LIBSBML_EXTENSION_TEST_TESTPACKAGE
