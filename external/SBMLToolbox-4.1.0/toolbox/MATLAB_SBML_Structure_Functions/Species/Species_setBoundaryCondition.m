function SBMLSpecies = Species_setBoundaryCondition(SBMLSpecies, boundaryCondition)
% SBMLSpecies = Species_setBoundaryCondition(SBMLSpecies, boundaryCondition)
%
% Takes
%
% 1. SBMLSpecies, an SBML Species structure
% 2. boundaryCondition, an integer (0/1) representing the value of boundaryCondition to be set
%
% Returns
%
% 1. the SBML Species structure with the new value for the boundaryCondition attribute
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

[level, version] = GetLevelVersion(SBMLSpecies);

if isfield(SBMLSpecies, 'boundaryCondition')
	if (~isIntegralNumber(boundaryCondition) || boundaryCondition < 0 || boundaryCondition > 1)
		error('boundaryCondition must be an integer of value 0/1') ;
	else
		SBMLSpecies.boundaryCondition = boundaryCondition;
	end;
else
	error('boundaryCondition not an attribute on SBML L%dV%d Species', level, version);
end;

