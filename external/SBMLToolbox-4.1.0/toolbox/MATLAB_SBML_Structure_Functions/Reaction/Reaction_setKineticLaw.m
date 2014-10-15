function SBMLReaction = Reaction_setKineticLaw(SBMLReaction, kineticLaw)
% SBMLReaction = Reaction_setKineticLaw(SBMLReaction, SBMLKineticLaw)
%
% Takes
%
% 1. SBMLReaction, an SBML Reaction structure
% 2. SBMLKineticLaw, an SBML KineticLaw structure
%
% Returns
%
% 1. the SBML Reaction structure with the new value for the kineticLaw field
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
if isstruct(kineticLaw)
  [kl_level, kl_version] = GetLevelVersion(kineticLaw);

  if level ~= kl_level
    error('mismatch in levels');
  elseif version ~= kl_version
    error('mismatch in versions');
  end;
end;

if isfield(SBMLReaction, 'kineticLaw')
  if ~isValid(kineticLaw, level, version)
    error('KineticLaw must ba an SBML KineticLaw');
  else
    SBMLReaction.kineticLaw = kineticLaw;
  end;
else
	error('kineticLaw not an attribute on SBML L%dV%d Reaction', level, version);
end;

