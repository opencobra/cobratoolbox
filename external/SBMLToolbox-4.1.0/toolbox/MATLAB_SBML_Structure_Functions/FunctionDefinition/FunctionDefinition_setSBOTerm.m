function SBMLFunctionDefinition = FunctionDefinition_setSBOTerm(SBMLFunctionDefinition, sboTerm)
% SBMLFunctionDefinition = FunctionDefinition_setSBOTerm(SBMLFunctionDefinition, sboTerm)
%
% Takes
%
% 1. SBMLFunctionDefinition, an SBML FunctionDefinition structure
% 2. sboTerm, an integer representing the sboTerm to be set
%
% Returns
%
% 1. the SBML FunctionDefinition structure with the new value for the sboTerm attribute
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




%get level and version and check the input arguments are appropriate

[level, version] = GetLevelVersion(SBMLFunctionDefinition);

if isfield(SBMLFunctionDefinition, 'sboTerm')
	if ~isIntegralNumber(sboTerm)
		error('sboTerm must be an integer') ;
	else
		SBMLFunctionDefinition.sboTerm = sboTerm;
	end;
else
	error('sboTerm not an attribute on SBML L%dV%d FunctionDefinition', level, version);
end;

