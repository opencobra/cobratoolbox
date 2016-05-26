function [valid, message] = isSBML_Priority(varargin)
% [valid, message] = isSBML_Priority(SBMLPriority, level, version(optional))
%
% Takes
%
% 1. SBMLPriority, an SBML Priority structure
% 2. level, an integer representing an SBML level
% 3. version (optional), an integer representing an SBML version
%
% Returns
%
% 1. valid = 
%   - 1, if the structure represents
%        a MATLAB_SBML Priority structure of the appropriate
%        level and version
%   - 0, otherwise
% 2. a message explaining any failure
%
% *NOTE:* the optional version defaults to a value of 1
%
% *NOTE:* The fields present in a MATLAB_SBML Priority structure of the appropriate
% level and version can be found using getPriorityFieldnames(level, version)

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




%check the input arguments are appropriate

if (nargin < 2 || nargin > 3)
	error('wrong number of input arguments');
end;

SBMLStructure = varargin{1};

if (length(SBMLStructure) > 1)
  valid = 0;
  message = 'cannot deal with arrays of structures';
  return;
end;

level = varargin{2};

if (nargin == 3)
	version = varargin{3};
else
	version = 1;
end;

isValidLevelVersionCombination(level, version);

message = '';

% check that argument is a structure
valid = isstruct(SBMLStructure);

% check the typecode
typecode = 'SBML_PRIORITY';
if (valid == 1 && ~isempty(SBMLStructure))
  if isfield(SBMLStructure, 'typecode')
    if (strcmp(typecode, SBMLStructure.typecode) ~= 1)
      valid = 0;
      message = 'typecode mismatch';
      return;
    end;
  else
    valid = 0;
    message = 'missing typecode field';
    return;
  end;
end;

% if the level and version fields exist they must match
if (valid == 1 && isfield(SBMLStructure, 'level') && ~isempty(SBMLStructure))
	if ~isequal(level, SBMLStructure.level)
		valid = 0;
		message = 'level mismatch';
	end;
end;
if (valid == 1 && isfield(SBMLStructure, 'version') && ~isempty(SBMLStructure))
	if ~isequal(version, SBMLStructure.version)
		valid = 0;
		message = 'version mismatch';
	end;
end;

% check that structure contains all the necessary fields
[SBMLfieldnames, numFields] = getFieldnames('SBML_PRIORITY', level, version);

if (numFields ==0)
	valid = 0;
	message = 'invalid level/version';
end;

index = 1;
while (valid == 1 && index <= numFields)
	valid = isfield(SBMLStructure, char(SBMLfieldnames(index)));
	if (valid == 0);
		message = sprintf('%s field missing', char(SBMLfieldnames(index)));
	end;
	index = index + 1;
end;

% report failure
if (valid == 0)
	message = sprintf('Invalid Priority\n%s\n', message);
end;
