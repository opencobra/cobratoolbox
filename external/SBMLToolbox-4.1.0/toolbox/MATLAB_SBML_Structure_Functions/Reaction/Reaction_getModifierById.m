function modifier = Reaction_getModifierById(SBMLReaction, id)
% modifier = Reaction_getModifierById(SBMLReaction, id)
%
% Takes
%
% 1. SBMLReaction, an SBML Reaction structure
% 2. id; a string representing the id of SBML Modifier structure
%
% Returns
%
% 1. the SBML Modifier structure that has this id
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







% check that input is correct
if (~isstruct(SBMLReaction))
  error(sprintf('%s', ...
    'first argument must be an SBML Reaction structure'));
end;
 
[sbmlLevel, sbmlVersion] = GetLevelVersion(SBMLReaction);

if (~isSBML_Reaction(SBMLReaction, sbmlLevel, sbmlVersion))
    error(sprintf('%s\n%s', 'Reaction_getModifierById(SBMLReaction, id)', 'first argument must be an SBML model structure'));
elseif (~ischar(id))
    error(sprintf('%s\n%s', 'Reaction_getModifierById(SBMLReaction, id)', 'second argument must be a string'));
elseif (sbmlLevel ~= 2)
    error(sprintf('%s\n%s', 'Reaction_getModifierById(SBMLReaction, id)', 'no id or modifier field in a level 1 model'));   
end;

modifier = [];

for i = 1:length(SBMLReaction.modifier)
    if (strcmp(id, SBMLReaction.modifier(i).species))
        modifier = SBMLReaction.modifier(i);
        return;
    end;
end;
