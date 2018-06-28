function sbmlStruct = getSBMLDefaultStruct(varargin)
%  structure = getSBMLDefaultStruct(element_name, level, version, 
%                                                          packages (optional), packageVersion (optional))
% 
% Takes
%
% 1. element_name - the name of the SBML element whose structure is wanted
% 2. level - an integer for the value of the level field to be added
% 3. version - an integer for the value of the version field to be added
% 4. packages, cell array of package names
% 5. packageVersion, an integer array representing the SBML package versions 
%
% Returns
%
% 1. structure - the original structure with additional fields 'level' and
%                           'version' added to this and every child
%                           structure
%

%  Thanks to Thomas Pfau for providing this function.

%<!---------------------------------------------------------------------------
% This file is part of libSBML.  Please visit http://sbml.org for more
% information about SBML, and the latest version of libSBML.
%
% Copyright (C) 2013-2017 jointly by the following organizations:
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

pkgCount = 0;

if (nargin < 3)
    error('not enough input arguments');
else
    element_name = varargin{1};
    level = varargin{2};
    version = varargin{3};
end;
packages = {};
packageVersion = 1;
if (nargin > 3)
    if (nargin < 5)
        error('not enough input arguments');
    end;
    pkgCount = length(varargin{4});
    packages = varargin{4};
    if (length(varargin{5}) ~= pkgCount)
        error('need a version number for each package');
    end;            
    packageVersion = varargin{5};
end;

fieldData = [getStructureFieldnames(element_name, level, version, ...
packages, packageVersion) ; getDefaultValues(element_name, level, ...
version, packages, packageVersion)];

if ~isempty(fieldData)
    fieldData = reshape(fieldData,numel(fieldData),1);
    sbmlStruct = struct(fieldData{:});
else
    sbmlStruct = struct();
end;
end