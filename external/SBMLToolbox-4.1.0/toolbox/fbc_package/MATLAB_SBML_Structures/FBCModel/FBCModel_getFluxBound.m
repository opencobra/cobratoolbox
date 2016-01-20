function fluxBound = FBCModel_getFluxBound(SBMLFBCModel, index)
% fluxBound = FBCModel_getFluxBound(SBMLFBCModel, index)
%
% Takes
%
% 1. SBMLFBCModel, an SBML FBCModel structure
% 2. index, an integer representing the index of SBML FluxBound structure
%
% Returns
%
% 1. the SBML FluxBound structure at the indexed position
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

[level, version] = GetLevelVersion(SBMLFBCModel);

if isfield(SBMLFBCModel, 'fbc_fluxBound')
	if (~isIntegralNumber(index) || index <= 0)
		error('index must be a positive integer');
	elseif index <= length(SBMLFBCModel.fbc_fluxBound)
		fluxBound = SBMLFBCModel.fbc_fluxBound;
	else
		error('index is out of range');
	end;
else
	error('fluxBound not an element on SBML L%dV%d FBCModel', level, version);
end;

