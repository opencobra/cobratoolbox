% toolbox\MATLAB_SBML_Structure_Functions\AlgebraicRule
%
% The functions allow users to create and work with the SBML AlgebraicRule structure.
%
%===========================================================================
% AlgebraicRule = AlgebraicRule_create(level(optional), version(optional) )
%===========================================================================
% Takes
% 1. level, an integer representing an SBML level (optional)
% 2. version, an integer representing an SBML version (optional)
% Returns
% 1. a MATLAB_SBML AlgebraicRule structure of the appropriate level and version
%
%=======================================================
% formula = AlgebraicRule_getFormula(SBMLAlgebraicRule)
%=======================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. the value of the formula attribute
%
%=====================================================
% metaid = AlgebraicRule_getMetaid(SBMLAlgebraicRule)
%=====================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. the value of the metaid attribute
%
%=======================================================
% sboTerm = AlgebraicRule_getSBOTerm(SBMLAlgebraicRule)
%=======================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. the value of the sboTerm attribute
%
%=======================================================
% value = AlgebraicRule_isSetFormula(SBMLAlgebraicRule)
%=======================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. value = 
%  - 1 if the formula attribute is set
%  - 0 otherwise
%
%======================================================
% value = AlgebraicRule_isSetMetaid(SBMLAlgebraicRule)
%======================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. value = 
%  - 1 if the metaid attribute is set
%  - 0 otherwise
%
%=======================================================
% value = AlgebraicRule_isSetSBOTerm(SBMLAlgebraicRule)
%=======================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. value = 
%  - 1 if the sboTerm attribute is set
%  - 0 otherwise
%
%==========================================================================
% SBMLAlgebraicRule = AlgebraicRule_setFormula(SBMLAlgebraicRule, formula)
%==========================================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% 2. formula; a string representing the formula to be set
% Returns
% 1. the SBML AlgebraicRule structure with the new value for the formula attribute
%
%========================================================================
% SBMLAlgebraicRule = AlgebraicRule_setMetaid(SBMLAlgebraicRule, metaid)
%========================================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% 2. metaid; a string representing the metaid to be set
% Returns
% 1. the SBML AlgebraicRule structure with the new value for the metaid attribute
%
%==========================================================================
% SBMLAlgebraicRule = AlgebraicRule_setSBOTerm(SBMLAlgebraicRule, sboTerm)
%==========================================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% 2. sboTerm, an integer representing the sboTerm to be set
% Returns
% 1. the SBML AlgebraicRule structure with the new value for the sboTerm attribute
%
%===================================================================
% SBMLAlgebraicRule = AlgebraicRule_unsetFormula(SBMLAlgebraicRule)
%===================================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. the SBML AlgebraicRule structure with the formula attribute unset
%
%==================================================================
% SBMLAlgebraicRule = AlgebraicRule_unsetMetaid(SBMLAlgebraicRule)
%==================================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. the SBML AlgebraicRule structure with the metaid attribute unset
%
%===================================================================
% SBMLAlgebraicRule = AlgebraicRule_unsetSBOTerm(SBMLAlgebraicRule)
%===================================================================
% Takes
% 1. SBMLAlgebraicRule, an SBML AlgebraicRule structure
% Returns
% 1. the SBML AlgebraicRule structure with the sboTerm attribute unset
%


%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2009-2012 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EBML-EBI), Hinxton, UK
%
% Copyright (C) 2006-2008 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. University of Hertfordshire, Hatfield, UK
%
% Copyright (C) 2003-2005 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA 
%     2. Japan Science and Technology Agency, Japan
%     3. University of Hertfordshire, Hatfield, UK
%
% SBMLToolbox is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution.
%----------------------------------------------------------------------- -->


