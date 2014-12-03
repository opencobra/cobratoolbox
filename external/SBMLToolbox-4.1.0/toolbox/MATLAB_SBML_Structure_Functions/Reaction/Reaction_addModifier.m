function SBMLReaction = Reaction_addModifier(SBMLReaction, SBMLModifier)
% SBMLReaction = Reaction_addModifier(SBMLReaction, SBMLModifier)
%
% Takes
%
% 1. SBMLReaction, an SBML Reaction structure
% 2. SBMLModifier, an SBML Modifier structure
%
% Returns
%
% 1. the SBML Reaction structure with the SBML Modifier structure added
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
[modifier_level, modifier_version] = GetLevelVersion(SBMLModifier);

if level ~= modifier_level
	error('mismatch in levels');
elseif version ~= modifier_version
	error('mismatch in versions');
end;

if isfield(SBMLReaction, 'modifier')
	index = length(SBMLReaction.modifier);
	if index == 0
		SBMLReaction.modifier = SBMLModifier;
	else
		SBMLReaction.modifier(index+1) = SBMLModifier;
	end;
else
	error('modifier not an element on SBML L%dV%d Reaction', level, version);
end;

