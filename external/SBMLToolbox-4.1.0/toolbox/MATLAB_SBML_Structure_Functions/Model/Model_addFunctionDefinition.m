function SBMLModel = Model_addFunctionDefinition(SBMLModel, SBMLFunctionDefinition)
% SBMLModel = Model_addFunctionDefinition(SBMLModel, SBMLFunctionDefinition)
%
% Takes
%
% 1. SBMLModel, an SBML Model structure
% 2. SBMLFunctionDefinition, an SBML FunctionDefinition structure
%
% Returns
%
% 1. the SBML Model structure with the SBML FunctionDefinition structure added
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

[level, version] = GetLevelVersion(SBMLModel);
[functionDefinition_level, functionDefinition_version] = GetLevelVersion(SBMLFunctionDefinition);

if level ~= functionDefinition_level
	error('mismatch in levels');
elseif version ~= functionDefinition_version
	error('mismatch in versions');
end;



if isfield(SBMLModel, 'functionDefinition')
	index = length(SBMLModel.functionDefinition);
	if index == 0
		SBMLModel.functionDefinition = SBMLFunctionDefinition;
  else
    if ~isfield(SBMLModel.functionDefinition(1), 'level')
      SBMLModel = propagateLevelVersion(SBMLModel);
    end;
		SBMLModel.functionDefinition(index+1) = SBMLFunctionDefinition;
	end;
else
	error('functionDefinition not an element on SBML L%dV%d Model', level, version);
end;

