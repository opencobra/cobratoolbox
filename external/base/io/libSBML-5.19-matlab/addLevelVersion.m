function structure = addLevelVersion(structure, level, version)
%  structure = addLevelVersion(structure, level, version)
% 
% this function is used internally by TranslateSBML
%
% Takes
%
% 1. structure - any MATLAB_SBML structure
% 2. level - an integer for the value of the level field to be added
% 3. version - an integer for the value of the version field to be added
%
% Returns
%
% 1. structure - the original structure with additional fields 'level' and
%                           'version' added to this and every child
%                           structure
%
% Note:
%             The structure must contain a 'typecode' field

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

if ~isfield(structure, 'typecode')
    return;
end;
if length(structure) ~= 1 ||strcmp(structure.typecode, 'SBML_MODEL') ~= 1
    structure = addData(structure, level, version);
end;
for i = 1:length(structure)
    f = fieldnames(structure(i));
    for j = 1:length(f)
        if isstruct(structure(i).(f{j}))
            substr = structure(i).(f{j});
            structure(i).(f{j}) = addLevelVersion(substr, level, version);
        end;
    end;
end;


function str = addData(str, l, v)
f = fieldnames(str);
if sum(ismember(f, 'level')) > 0
    return;
end;
for i=1:length(str)
    str(i).level = l;
    str(i).version = v;
end;