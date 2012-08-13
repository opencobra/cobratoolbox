function SBMLSpecies = Species_setInitialConcentration(SBMLSpecies, initialConcentration)
% SBMLSpecies = Species_setInitialConcentration(SBMLSpecies, initialConcentration)
%
% Takes
%
% 1. SBMLSpecies, an SBML Species structure
% 2. initialConcentration; number representing the value of initialConcentration to be set
%
% Returns
%
% 1. the SBML Species structure with the new value for the initialConcentration attribute
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

if isfield(SBMLSpecies, 'initialConcentration')
	if ~isnumeric(initialConcentration)
		error('initialConcentration must be numeric') ;
	else
		SBMLSpecies.initialConcentration = initialConcentration;
    SBMLSpecies.isSetInitialConcentration = 1;
	end;
else
	error('initialConcentration not an attribute on SBML L%dV%d Species', level, version);
end;

