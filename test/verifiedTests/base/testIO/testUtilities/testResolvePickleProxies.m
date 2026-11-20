% The COBRAToolbox: testResolvePickleProxies.m
%
% Purpose:
%     - resolvePickleProxies replaces, recursively, the list proxies that readPythonPickle
%       builds (containers.Map objects with double keys 1, 2, ...) by column cell arrays of
%       their items in key order, inside cell arrays, scalar structures and dictionaries
%       (containers.Map objects with char keys, modified in place). Other values are returned
%       unchanged.
%     - Expected values follow from the documentation: hand-built proxies and nested
%       containers whose resolved form is written out by hand.
%
% Function under test:
%     src/base/io/utilities/resolvePickleProxies.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built containers.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testResolvePickleProxies'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a list proxy becomes a column cell array of its items in key order

% items inserted out of order: the order of the keys counts, not the order of insertion
proxy = containers.Map('KeyType', 'double', 'ValueType', 'any');
proxy(2) = 'b';
proxy(1) = 'a';
proxy(3) = 7;
assert(isequal(resolvePickleProxies(proxy), {'a'; 'b'; 7}));
% an empty proxy (empty list or set) becomes an empty column cell array
emptyProxy = containers.Map('KeyType', 'double', 'ValueType', 'any');
resolved = resolvePickleProxies(emptyProxy);
assert(iscell(resolved) && isequal(size(resolved), [0 1]));

%% nested proxies, proxies inside cell arrays and scalar structures

innerProxy = containers.Map('KeyType', 'double', 'ValueType', 'any');
innerProxy(1) = 2;
innerProxy(2) = 3;
outerProxy = containers.Map('KeyType', 'double', 'ValueType', 'any');
outerProxy(1) = 1;
outerProxy(2) = innerProxy;
assert(isequal(resolvePickleProxies(outerProxy), {1; {2; 3}}));
% cell arrays keep their shape; their elements are resolved
assert(isequal(resolvePickleProxies({innerProxy, 'x'; 5, {innerProxy}}), {{2; 3}, 'x'; 5, {{2; 3}}}));
% fields of a scalar structure are resolved
structValue = struct('pyClass', 'Custom', 'items', innerProxy);
assert(isequal(resolvePickleProxies(structValue), struct('pyClass', 'Custom', 'items', {{2; 3}})));

%% dictionaries (char keys) are resolved in place

dictionary = containers.Map({'list', 'number'}, {innerProxy, 4});
returned = resolvePickleProxies(dictionary);
% the returned dictionary is the same handle object, and the input itself was changed
assert(returned == dictionary);
assert(isequal(dictionary('list'), {2; 3}) && dictionary('number') == 4);

%% other values are returned unchanged (numbers, text, logical, empty)

assert(isequal(resolvePickleProxies(2.5), 2.5));
assert(isequal(resolvePickleProxies('text'), 'text'));
assert(isequal(resolvePickleProxies(true), true));
assert(isempty(resolvePickleProxies([])));

%% error: no input

assert(verifyCobraFunctionError('resolvePickleProxies', 'testMessage', 'value must be provided.'));

% change the directory
cd(currentDir)
