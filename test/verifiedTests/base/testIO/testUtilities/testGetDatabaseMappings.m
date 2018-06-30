% The COBRAToolbox: testGetDatabaseMappings.m
%
% Purpose:
%     - test the getDatabaseMappings function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDatabaseMappings'));
cd(fileDir);

% test variables
field = 'met';
qualifiers = {};
refData_returnedmappings = cell(0, 6);

% function outputs
returnedmappings = getDatabaseMappings(field, qualifiers);

%We request "no" qualifiers, so we expect nothing to be returned (i.e. an empty 0,5 cell array.
assert(isequal(refData_returnedmappings, returnedmappings));
qualifiers = 'is';
returnedmappings = getDatabaseMappings(field, qualifiers);
%We request is, so we should get only 'is'
assert(size(returnedmappings,1) > 0);
assert(all(cellfun(@(x) isequal('is',x), returnedmappings(:,2))));

field = 'rxn';
%Lets request everything for rxns
returnedmappings = getDatabaseMappings(field);
%We know that e.g. kegg.reaction is part of the mapped fields.
keggpos = ismember(returnedmappings(:,1),'kegg');
isqualifiers = cellfun(@(x) strcmp('is',x), returnedmappings(:,2));
assert(any(keggpos));

%Now, we can savely assume, that rxnKEGGID should be the target of a 'is' qualifier for kegg. 
assert(isequal(returnedmappings{keggpos & isqualifiers,3},'rxnKEGGID'));


% change to old directory
cd(currentDir);
