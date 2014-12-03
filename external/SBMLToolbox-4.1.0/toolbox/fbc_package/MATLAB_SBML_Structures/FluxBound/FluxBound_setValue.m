function SBMLFluxBound = FluxBound_setValue(SBMLFluxBound, value)
% SBMLFluxBound = FluxBound_setValue(SBMLFluxBound, value)
%
% Takes
%
% 1. SBMLFluxBound, an SBML FluxBound structure
% 2. value, a number representing the fbc_value to be set
%
% Returns
%
% 1. the SBML FBC FluxBound structure with the new value for the fbc_value attribute
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

[level, version] = GetLevelVersion(SBMLFluxBound);

if isfield(SBMLFluxBound, 'fbc_value')
	if ~isnumeric(value)
		error('value must be numeric') ;
	else
		SBMLFluxBound.fbc_value = value;
		SBMLFluxBound.isSetfbc_value = 1;
	end;
else
	error('value not an attribute on SBML L%dV%d FluxBound', level, version);
end;

