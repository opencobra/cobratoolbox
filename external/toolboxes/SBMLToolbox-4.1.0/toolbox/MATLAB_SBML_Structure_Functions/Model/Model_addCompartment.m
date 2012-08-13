function SBMLModel = Model_addCompartment(SBMLModel, SBMLCompartment)
% SBMLModel = Model_addCompartment(SBMLModel, SBMLCompartment)
%
% Takes
%
% 1. SBMLModel, an SBML Model structure
% 2. SBMLCompartment, an SBML Compartment structure
%
% Returns
%
% 1. the SBML Model structure with the SBML Compartment structure added
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
[compartment_level, compartment_version] = GetLevelVersion(SBMLCompartment);

if level ~= compartment_level
	error('mismatch in levels');
elseif version ~= compartment_version
	error('mismatch in versions');
end;

if isfield(SBMLModel, 'compartment')
	index = length(SBMLModel.compartment);
	if index == 0
		SBMLModel.compartment = SBMLCompartment;
	else
    if ~isfield(SBMLModel.compartment(1), 'level')
      SBMLModel = propagateLevelVersion(SBMLModel);
    end;
		SBMLModel.compartment(index+1) = SBMLCompartment;
	end;
else
	error('compartment not an element on SBML L%dV%d Model', level, version);
end;

