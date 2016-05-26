function [valid, message] = isValidSBML_Model(SBMLStructure)
% [valid, message] = isValidSBML_Model(SBMLModel)
%
% Takes
%
% 1. SBMLModel, an SBML Model structure
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
% *NOTE:* The fields present in a MATLAB_SBML Model structure of the appropriate
% level and version can be found using getModelFieldnames(level, version)

%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2009-2011 jointly by the following organizations: 
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

if (length(SBMLStructure) > 1)
  valid = 0;
  message = 'cannot deal with arrays of structures';
  return;
end;

if ~isempty(SBMLStructure)
  if isfield(SBMLStructure, 'SBML_level')
    level = SBMLStructure.SBML_level;
  else
    level = 3;
  end;
  if isfield(SBMLStructure, 'SBML_version')
    version = SBMLStructure.SBML_version;
  else
    version = 1;
  end;
else
  level = 3;
  version = 1;
end;

isValidLevelVersionCombination(level, version);

message = '';

% check that argument is a structure
valid = isstruct(SBMLStructure);

% check the typecode
typecode = 'SBML_MODEL';
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


% check that structure contains all the necessary fields
[SBMLfieldnames, numFields] = getFieldnames('SBML_MODEL', level, version);

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

%check that any nested structures are appropriate

% functionDefinitions
if (valid == 1 && level > 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.functionDefinition))
    [valid, message] = isSBML_FunctionDefinition( ...
                                  SBMLStructure.functionDefinition(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% unitDefinitions
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.unitDefinition))
    [valid, message] = isSBML_UnitDefinition( ...
                                  SBMLStructure.unitDefinition(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% compartments
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.compartment))
    [valid, message] = isSBML_Compartment(SBMLStructure.compartment(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% species
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.species))
    [valid, message] = isSBML_Species(SBMLStructure.species(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% compartmentTypes
if (valid == 1 && level == 2 && version > 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.compartmentType))
    [valid, message] = isSBML_CompartmentType(SBMLStructure.compartmentType(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% speciesTypes
if (valid == 1 && level == 2 && version > 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.speciesType))
    [valid, message] = isSBML_SpeciesType(SBMLStructure.speciesType(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% parameter
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.parameter))
    [valid, message] = isSBML_Parameter(SBMLStructure.parameter(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% initialAssignment
if (valid == 1 && (level > 2 || (level == 2 && version > 1)))
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.initialAssignment))
    [valid, message] = isSBML_InitialAssignment( ...
                                  SBMLStructure.initialAssignment(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% rule
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.rule))
    [valid, message] = isSBML_Rule(SBMLStructure.rule(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% constraints
if (valid == 1 && (level > 2 || (level == 2 && version > 1)))
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.constraint))
    [valid, message] = isSBML_Constraint( ...
                                  SBMLStructure.constraint(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% reaction
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.reaction))
    [valid, message] = isSBML_Reaction(SBMLStructure.reaction(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% event
if (valid == 1 && level > 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.event))
    [valid, message] = isSBML_Event(SBMLStructure.event(index), ...
                                  level, version);
    index = index + 1;
  end;
end;


% report failure
if (valid == 0)
	message = sprintf('Invalid Model structure\n%s\n', message);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_AlgebraicRule(varargin)




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
typecode = 'SBML_ALGEBRAIC_RULE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_ALGEBRAIC_RULE', level, version);

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
	message = sprintf('Invalid AlgebraicRule\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_AssignmentRule(varargin)




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
typecode = 'SBML_ASSIGNMENT_RULE';
if (valid == 1 && ~isempty(SBMLStructure))
  if isfield(SBMLStructure, 'typecode')
    if (level > 1)
      if (strcmp(typecode, SBMLStructure.typecode) ~= 1)
        valid = 0;
        message = 'typecode mismatch';
        return;
      end;
    else
      % check L1 types
      typecode = SBMLStructure.typecode;
      cvr = strcmp(typecode, 'SBML_COMPARTMENT_VOLUME_RULE');
      pr = strcmp(typecode, 'SBML_PARAMETER_RULE');
      scr = strcmp(typecode, 'SBML_SPECIES_CONCENTRATION_RULE');
      if (cvr ~= 1 && pr ~= 1 && scr ~= 1)
        valid = 0;
        message = 'typecode mismatch';
        return;
      elseif (strcmp(SBMLStructure.type, 'scalar') ~= 1)
        valid = 0;
        message = 'expected scalar type';
        return;
      end;      
    end;
  else
    valid = 0;
    message = 'missing typecode';
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
[SBMLfieldnames, numFields] = getFieldnames(typecode, level, version);

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
	message = sprintf('Invalid AssignmentRule\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Compartment(varargin)




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
typecode = 'SBML_COMPARTMENT';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_COMPARTMENT', level, version);

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
	message = sprintf('Invalid Compartment\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_CompartmentType(varargin)




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
typecode = 'SBML_COMPARTMENT_TYPE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_COMPARTMENT_TYPE', level, version);

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
	message = sprintf('Invalid CompartmentType\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_CompartmentVolumeRule(varargin)




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
typecode = 'SBML_COMPARTMENT_VOLUME_RULE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_COMPARTMENT_VOLUME_RULE', level, version);

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
	message = sprintf('Invalid CompartmentVolumeRule\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Constraint(varargin)




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
typecode = 'SBML_CONSTRAINT';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_CONSTRAINT', level, version);

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
	message = sprintf('Invalid Constraint\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Delay(varargin)




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
typecode = 'SBML_DELAY';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_DELAY', level, version);

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
	message = sprintf('Invalid Delay\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Event(varargin)




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
typecode = 'SBML_EVENT';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_EVENT', level, version);

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

%check that any nested structures are appropriate

% eventAssignments
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.eventAssignment))
    [valid, message] = isSBML_EventAssignment( ...
                                  SBMLStructure.eventAssignment(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% trigger/delay/priority
% these are level and version dependent
if (valid == 1)
  if (level == 2 && version > 2)
    if (length(SBMLStructure.trigger) > 1)
      valid = 0;
      message = 'multiple trigger elements encountered';
    elseif (length(SBMLStructure.delay) > 1)
      valid = 0;
      message = 'multiple delay elements encountered';
    end;
    if (valid == 1 && length(SBMLStructure.trigger) == 1)
      [valid, message] = isSBML_Trigger(SBMLStructure.trigger, level, version);
    end;
    if (valid == 1 && length(SBMLStructure.delay) == 1)
      [valid, message] = isSBML_Delay(SBMLStructure.delay, level, version);
    end;
  elseif (level > 2)
    if (length(SBMLStructure.trigger) > 1)
      valid = 0;
      message = 'multiple trigger elements encountered';
    elseif (length(SBMLStructure.delay) > 1)
      valid = 0;
      message = 'multiple delay elements encountered';
    elseif (length(SBMLStructure.priority) > 1)
      valid = 0;
      message = 'multiple priority elements encountered';
    end;
    if (valid == 1 && length(SBMLStructure.trigger) == 1)
      [valid, message] = isSBML_Trigger(SBMLStructure.trigger, level, version);
    end;
    if (valid == 1 && length(SBMLStructure.delay) == 1)
      [valid, message] = isSBML_Delay(SBMLStructure.delay, level, version);
    end;
    if (valid == 1 && length(SBMLStructure.priority) == 1)
      [valid, message] = isSBML_Priority(SBMLStructure.priority, level, version);
    end;
  end;
end;

% report failure
if (valid == 0)
	message = sprintf('Invalid Event\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_EventAssignment(varargin)




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
typecode = 'SBML_EVENT_ASSIGNMENT';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_EVENT_ASSIGNMENT', level, version);

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
	message = sprintf('Invalid EventAssignment\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_FunctionDefinition(varargin)




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
typecode = 'SBML_FUNCTION_DEFINITION';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_FUNCTION_DEFINITION', level, version);

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
	message = sprintf('Invalid FunctionDefinition\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_InitialAssignment(varargin)




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
typecode = 'SBML_INITIAL_ASSIGNMENT';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_INITIAL_ASSIGNMENT', level, version);

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
	message = sprintf('Invalid InitialAssignment\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_KineticLaw(varargin)




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
typecode = 'SBML_KINETIC_LAW';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_KINETIC_LAW', level, version);

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

%check that any nested structures are appropriate

% parameters
if (valid == 1 && level < 3)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.parameter))
    [valid, message] = isSBML_Parameter(SBMLStructure.parameter(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

%check that any nested structures are appropriate

% localParameters
if (valid == 1 && level > 2)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.localParameter))
    [valid, message] = isSBML_LocalParameter(SBMLStructure.localParameter(index), ...
                                  level, version);
    index = index + 1;
  end;
end;


% report failure
if (valid == 0)
	message = sprintf('Invalid KineticLaw\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_LocalParameter(varargin)




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
typecode = 'SBML_LOCAL_PARAMETER';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_LOCAL_PARAMETER', level, version);

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
	message = sprintf('Invalid LocalParameter\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_ModifierSpeciesReference(varargin)




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
typecode = 'SBML_MODIFIER_SPECIES_REFERENCE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_MODIFIER_SPECIES_REFERENCE', level, version);

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
	message = sprintf('Invalid ModifierSpeciesReference\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Parameter(varargin)




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
typecode = 'SBML_PARAMETER';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_PARAMETER', level, version);

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
	message = sprintf('Invalid Parameter\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_ParameterRule(varargin)




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
typecode = 'SBML_PARAMETER_RULE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_PARAMETER_RULE', level, version);

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
	message = sprintf('Invalid ParameterRule\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Priority(varargin)




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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_RateRule(varargin)




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
typecode = 'SBML_RATE_RULE';
if (valid == 1 && ~isempty(SBMLStructure))
  if isfield(SBMLStructure, 'typecode')
    if (level > 1)
      if (strcmp(typecode, SBMLStructure.typecode) ~= 1)
        valid = 0;
        message = 'typecode mismatch';
        return;
      end;
    else
      % check L1 types
      typecode = SBMLStructure.typecode;
      cvr = strcmp(typecode, 'SBML_COMPARTMENT_VOLUME_RULE');
      pr = strcmp(typecode, 'SBML_PARAMETER_RULE');
      scr = strcmp(typecode, 'SBML_SPECIES_CONCENTRATION_RULE');
      if (cvr ~= 1 && pr ~= 1 && scr ~= 1)
        valid = 0;
        message = 'typecode mismatch';
        return;
      elseif (strcmp(SBMLStructure.type, 'rate') ~= 1)
        valid = 0;
        message = 'expected rate type';
        return;
      end;      
    end;
  else
    valid = 0;
    message = 'missing typecode';
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
[SBMLfieldnames, numFields] = getFieldnames(typecode, level, version);

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
	message = sprintf('Invalid RateRule\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Reaction(varargin)




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
typecode = 'SBML_REACTION';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_REACTION', level, version);

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

%check that any nested structures are appropriate

% reactants
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.reactant))
    [valid, message] = isSBML_SpeciesReference(SBMLStructure.reactant(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% products
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.product))
    [valid, message] = isSBML_SpeciesReference(SBMLStructure.product(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% modifiers
if (valid == 1 && level > 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.modifier))
    [valid, message] = isSBML_ModifierSpeciesReference( ...
                                  SBMLStructure.modifier(index), ...
                                  level, version);
    index = index + 1;
  end;
end;

% kineticLaw
if (valid == 1 && length(SBMLStructure.kineticLaw) == 1)
  [valid, message] = isSBML_KineticLaw(SBMLStructure.kineticLaw, level, version);
end;


% report failure
if (valid == 0)
	message = sprintf('Invalid Reaction\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Rule(varargin)




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

if ~isempty(SBMLStructure)
  if isfield(SBMLStructure, 'typecode')
    typecode = SBMLStructure.typecode;
  else
    valid = 0;
    message = 'missing typecode';
    return;
  end;
else
  typecode = 'SBML_ASSIGNMENT_RULE';
end;

switch (typecode)
  case 'SBML_ALGEBRAIC_RULE'
    [valid, message] = isSBML_AlgebraicRule(SBMLStructure, level, version);
  case 'SBML_ASSIGNMENT_RULE'
    [valid, message] = isSBML_AssignmentRule(SBMLStructure, level, version);
  case 'SBML_COMPARTMENT_VOLUME_RULE'
    [valid, message] = isSBML_CompartmentVolumeRule(SBMLStructure, level, version);
  case 'SBML_PARAMETER_RULE'
    [valid, message] = isSBML_ParameterRule(SBMLStructure, level, version);
  case 'SBML_RATE_RULE'
    [valid, message] = isSBML_RateRule(SBMLStructure, level, version);
  case 'SBML_SPECIES_CONCENTRATION_RULE'
    [valid, message] = isSBML_SpeciesConcentrationRule(SBMLStructure, level, version);
  case 'SBML_RULE'
    [valid, message] = checkRule(SBMLStructure, level, version);
  otherwise
    valid = 0;
    message = 'Incorrect rule typecode';
 end;
 

function [valid, message] = checkRule(SBMLStructure, level, version)


message = '';

% check that argument is a structure
valid = isstruct(SBMLStructure);

% check the typecode
typecode = 'SBML_RULE';
if (valid == 1 && ~isempty(SBMLStructure))
  if (strcmp(typecode, SBMLStructure.typecode) ~= 1)
    valid = 0;
    message = 'typecode mismatch';
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
[SBMLfieldnames, numFields] = getAlgebraicRuleFieldnames(level, version);

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
	message = sprintf('Invalid Rule\n%s\n', message);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Species(varargin)




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
typecode = 'SBML_SPECIES';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_SPECIES', level, version);

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
	message = sprintf('Invalid Species\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_SpeciesConcentrationRule(varargin)




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
typecode = 'SBML_SPECIES_CONCENTRATION_RULE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_SPECIES_CONCENTRATION_RULE', level, version);

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
	message = sprintf('Invalid SpeciesConcentrationRule\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_SpeciesReference(varargin)




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
typecode = 'SBML_SPECIES_REFERENCE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_SPECIES_REFERENCE', level, version);

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
	message = sprintf('Invalid SpeciesReference\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_SpeciesType(varargin)




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
typecode = 'SBML_SPECIES_TYPE';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_SPECIES_TYPE', level, version);

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
	message = sprintf('Invalid SpeciesType\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_StoichiometryMath(varargin)




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
typecode = 'SBML_STOICHIOMETRY_MATH';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_STOICHIOMETRY_MATH', level, version);

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
	message = sprintf('Invalid StoichiometryMath\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Trigger(varargin)




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
typecode = 'SBML_TRIGGER';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_TRIGGER', level, version);

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
	message = sprintf('Invalid Trigger\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_Unit(varargin)




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
typecode = 'SBML_UNIT';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_UNIT', level, version);

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
	message = sprintf('Invalid Unit\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, message] = isSBML_UnitDefinition(varargin)




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
typecode = 'SBML_UNIT_DEFINITION';
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
[SBMLfieldnames, numFields] = getFieldnames('SBML_UNIT_DEFINITION', level, version);

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

%check that any nested structures are appropriate

% unit
if (valid == 1)
  index = 1;
  while (valid == 1 && index <= length(SBMLStructure.unit))
    [valid, message] = isSBML_Unit(SBMLStructure.unit(index), ...
                                  level, version);
    index = index + 1;
  end;
end;


% report failure
if (valid == 0)
	message = sprintf('Invalid UnitDefinition\n%s\n', message);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
		error('SBMLToolbox supports versions 1-2 of SBML Level 1');
	end;

elseif (level == 2)
	if (version < 1 || version > 4)
		error('SBMLToolbox supports versions 1-4 of SBML Level 2');
	end;

elseif (level == 3)
	if (version ~= 1)
		error('SBMLToolbox supports only version 1 of SBML Level 3');
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getAlgebraicRuleFieldnames(level, ...
                                                             version)









if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'type', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getAssignmentRuleFieldnames(level, ...
                                                             version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getCompartmentFieldnames(level, ...
                                                                    version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'volume', ...
		                   'units', ...
		                   'outside', ...
		                   'isSetVolume', ...
		                 };
		nNumberFields = 8;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'spatialDimensions', ...
		                   'size', ...
		                   'units', ...
		                   'outside', ...
		                   'constant', ...
		                   'isSetSize', ...
		                   'isSetVolume', ...
		                 };
		nNumberFields = 13;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'compartmentType', ...
		                   'spatialDimensions', ...
		                   'size', ...
		                   'units', ...
		                   'outside', ...
		                   'constant', ...
		                   'isSetSize', ...
		                   'isSetVolume', ...
		                 };
		nNumberFields = 14;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'compartmentType', ...
		                   'spatialDimensions', ...
		                   'size', ...
		                   'units', ...
		                   'outside', ...
		                   'constant', ...
		                   'isSetSize', ...
		                   'isSetVolume', ...
		                 };
		nNumberFields = 15;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'compartmentType', ...
		                   'spatialDimensions', ...
		                   'size', ...
		                   'units', ...
		                   'outside', ...
		                   'constant', ...
		                   'isSetSize', ...
		                   'isSetVolume', ...
		                 };
		nNumberFields = 15;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'spatialDimensions', ...
		                   'size', ...
		                   'units', ...
		                   'constant', ...
		                   'isSetSize', ...
		                   'isSetSpatialDimensions', ...
		                 };
		nNumberFields = 13;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getCompartmentTypeFieldnames(level, ...
                                                                        version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                 };
		nNumberFields = 6;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                 };
		nNumberFields = 7;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                 };
		nNumberFields = 7;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getCompartmentVolumeRuleFieldnames(level, ...
                                                             version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'type', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 3)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 4)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getConstraintFieldnames(level, ...
                                                                   version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                   'message', ...
		                 };
		nNumberFields = 7;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                   'message', ...
		                 };
		nNumberFields = 7;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                   'message', ...
		                 };
		nNumberFields = 7;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                   'message', ...
		                 };
		nNumberFields = 7;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getDelayFieldnames(level, ...
                                                              version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getEventAssignmentFieldnames(level, ...
                                                                        version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'variable', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'variable', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'variable', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'variable', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'variable', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getEventFieldnames(level, ...
                                                              version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'trigger', ...
		                   'delay', ...
		                   'timeUnits', ...
		                   'eventAssignment', ...
		                 };
		nNumberFields = 10;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'trigger', ...
		                   'delay', ...
		                   'timeUnits', ...
		                   'sboTerm', ...
		                   'eventAssignment', ...
		                 };
		nNumberFields = 11;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'trigger', ...
		                   'delay', ...
		                   'eventAssignment', ...
		                 };
		nNumberFields = 10;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'useValuesFromTriggerTime', ...
		                   'trigger', ...
		                   'delay', ...
		                   'eventAssignment', ...
		                 };
		nNumberFields = 11;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'useValuesFromTriggerTime', ...
		                   'trigger', ...
		                   'delay', ...
		                   'priority', ...
		                   'eventAssignment', ...
		                 };
		nNumberFields = 12;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getFieldnames(typecode, ...
                                                         level, version)









done = 1;


switch (typecode)
  case {'SBML_ALGEBRAIC_RULE', 'AlgebraicRule', 'algebraicRule'}
    fhandle = str2func('getAlgebraicRuleFieldnames');
  case {'SBML_ASSIGNMENT_RULE', 'AssignmentRule', 'assignmentRule'}
    fhandle = str2func('getAssignmentRuleFieldnames');
  case {'SBML_COMPARTMENT', 'Compartment', 'compartment'}
    fhandle = str2func('getCompartmentFieldnames');
  case {'SBML_COMPARTMENT_TYPE', 'CompartmentType', 'compartmentType'}
    fhandle = str2func('getCompartmentTypeFieldnames');
  case {'SBML_COMPARTMENT_VOLUME_RULE', 'CompartmentVolumeRule', 'compartmentVolumeRule'}
    fhandle = str2func('getCompartmentVolumeRuleFieldnames');
  case {'SBML_CONSTRAINT', 'Constraint', 'constraint'}
    fhandle = str2func('getConstraintFieldnames');
  case {'SBML_DELAY', 'Delay', 'delay'}
    fhandle = str2func('getDelayFieldnames');
  case {'SBML_EVENT', 'Event', 'event'}
    fhandle = str2func('getEventFieldnames');
  case {'SBML_EVENT_ASSIGNMENT', 'EventAssignment', 'eventAssignment'}
    fhandle = str2func('getEventAssignmentFieldnames');
  case {'SBML_FUNCTION_DEFINITION', 'FunctionDefinition', 'functionDefinition'}
    fhandle = str2func('getFunctionDefinitionFieldnames');
  case {'SBML_INITIAL_ASSIGNMENT', 'InitialAssignment', 'initialAssignment'}
    fhandle = str2func('getInitialAssignmentFieldnames');
  case {'SBML_KINETIC_LAW', 'KineticLaw', 'kineticLaw'}
    fhandle = str2func('getKineticLawFieldnames');
  case {'SBML_LOCAL_PARAMETER', 'LocalParameter', 'localParameter'}
    fhandle = str2func('getLocalParameterFieldnames');
  case {'SBML_MODEL', 'Model', 'model'}
    fhandle = str2func('getModelFieldnames');
  case {'SBML_MODIFIER_SPECIES_REFERENCE', 'ModifierSpeciesReference', 'modifierSpeciesReference'}
    fhandle = str2func('getModifierSpeciesReferenceFieldnames');
  case {'SBML_PARAMETER', 'Parameter', 'parameter'}
    fhandle = str2func('getParameterFieldnames');
  case {'SBML_PARAMETER_RULE', 'ParameterRule', 'parameterRule'}
    fhandle = str2func('getParameterRuleFieldnames');
  case {'SBML_PRIORITY', 'Priority', 'priority'}
    fhandle = str2func('getPriorityFieldnames');
  case {'SBML_RATE_RULE', 'RateRule', 'ruleRule'}
    fhandle = str2func('getRateRuleFieldnames');
  case {'SBML_REACTION', 'Reaction', 'reaction'}
    fhandle = str2func('getReactionFieldnames');
  case {'SBML_SPECIES', 'Species', 'species'}
    fhandle = str2func('getSpeciesFieldnames');
  case {'SBML_SPECIES_CONCENTRATION_RULE', 'SpeciesConcentrationRule', 'speciesConcentrationRule'}
    fhandle = str2func('getSpeciesConcentrationRuleFieldnames');
  case {'SBML_SPECIES_REFERENCE', 'SpeciesReference', 'speciesReference'}
    fhandle = str2func('getSpeciesReferenceFieldnames');
  case {'SBML_SPECIES_TYPE', 'SpeciesType', 'speciesType'}
    fhandle = str2func('getSpeciesTypeFieldnames');
  case {'SBML_STOICHIOMETRY_MATH', 'StoichiometryMath', 'stoichiometryMath'}
    fhandle = str2func('getStoichiometryMathFieldnames');
  case {'SBML_TRIGGER', 'Trigger', 'trigger'}
    fhandle = str2func('getTriggerFieldnames');
  case {'SBML_UNIT', 'Unit', 'unit'}
    fhandle = str2func('getUnitFieldnames');
  case {'SBML_UNIT_DEFINITION', 'UnitDefinition', 'unitDefinition'}
    fhandle = str2func('getUnitDefinitionFieldnames');
  otherwise
    done = 0;  
end;

if done == 1
  [SBMLfieldnames, nNumberFields] = feval(fhandle, level, version);
else
  switch (typecode)
    case {'SBML_FBC_FLUXBOUND', 'FluxBound', 'fluxBound'}
      fhandle = str2func('getFluxBoundFieldnames');
    case {'SBML_FBC_FLUXOBJECTIVE', 'FluxObjective', 'fluxObjective'}
      fhandle = str2func('getFluxObjectiveFieldnames');
    case {'SBML_FBC_OBJECTIVE', 'Objective', 'objective'}
      fhandle = str2func('getObjectiveFieldnames');
    case {'SBML_FBC_MODEL', 'FBCModel'}
      fhandle = str2func('getFBCModelFieldnames');
    case {'SBML_FBC_SPECIES', 'FBCSpecies'}
      fhandle = str2func('getFBCSpeciesFieldnames');
    otherwise
      error('%s\n%s', ...
        'getFieldnames(typecode, level, version', ...
        'typecode not recognised');    
  end;
  [SBMLfieldnames, nNumberFields] = feval(fhandle, level, version, 1);
end;
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getFunctionDefinitionFieldnames(level, ...
                                                                           version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'math', ...
		                 };
		nNumberFields = 8;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'math', ...
		                 };
		nNumberFields = 8;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'math', ...
		                 };
		nNumberFields = 8;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'math', ...
		                 };
		nNumberFields = 8;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getInitialAssignmentFieldnames(level, ...
                                                                          version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'symbol', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'symbol', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'symbol', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'symbol', ...
		                   'math', ...
		                 };
		nNumberFields = 7;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getKineticLawFieldnames(level, ...
                                                                   version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'formula', ...
		                   'parameter', ...
		                   'timeUnits', ...
		                   'substanceUnits', ...
		                 };
		nNumberFields = 7;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'formula', ...
		                   'math', ...
		                   'parameter', ...
		                   'timeUnits', ...
		                   'substanceUnits', ...
		                 };
		nNumberFields = 9;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'formula', ...
		                   'math', ...
		                   'parameter', ...
		                   'sboTerm', ...
		                 };
		nNumberFields = 8;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'math', ...
		                   'parameter', ...
		                 };
		nNumberFields = 8;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'math', ...
		                   'parameter', ...
		                 };
		nNumberFields = 8;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                   'localParameter', ...
		                 };
		nNumberFields = 7;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getLocalParameterFieldnames(level, ...
                                                                       version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'value', ...
		                   'units', ...
		                   'isSetValue', ...
		                 };
		nNumberFields = 10;
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getModelFieldnames(level, ...
                                                              version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'SBML_level', ...
		                   'SBML_version', ...
		                   'name', ...
		                   'unitDefinition', ...
		                   'compartment', ...
		                   'species', ...
		                   'parameter', ...
		                   'rule', ...
		                   'reaction', ...
		                 };
		nNumberFields = 12;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'SBML_level', ...
		                   'SBML_version', ...
		                   'name', ...
		                   'id', ...
		                   'functionDefinition', ...
		                   'unitDefinition', ...
		                   'compartment', ...
		                   'species', ...
		                   'parameter', ...
		                   'rule', ...
		                   'reaction', ...
		                   'event', ...
		                 };
		nNumberFields = 16;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'SBML_level', ...
		                   'SBML_version', ...
		                   'name', ...
		                   'id', ...
		                   'sboTerm', ...
		                   'functionDefinition', ...
		                   'unitDefinition', ...
		                   'compartmentType', ...
		                   'speciesType', ...
		                   'compartment', ...
		                   'species', ...
		                   'parameter', ...
		                   'initialAssignment', ...
		                   'rule', ...
		                   'constraint', ...
		                   'reaction', ...
		                   'event', ...
		                 };
		nNumberFields = 21;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'SBML_level', ...
		                   'SBML_version', ...
		                   'name', ...
		                   'id', ...
		                   'sboTerm', ...
		                   'functionDefinition', ...
		                   'unitDefinition', ...
		                   'compartmentType', ...
		                   'speciesType', ...
		                   'compartment', ...
		                   'species', ...
		                   'parameter', ...
		                   'initialAssignment', ...
		                   'rule', ...
		                   'constraint', ...
		                   'reaction', ...
		                   'event', ...
		                 };
		nNumberFields = 21;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'SBML_level', ...
		                   'SBML_version', ...
		                   'name', ...
		                   'id', ...
		                   'sboTerm', ...
		                   'functionDefinition', ...
		                   'unitDefinition', ...
		                   'compartmentType', ...
		                   'speciesType', ...
		                   'compartment', ...
		                   'species', ...
		                   'parameter', ...
		                   'initialAssignment', ...
		                   'rule', ...
		                   'constraint', ...
		                   'reaction', ...
		                   'event', ...
		                 };
		nNumberFields = 21;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'SBML_level', ...
		                   'SBML_version', ...
		                   'name', ...
		                   'id', ...
		                   'sboTerm', ...
		                   'functionDefinition', ...
		                   'unitDefinition', ...
		                   'compartment', ...
		                   'species', ...
		                   'parameter', ...
		                   'initialAssignment', ...
		                   'rule', ...
		                   'constraint', ...
		                   'reaction', ...
		                   'event', ...
		                   'substanceUnits', ...
		                   'timeUnits', ...
		                   'lengthUnits', ...
		                   'areaUnits', ...
		                   'volumeUnits', ...
		                   'extentUnits', ...
		                   'conversionFactor', ...
		                 };
		nNumberFields = 26;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getModifierSpeciesReferenceFieldnames(level, ...
                                                                                 version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'species', ...
		                 };
		nNumberFields = 5;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                   'sboTerm', ...
		                 };
		nNumberFields = 8;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                 };
		nNumberFields = 8;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                 };
		nNumberFields = 8;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                 };
		nNumberFields = 8;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getParameterFieldnames(level, ...
                                                                  version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'value', ...
		                   'units', ...
		                   'isSetValue', ...
		                 };
		nNumberFields = 7;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'value', ...
		                   'units', ...
		                   'constant', ...
		                   'isSetValue', ...
		                 };
		nNumberFields = 10;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'value', ...
		                   'units', ...
		                   'constant', ...
		                   'sboTerm', ...
		                   'isSetValue', ...
		                 };
		nNumberFields = 11;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'value', ...
		                   'units', ...
		                   'constant', ...
		                   'isSetValue', ...
		                 };
		nNumberFields = 11;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'value', ...
		                   'units', ...
		                   'constant', ...
		                   'isSetValue', ...
		                 };
		nNumberFields = 11;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'value', ...
		                   'units', ...
		                   'constant', ...
		                   'isSetValue', ...
		                 };
		nNumberFields = 11;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getParameterRuleFieldnames(level, ...
                                                             version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'type', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 3)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 4)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getPriorityFieldnames(level, ...
                                                                 version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getRateRuleFieldnames(level, ...
                                                             version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getReactionFieldnames(level, ...
                                                                 version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'reactant', ...
		                   'product', ...
		                   'kineticLaw', ...
		                   'reversible', ...
		                   'fast', ...
		                 };
		nNumberFields = 9;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'reactant', ...
		                   'product', ...
		                   'modifier', ...
		                   'kineticLaw', ...
		                   'reversible', ...
		                   'fast', ...
		                   'isSetFast', ...
		                 };
		nNumberFields = 13;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'reactant', ...
		                   'product', ...
		                   'modifier', ...
		                   'kineticLaw', ...
		                   'reversible', ...
		                   'fast', ...
		                   'sboTerm', ...
		                   'isSetFast', ...
		                 };
		nNumberFields = 14;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'reactant', ...
		                   'product', ...
		                   'modifier', ...
		                   'kineticLaw', ...
		                   'reversible', ...
		                   'fast', ...
		                   'isSetFast', ...
		                 };
		nNumberFields = 14;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'reactant', ...
		                   'product', ...
		                   'modifier', ...
		                   'kineticLaw', ...
		                   'reversible', ...
		                   'fast', ...
		                   'isSetFast', ...
		                 };
		nNumberFields = 14;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'reactant', ...
		                   'product', ...
		                   'modifier', ...
		                   'kineticLaw', ...
		                   'reversible', ...
		                   'fast', ...
		                   'isSetFast', ...
		                   'compartment', ...
		                 };
		nNumberFields = 15;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getRuleFieldnames(level, ...
                                                             version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'type', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 11;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getSpeciesConcentrationRuleFieldnames(level, ...
                                                             version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'type', ...
		                   'formula', ...
		                   'variable', ...
		                   'species', ...
		                   'compartment', ...
		                   'name', ...
		                   'units', ...
		                 };
		nNumberFields = 10;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 3)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 4)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getSpeciesFieldnames(level, ...
                                                                version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'compartment', ...
		                   'initialAmount', ...
		                   'units', ...
		                   'boundaryCondition', ...
		                   'charge', ...
		                   'isSetInitialAmount', ...
		                   'isSetCharge', ...
		                 };
		nNumberFields = 11;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'compartment', ...
		                   'initialAmount', ...
		                   'initialConcentration', ...
		                   'substanceUnits', ...
		                   'spatialSizeUnits', ...
		                   'hasOnlySubstanceUnits', ...
		                   'boundaryCondition', ...
		                   'charge', ...
		                   'constant', ...
		                   'isSetInitialAmount', ...
		                   'isSetInitialConcentration', ...
		                   'isSetCharge', ...
		                 };
		nNumberFields = 18;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'speciesType', ...
		                   'compartment', ...
		                   'initialAmount', ...
		                   'initialConcentration', ...
		                   'substanceUnits', ...
		                   'spatialSizeUnits', ...
		                   'hasOnlySubstanceUnits', ...
		                   'boundaryCondition', ...
		                   'charge', ...
		                   'constant', ...
		                   'isSetInitialAmount', ...
		                   'isSetInitialConcentration', ...
		                   'isSetCharge', ...
		                 };
		nNumberFields = 19;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'speciesType', ...
		                   'compartment', ...
		                   'initialAmount', ...
		                   'initialConcentration', ...
		                   'substanceUnits', ...
		                   'hasOnlySubstanceUnits', ...
		                   'boundaryCondition', ...
		                   'charge', ...
		                   'constant', ...
		                   'isSetInitialAmount', ...
		                   'isSetInitialConcentration', ...
		                   'isSetCharge', ...
		                 };
		nNumberFields = 19;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'speciesType', ...
		                   'compartment', ...
		                   'initialAmount', ...
		                   'initialConcentration', ...
		                   'substanceUnits', ...
		                   'hasOnlySubstanceUnits', ...
		                   'boundaryCondition', ...
		                   'charge', ...
		                   'constant', ...
		                   'isSetInitialAmount', ...
		                   'isSetInitialConcentration', ...
		                   'isSetCharge', ...
		                 };
		nNumberFields = 19;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'compartment', ...
		                   'initialAmount', ...
		                   'initialConcentration', ...
		                   'substanceUnits', ...
		                   'hasOnlySubstanceUnits', ...
		                   'boundaryCondition', ...
		                   'constant', ...
		                   'isSetInitialAmount', ...
		                   'isSetInitialConcentration', ...
		                   'conversionFactor', ...
		                 };
		nNumberFields = 17;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getSpeciesReferenceFieldnames(level, ...
                                                                         version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'species', ...
		                   'stoichiometry', ...
		                   'denominator', ...
		                 };
		nNumberFields = 6;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'species', ...
		                   'stoichiometry', ...
		                   'denominator', ...
		                   'stoichiometryMath', ...
		                 };
		nNumberFields = 8;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                   'sboTerm', ...
		                   'stoichiometry', ...
		                   'stoichiometryMath', ...
		                 };
		nNumberFields = 10;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                   'stoichiometry', ...
		                   'stoichiometryMath', ...
		                 };
		nNumberFields = 10;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                   'stoichiometry', ...
		                   'stoichiometryMath', ...
		                 };
		nNumberFields = 10;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'species', ...
		                   'id', ...
		                   'name', ...
		                   'stoichiometry', ...
		                   'constant', ...
		                   'isSetStoichiometry', ...
		                 };
		nNumberFields = 11;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getSpeciesTypeFieldnames(level, ...
                                                                    version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                 };
		nNumberFields = 6;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                 };
		nNumberFields = 7;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                 };
		nNumberFields = 7;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getStoichiometryMathFieldnames(level, ...
                                                                          version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getTriggerFieldnames(level, ...
                                                                version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
	SBMLfieldnames = [];
	nNumberFields = 0;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 2)
		SBMLfieldnames = [];
		nNumberFields = 0;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'math', ...
		                 };
		nNumberFields = 6;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'persistent', ...
		                   'initialValue', ...
		                   'math', ...
		                 };
		nNumberFields = 8;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getUnitDefinitionFieldnames(level, ...
                                                                       version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'unit', ...
		                 };
		nNumberFields = 5;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'unit', ...
		                 };
		nNumberFields = 7;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'name', ...
		                   'id', ...
		                   'unit', ...
		                 };
		nNumberFields = 7;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'unit', ...
		                 };
		nNumberFields = 8;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'unit', ...
		                 };
		nNumberFields = 8;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'name', ...
		                   'id', ...
		                   'unit', ...
		                 };
		nNumberFields = 8;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [SBMLfieldnames, nNumberFields] = getUnitFieldnames(level, ...
                                                             version)










if (~isValidLevelVersionCombination(level, version))
  error ('invalid level/version combination');
end;

if (level == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'notes', ...
		                   'annotation', ...
		                   'kind', ...
		                   'exponent', ...
		                   'scale', ...
		                 };
		nNumberFields = 6;
elseif (level == 2)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'kind', ...
		                   'exponent', ...
		                   'scale', ...
		                   'multiplier', ...
		                   'offset', ...
		                 };
		nNumberFields = 9;
	elseif (version == 2)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'kind', ...
		                   'exponent', ...
		                   'scale', ...
		                   'multiplier', ...
		                 };
		nNumberFields = 8;
	elseif (version == 3)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'kind', ...
		                   'exponent', ...
		                   'scale', ...
		                   'multiplier', ...
		                 };
		nNumberFields = 9;
	elseif (version == 4)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'kind', ...
		                   'exponent', ...
		                   'scale', ...
		                   'multiplier', ...
		                 };
		nNumberFields = 9;
	end;
elseif (level == 3)
	if (version == 1)
		SBMLfieldnames = { 'typecode', ...
		                   'metaid', ...
		                   'notes', ...
		                   'annotation', ...
		                   'sboTerm', ...
		                   'kind', ...
		                   'exponent', ...
		                   'scale', ...
		                   'multiplier', ...
		                 };
		nNumberFields = 9;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

