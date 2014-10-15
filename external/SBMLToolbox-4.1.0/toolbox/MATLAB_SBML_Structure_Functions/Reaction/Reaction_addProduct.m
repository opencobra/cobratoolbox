function SBMLReaction = Reaction_addProduct(SBMLReaction, SBMLProduct)
% SBMLReaction = Reaction_addProduct(SBMLReaction, SBMLProduct)
%
% Takes
%
% 1. SBMLReaction, an SBML Reaction structure
% 2. SBMLProduct, an SBML Product structure
%
% Returns
%
% 1. the SBML Reaction structure with the SBML Product structure added
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
[product_level, product_version] = GetLevelVersion(SBMLProduct);

if level ~= product_level
	error('mismatch in levels');
elseif version ~= product_version
	error('mismatch in versions');
end;

if isfield(SBMLReaction, 'product')
	index = length(SBMLReaction.product);
	if index == 0
		SBMLReaction.product = SBMLProduct;
	else
		SBMLReaction.product(index+1) = SBMLProduct;
	end;
else
	error('product not an element on SBML L%dV%d Reaction', level, version);
end;

