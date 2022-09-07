function [valid, message] = applyUserValidation(SBMLStructure, level, version, packages, pkgVersion)
%  [valid, message] = applyUserValidation(SBMLStructure, level, version, packages, pkgVersion)
%
% a script that can be customized by the user to add additional
%   validation to the isSBML_Model function
%
% Takes
%
% 1. SBMLstructure - a MATLAB_SBML structure
% 2. level - an integer representing the SBML level
% 3. version - an integer representing the SBML version
% 4. packages - a cell array of the package prefixes used 
%                              e.g. {'fbc'}
% 5. pkgVersion - an array of integers representing the version of each
%                               package; note indexing should match the
%                               packages indexing e.g. [1] 
%
% Returns
%
% 1. valid = 
%   - 1, if the structure represents passes the tests imposed
%   - 0, otherwise
% 2. a message explaining any failure

%<!---------------------------------------------------------------------------
% This file is part of libSBML.  Please visit http://sbml.org for more
% information about SBML, and the latest version of libSBML.
%
% Copyright (C) 2013-2018 jointly by the following organizations:
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
%     3. University of Heidelberg, Heidelberg, Germany
%
% Copyright (C) 2009-2013 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
%  
% Copyright (C) 2006-2008 by the California Institute of Technology,
%     Pasadena, CA, USA 
%  
% Copyright (C) 2002-2005 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. Japan Science and Technology Agency, Japan
% 
% This library is free software; you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as
% published by the Free Software Foundation.  A copy of the license
% agreement is provided in the file named "LICENSE.txt" included with
% this software distribution and also available online as
% http://sbml.org/software/libsbml/license.html
%----------------------------------------------------------------------- -->

valid = 1;
message = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% example check that all GeneProducts listed have an id value

% if isempty(packages{1})
%     present = 0;
% else
%     [present, index] = ismember('fbc', packages);
% end;
% 
% if (present)
%     if (pkgVersion(index) == 2)
%         gp = SBMLStructure.fbc_geneProduct;
%         [a, num] = size(gp);
%         for i=1:num
%             if (isempty(gp(num).fbc_id))
%                 valid = 0;
%                 message = 'geneProduct is missing the id attribute';
%             end;
%         end;
%     end;
% end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
