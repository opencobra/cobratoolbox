% toolbox\MATLAB_SBML_Structure_Functions\StoichiometryMath
%
% The functions allow users to create and work with the SBML StoichiometryMath structure.
%
%===================================================================================
% StoichiometryMath = StoichiometryMath_create(level(optional), version(optional) )
%===================================================================================
% Takes
% 1. level, an integer representing an SBML level (optional)
% 2. version, an integer representing an SBML version (optional)
% Returns
% 1. a MATLAB_SBML StoichiometryMath structure of the appropriate level and version
%
%=========================================================
% math = StoichiometryMath_getMath(SBMLStoichiometryMath)
%=========================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. the value of the math attribute
%
%=============================================================
% metaid = StoichiometryMath_getMetaid(SBMLStoichiometryMath)
%=============================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. the value of the metaid attribute
%
%===============================================================
% sboTerm = StoichiometryMath_getSBOTerm(SBMLStoichiometryMath)
%===============================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. the value of the sboTerm attribute
%
%============================================================
% value = StoichiometryMath_isSetMath(SBMLStoichiometryMath)
%============================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. value = 
%  - 1 if the math attribute is set
%  - 0 otherwise
%
%==============================================================
% value = StoichiometryMath_isSetMetaid(SBMLStoichiometryMath)
%==============================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. value = 
%  - 1 if the metaid attribute is set
%  - 0 otherwise
%
%===============================================================
% value = StoichiometryMath_isSetSBOTerm(SBMLStoichiometryMath)
%===============================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. value = 
%  - 1 if the sboTerm attribute is set
%  - 0 otherwise
%
%================================================================================
% SBMLStoichiometryMath = StoichiometryMath_setMath(SBMLStoichiometryMath, math)
%================================================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% 2. math; string representing the math expression math to be set
% Returns
% 1. the SBML StoichiometryMath structure with the new value for the math attribute
%
%====================================================================================
% SBMLStoichiometryMath = StoichiometryMath_setMetaid(SBMLStoichiometryMath, metaid)
%====================================================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% 2. metaid; a string representing the metaid to be set
% Returns
% 1. the SBML StoichiometryMath structure with the new value for the metaid attribute
%
%======================================================================================
% SBMLStoichiometryMath = StoichiometryMath_setSBOTerm(SBMLStoichiometryMath, sboTerm)
%======================================================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% 2. sboTerm, an integer representing the sboTerm to be set
% Returns
% 1. the SBML StoichiometryMath structure with the new value for the sboTerm attribute
%
%============================================================================
% SBMLStoichiometryMath = StoichiometryMath_unsetMath(SBMLStoichiometryMath)
%============================================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. the SBML StoichiometryMath structure with the math attribute unset
%
%==============================================================================
% SBMLStoichiometryMath = StoichiometryMath_unsetMetaid(SBMLStoichiometryMath)
%==============================================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. the SBML StoichiometryMath structure with the metaid attribute unset
%
%===============================================================================
% SBMLStoichiometryMath = StoichiometryMath_unsetSBOTerm(SBMLStoichiometryMath)
%===============================================================================
% Takes
% 1. SBMLStoichiometryMath, an SBML StoichiometryMath structure
% Returns
% 1. the SBML StoichiometryMath structure with the sboTerm attribute unset
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


