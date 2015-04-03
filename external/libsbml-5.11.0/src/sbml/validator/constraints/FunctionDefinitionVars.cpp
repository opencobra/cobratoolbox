/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    FunctionDefinitionVars.cpp
 * @brief   Ensures FunctionDefinitions contain no undefined variables.
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

#include <sbml/Model.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/util/List.h>
#include <sbml/math/ASTNode.h>

#include "FunctionDefinitionVars.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new Constraint with the given @p id.
 */
FunctionDefinitionVars::FunctionDefinitionVars (unsigned int id, Validator& v) :
  TConstraint<FunctionDefinition>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
FunctionDefinitionVars::~FunctionDefinitionVars ()
{
}


/*
 * Checks that all variables referenced in FunctionDefinition bodies are
 * bound variables (function arguments).
 */
void
FunctionDefinitionVars::check_ (const Model& m, const FunctionDefinition& fd)
{
  if ( fd.getLevel() == 1         ) return;
  if ( !fd.isSetMath()            ) return;
  if ( fd.getBody()  == NULL      ) return;
  //if (  fd.getNumArguments() == 0 ) return;


  List* variables = fd.getBody()->getListOfNodes( ASTNode_isName );


  for (unsigned int n = 0; n < variables->getSize(); ++n)
  {
    ASTNode* node = static_cast<ASTNode*>( variables->get(n) );
    string   name = node->getName() ? node->getName() : "";

    if ( fd.getArgument(name) == NULL ) 
    {
      /* if this is the csymbol time - technically it is allowed 
       * in L2v1 and L2v2
       */
      if (node->getType() == AST_NAME_TIME)
      {
        if (fd.getLevel() > 2
          || (fd.getLevel() == 2 && fd.getVersion() > 2))
        {
          logUndefined(fd, name);
        }
      }
      else
      {
        logUndefined(fd, name);
      }
    }
  }
  
  delete variables;
}


/*
 * Logs a message about an undefined variable in the given
 * FunctionDefinition.
 */
void
FunctionDefinitionVars::logUndefined ( const FunctionDefinition& fd,
                                       const string& varname )
{
  msg =
  msg =
    //"Inside the 'lambda' of a <functionDefinition>, if a 'ci' element is not "
    //"the first element within a MathML 'apply', then the 'ci''s value can "
    //"only be the value of a 'bvar' element declared in that 'lambda'. In "
    //"other words, all model entities referenced inside a function definition "
    //"must be passed arguments to that function. (References: L2V2 Section "
    //"4.3.2.)" 
    "The variable '";

  msg += varname;
  msg += "' is not listed as a <bvar> of FunctionDefinition '";
  msg += fd.getId();
  msg += "'.";
  
  logFailure(fd);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
