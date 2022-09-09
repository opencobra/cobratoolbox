function [fieldnames, defaults, valuetypes, num] = getStructure(varargin)
% [SBMLfieldnames, nNumberFields] = getStructure(typecode, level, version, pkgversion(optional))
%
% Takes
%
% 1. typecode; a string representing the type of object being queried
% 2. level, an integer representing an SBML level
% 3. version, an integer representing an SBML version
% 4. pkgversion, an integer representing the SBML package version 
%       (defaults to 1)
%
% Returns
%
% 1. an array of fieldnames for an SBML structure of the given typecode, level and version
% 2. an array of default Values
% 3. an array of value types
% 4. the number of fieldnames
%

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
% This library is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution
% and also available online as http://sbml.org/software/libsbml/license.html
%----------------------------------------------------------------------- -->

typecode = varargin{1};
level = varargin{2};
version = varargin{3};

pkgCount = 0;

if (nargin > 3)
    if (nargin < 5)
        error('not enough arguments');
    end;
    packages = varargin{4};
    pkgVersion = varargin{5};
    [fieldnames, num] = getStructureEnum(typecode, level, version, packages, pkgVersion);
    defaults = getDefaultValues(typecode, level, version, packages, pkgVersion);
    valuetypes = getValueType(typecode, level, version, packages, pkgVersion);
else
    [fieldnames, num] = getStructureEnum(typecode, level, version);
    defaults = getDefaultValues(typecode, level, version);
    valuetypes = getValueType(typecode, level, version);
end;