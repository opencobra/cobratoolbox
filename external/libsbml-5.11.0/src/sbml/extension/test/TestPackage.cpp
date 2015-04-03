/**
 * \file    TestPackage.cpp
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

#ifdef __cplusplus 

#include <sbml/extension/SBMLExtensionRegister.h>
#include <sbml/extension/SBMLExtensionRegistry.h>
#include <sbml/extension/SBasePluginCreator.h>
#include <sbml/extension/SBMLDocumentPlugin.h>
#include <iostream>

#include "TestPackage.h"

LIBSBML_CPP_NAMESPACE_USE

const std::string& TestExtension::getPackageName ()
{
	static const std::string pkgName = "test";
	return pkgName;
}

unsigned int TestExtension::getDefaultLevel()
{
	return 3;
}  

unsigned int TestExtension::getDefaultVersion()
{
	return 1; 
}

unsigned int TestExtension::getDefaultPackageVersion()
{
	return 1;
} 

const std::string& TestExtension::getXmlnsL3V1V1  ()
{
	static const std::string xmlns = "http://www.sbml.org/sbml/level3/version1/test/version1";
	return xmlns;
}

static SBMLExtensionRegister<TestExtension> groupsExtensionRegistry;


static
	const char* SBML_GROUPS_TYPECODE_STRINGS[] =
{
	"Test"
};

template class SBMLExtensionNamespaces<TestExtension>;

TestExtension::TestExtension ()
{
}

TestExtension::TestExtension(const TestExtension& orig)
	: SBMLExtension(orig)
{
}

TestExtension::~TestExtension ()
{
}

TestExtension& 
	TestExtension::operator=(const TestExtension& orig)
{
	SBMLExtension::operator=(orig);
	return *this;
}


TestExtension* 
	TestExtension::clone () const
{
	return new TestExtension(*this);  
}

const std::string&
	TestExtension::getName() const
{
	return getPackageName();
}

const std::string& 
	TestExtension::getURI(unsigned int sbmlLevel, unsigned int sbmlVersion, unsigned int pkgVersion) const
{
	if (sbmlLevel == 3)
	{
		if (sbmlVersion == 1)
		{
			if (pkgVersion == 1)
			{
				return getXmlnsL3V1V1();
			}
		}
	}

	static std::string empty = "";

	return empty;
}

unsigned int 
	TestExtension::getLevel(const std::string &uri) const
{
	if (uri == getXmlnsL3V1V1())
	{
		return 3;
	}

	return 0;
}

unsigned int 
	TestExtension::getVersion(const std::string &uri) const
{
	if (uri == getXmlnsL3V1V1())
	{
		return 1;
	}

	return 0;
}

unsigned int
	TestExtension::getPackageVersion(const std::string &uri) const
{
	if (uri == getXmlnsL3V1V1())
	{
		return 1;
	}

	return 0;
}

SBMLNamespaces*
	TestExtension::getSBMLExtensionNamespaces(const std::string &uri) const
{
	TestPkgNamespaces* pkgns = NULL;
	if ( uri == getXmlnsL3V1V1())
	{
		pkgns = new TestPkgNamespaces(3,1,1);    
	}  
	return pkgns;
}

const char* 
	TestExtension::getStringFromTypeCode(int typeCode) const
{
	int min = SBML_TEST_TEST;
	int max = SBML_TEST_TEST;

	if ( typeCode < min || typeCode > max)
	{
		return "(Unknown SBML Groups Type)";  
	}

	return SBML_GROUPS_TYPECODE_STRINGS[typeCode - min];
}


void 
	TestExtension::init()
{
	if (SBMLExtensionRegistry::getInstance().isRegistered(getPackageName()))
	{
		return;
	}

	TestExtension testExtension;

	std::vector<std::string> packageURIs;
	packageURIs.push_back(getXmlnsL3V1V1());

	SBaseExtensionPoint sbmldocExtPoint("core",SBML_DOCUMENT);
	SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);

	SBasePluginCreator<SBMLDocumentPlugin, TestExtension> sbmldocPluginCreator(sbmldocExtPoint,packageURIs);
	SBasePluginCreator<TestModelPlugin,   TestExtension> modelPluginCreator(modelExtPoint,packageURIs);

	testExtension.addSBasePluginCreator(&sbmldocPluginCreator);
	testExtension.addSBasePluginCreator(&modelPluginCreator);

	int result = SBMLExtensionRegistry::getInstance().addExtension(&testExtension);

	if (result != LIBSBML_OPERATION_SUCCESS)
	{
		std::cerr << "[Error] TestExtension::init() failed." << std::endl;
	}
}


TestModelPlugin::TestModelPlugin (const std::string &uri, 
	const std::string &prefix,
	TestPkgNamespaces *groupsns)
	: SBasePlugin(uri,prefix, groupsns)
  , mValue()
{
}

TestModelPlugin::TestModelPlugin(const TestModelPlugin& orig)
	: SBasePlugin(orig)
  , mValue(orig.mValue)
{
}

TestModelPlugin::~TestModelPlugin () {}

TestModelPlugin& 
	TestModelPlugin::operator=(const TestModelPlugin& orig)
{
	if(&orig!=this)
	{
    this->mValue = orig.mValue;
		this->SBasePlugin::operator =(orig);
	}    
	return *this;
}

TestModelPlugin* 
	TestModelPlugin::clone () const
{
	return new TestModelPlugin(*this);  
}

const std::string& 
TestModelPlugin::getValue() const
{
  return mValue;
}
void 
TestModelPlugin::setValue(const std::string& value)
{
  mValue = value;
}


SBase*
	TestModelPlugin::createObject(XMLInputStream& stream)
{
	SBase*        object = NULL;

	const std::string&   name   = stream.peek().getName();
	const XMLNamespaces& xmlns  = stream.peek().getNamespaces();
	const std::string&   prefix = stream.peek().getPrefix();

	const std::string& targetPrefix = (xmlns.hasURI(mURI)) ? xmlns.getPrefix(mURI) : mPrefix;

	if (prefix == targetPrefix)
	{
		if ( name == "Test" ) 
		{
			// adding object later on
		}
	}
    return object;
}

void
TestModelPlugin::writeElements (XMLOutputStream& stream) const
{
}

bool
TestModelPlugin::hasRequiredElements() const
{
  bool allPresent = true;
  return allPresent ;
}


void 
TestModelPlugin::setSBMLDocument (SBMLDocument* d)
{
  SBasePlugin::setSBMLDocument(d);
}

void
TestModelPlugin::connectToParent (SBase* sbase)
{
  SBasePlugin::connectToParent(sbase);
}

void
TestModelPlugin::enablePackageInternal(const std::string& pkgURI,
                                        const std::string& pkgPrefix, bool flag)
{
 
}


#endif //__cplusplus 
