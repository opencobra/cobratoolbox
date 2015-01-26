function SBMLReaction = Reaction_createReactant(SBMLReaction)
% SBMLReaction = Reaction_createReactant(SBMLReaction)
%
% Takes
%
% 1. SBMLReaction, an SBML Reaction structure
%
% Returns
%
% 1. the SBML Reaction structure with a new SBML SpeciesReference structure added
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

[level, version] = GetLevelVersion(SBMLReaction);

if isfield(SBMLReaction, 'reactant')
	index = length(SBMLReaction.reactant);
  SBMLReactant = SpeciesReference_create(level, version);
	if index == 0
		SBMLReaction.reactant = SBMLReactant;
	else
		SBMLReaction.reactant(index+1) = SBMLReactant;
	end;
else
	error('reactant not an element on SBML L%dV%d Reaction', level, version);
end;

