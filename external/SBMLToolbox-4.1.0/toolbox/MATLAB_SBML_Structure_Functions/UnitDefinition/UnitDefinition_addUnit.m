function SBMLUnitDefinition = UnitDefinition_addUnit(SBMLUnitDefinition, SBMLUnit)
% SBMLUnitDefinition = UnitDefinition_addUnit(SBMLUnitDefinition, SBMLUnit)
%
% Takes
%
% 1. SBMLUnitDefinition, an SBML UnitDefinition structure
% 2. SBMLUnit, an SBML Unit structure
%
% Returns
%
% 1. the SBML UnitDefinition structure with the SBML Unit structure added
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

[level, version] = GetLevelVersion(SBMLUnitDefinition);
[unit_level, unit_version] = GetLevelVersion(SBMLUnit);

if level ~= unit_level
	error('mismatch in levels');
elseif version ~= unit_version
	error('mismatch in versions');
end;

if isfield(SBMLUnitDefinition, 'unit')
	index = length(SBMLUnitDefinition.unit);
	if index == 0
		SBMLUnitDefinition.unit = SBMLUnit;
	else
		SBMLUnitDefinition.unit(index+1) = SBMLUnit;
	end;
else
	error('unit not an element on SBML L%dV%d UnitDefinition', level, version);
end;

