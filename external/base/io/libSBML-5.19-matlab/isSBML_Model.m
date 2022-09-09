function [valid, message] = isSBML_Model(varargin)
% [valid, message] = isSBML_Model(SBMLModel)
%
% Takes
%
% 1. SBMLModel, an SBML Model structure
% 2. extensions_allowed (optional) =
%   - 0, structures should contain ONLY required fields
%   - 1, structures may contain additional fields (default)
%3. applyUserValidation (optional) = 
%   - 0, no further validation (default)
%   - 1, run the applyUserValidation function as part of validation
%
% Returns
%
% 1. valid = 
%   - 1, if the structure represents
%        a MATLAB_SBML Model structure of the appropriate
%        level and version
%   - 0, otherwise
% 2. a message explaining any failure
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
% This library is free software; you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as
% published by the Free Software Foundation.  A copy of the license
% agreement is provided in the file named "LICENSE.txt" included with
% this software distribution and also available online as
% http://sbml.org/software/libsbml/license.html
%----------------------------------------------------------------------- -->

supported = {'fbc'};

%check the input arguments are appropriate
if (nargin < 1)
  error('isSBML_Model needs at least one argument');
elseif (nargin == 1)
  SBMLStructure = varargin{1};
  extensions_allowed = 1;
  userValidation = 0;
elseif (nargin == 2)
  SBMLStructure = varargin{1};
  extensions_allowed = varargin{2};
  userValidation = 0;
elseif (nargin == 3)
  SBMLStructure = varargin{1};
  extensions_allowed = varargin{2};
  userValidation = varargin{3};
else
  error('too many arguments to isSBML_Model');
end;
     
if ~isempty(SBMLStructure)
  if isfield(SBMLStructure, 'SBML_level') && ~isempty(SBMLStructure.SBML_level)
    level = SBMLStructure.SBML_level;
  else
    level = 3;
  end;
  if isfield(SBMLStructure, 'SBML_version') && ~isempty(SBMLStructure.SBML_version)
    version = SBMLStructure.SBML_version;
  else
    version = 1;
  end;
else
  level = 3;
  version = 1;
end;

pkgCount = 0;

num = length(supported);
packages = cell(1, num);
pkgVersion = zeros(1, num);

valid = 1;
% identify packages
for i=1:length(supported)
    vers = strcat(supported{i}, '_version');
    if isfield(SBMLStructure, vers)
        if isempty(SBMLStructure.(vers))
          valid = 0;
          message = sprintf('Missing %s value', vers);
        else
            pkgCount = pkgCount + 1;
            packages{pkgCount} = supported{i};
            pkgVersion(pkgCount) = SBMLStructure.(vers);
        end;
    end;
end;

if (valid == 1)
    [valid, message] = isSBML_Struct('model', SBMLStructure, level, version, packages, pkgVersion, extensions_allowed);

    if (valid == 1 && userValidation == 1)
        [valid, message] = applyUserValidation(SBMLStructure, level, version, packages, pkgVersion);
    end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [valid, message] = isSBML_Struct(typecode, SBMLStructure, level, version, packages, pkgVersion, extensions_allowed)

num = length(SBMLStructure);
if (num == 0)
  valid = 0;
  message = 'Invalid Model structure';
  return;    
elseif (num > 1)
  valid = 0;
  message = 'cannot deal with arrays of structures';
  return;
end;

isValidLevelVersionCombination(level, version);

message = '';

% check that argument is a structure
valid = isstruct(SBMLStructure);

% if the level and version fields exist they must match
if (valid == 1 && isfield(SBMLStructure, 'level') && ~isempty(SBMLStructure))
	if ~isequal(level, SBMLStructure.level)
		valid = 0;
		message = sprintf('%s level mismatch', typecode);
	end;
end;
if (valid == 1 && isfield(SBMLStructure, 'version') && ~isempty(SBMLStructure))
	if ~isequal(version, SBMLStructure.version)
		valid = 0;
		message = sprintf('%s version mismatch', typecode);
	end;
end;

if (strcmp(typecode, 'rule') == 1)
  if isfield(SBMLStructure, 'typecode')
    typecode = SBMLStructure.typecode;
  end;
end;

% check that structure contains all the necessary fields
if (isempty(typecode))
	valid = 0;
	message = sprintf('missing typecode');     
end;
if (valid == 1)
    [SBMLfieldnames, numFields] = getStructureFieldnames(typecode, level, version, packages, pkgVersion);
    if (numFields ==0)
        valid = 0;
        message = sprintf('%s invalid level/version', typecode); 
    end;

    [value_types] = getValueType(typecode, level, version, packages, pkgVersion);
    [defaults] = getDefaultValues(typecode, level, version, packages, pkgVersion);
else
    SBMLfieldnames = [];
    numFields = 0;
    [value_types] = [];
    [defaults] = [];
end;
% check the typecode
if (valid == 1 && ~isempty(SBMLStructure))
  if isfield(SBMLStructure, 'typecode')
    if (strcmp(defaults{1}, SBMLStructure.typecode) ~= 1)
        % for a association there may be differences
        if (strcmp(defaults{1}, 'SBML_FBC_ASSOCIATION') == 1)
            possible = {'SBML_FBC_GENE_PRODUCT_REF', 'SBML_FBC_AND', 'SBML_FBC_OR', 'SBML_FBC_ASSOCIATION'};
            if ~ismember(possible, SBMLStructure.typecode)
              valid = 0;
              message = sprintf('%s typecode mismatch', typecode); 
              return;
            end;
        else
          valid = 0;
          message = sprintf('%s typecode mismatch', typecode); 
          return;
        end;
    end;
  else
    valid = 0;
    message = sprintf('%s missing typecode field', typecode); 
    return;
  end;
end;

if iscell(value_types) == 0
    typecode
    SBMLfieldnames
end;

index = 1;
while (valid == 1 && index <= numFields)
    field = char(SBMLfieldnames(index));
	valid = isfield(SBMLStructure, field);
    if (strcmp(char(field), 'cvterms')==1)
        % do nothing
        valid = 1;
    elseif (valid == 0)
		message = sprintf('%s field missing', field);
    else
        mess = '';
        if (index ~= 1)
            value = getfield(SBMLStructure, field);
            if (strcmp(value_types{index}, 'structure') ~= 1)
                correctType = getCorrectType(value_types{index});
                % need to deal with matlab number value_types 
                valid = isValidType(value, correctType);
%                valid = isa(value, correctType);
            else
                for i=1:length(value)
                    if (valid == 1)
                        if (strcmp(char(field), 'namespaces') ~= 1 && strcmp(char(field), 'cvterms')~=1)
                            [valid, mess] = isSBML_Struct(field, value(i), level, version, packages, pkgVersion, extensions_allowed);
                        end;
                    end;
                end;
            end;
        end;
        if (valid == 0)
            if (isempty(mess))
                message = sprintf('%s %s field incorrect type', typecode, field);
            else
                message = sprintf('%s structure reports %s', field, mess);
            end;
        end;
    end;
	index = index + 1;
end;

if (extensions_allowed == 0)
  % check that the structure contains ONLY the expected fields
  if (valid == 1)
      % here we hack for structures that dont list level and version
      numExpected = length(fieldnames(SBMLStructure));
      if (sum(ismember(SBMLfieldnames, 'level')) == 0 && strcmp('SBML_MODEL', SBMLStructure.typecode) ~= 1) 
          numExpected = numExpected - 2;
      end;
    if (numFields ~= numExpected)
      valid = 0;
      message = sprintf('%s - Unexpected field detected', typecode);
    end;
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ctype = getCorrectType(type)

if (strcmp(type, 'bool')  == 1)
    ctype = 'int32';
elseif  (strcmp(type, 'int') == 1)
    ctype = 'int32';
elseif  (strcmp(type, 'uint') == 1)
    ctype = 'int32';
else
    ctype = type;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function valid = isValidLevelVersionCombination(level, version)

valid = 1;

if ~isIntegralNumber(level)
	error('level must be an integer');
elseif ~isIntegralNumber(version)
	error('version must be an integer');
end;

if (level < 1 || level > 3)
	error('current SBML levels are 1, 2 or 3');
end;

if (level == 1)
	if (version < 1 || version > 2)
		error('libSBML supports versions 1-2 of SBML Level 1');
	end;

elseif (level == 2)
	if (version < 1 || version > 5)
		error('libSBML supports versions 1-5 of SBML Level 2');
	end;

elseif (level == 3)
	if (version > 2)
		error('libSBML supports only versions 1 and 2 of SBML Level 3');
	end;

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function value = isIntegralNumber(number)


value = 0;

integerClasses = {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'};

% since the function isinteger does not exist in MATLAB Rel 13
% this is not used
%if (isinteger(number))
if (ismember(class(number), integerClasses))
    value = 1;
elseif (isnumeric(number))
    % if it is an integer 
    if (number == fix(number))
        value = 1;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valid = isValidType(value, correctType)
if (isempty(value))
    valid = 1;
else
    valid = isIntegralNumber(value);

    if (~valid)
        valid = isa(value, correctType);
    end;
end;

