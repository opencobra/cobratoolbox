/**
 * @file    local-doc-extras.i
 * @brief   Python-specific SWIG directives for documentation purposes
 * @author  Michael Hucka
 *
 *<!---------------------------------------------------------------------------
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
 *----------------------------------------------------------------------- -->*/

/**
 * SWIG generates __init__() methods for classes that have no explicit
 * constructors.  E.g., it creates Rule::__init(Rule self, Rule orig)__. This
 * results in Doxygen listing the methods, but Doxygen puts them in a section
 * called "Functions" on our page "Core libSBML" in the API manual, and this
 * is confusing.  Since these don't have explicit constructors anyway, the
 * least-evil approach to stop Doxygen from doing that is to mark them as
 * internal.
 */

%feature("docstring") Rule::Rule "
@internal
";


%feature("docstring") SBO::SBO "
@internal
";


%feature("docstring") SyntaxChecker::SyntaxChecker "
@internal
";


%feature("docstring") XMLErrorLog::XMLErrorLog "
@internal
";


%feature("docstring") SBMLErrorLog::SBMLErrorLog "
@internal
";


%feature("docstring") RDFAnnotationParser::RDFAnnotationParser "
@internal
";
