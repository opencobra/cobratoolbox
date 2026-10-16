% The COBRAToolbox: testRemoveProblematicCharacters.m
%
% Purpose:
%     - removeProblematicCharacters replaces characters that cause problems in identifiers (blanks,
%     symbols and punctuation) by an underscore or a given single character, deletes them when the
%     substitute is empty, and rewrites German umlauts.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/removeProblematicCharacters.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines that handle the accented characters (o, u and a umlaut, sharp s and mu): they are
%     written with characters in a legacy encoding and cannot be matched reliably by a test file in
%     the current encoding.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveProblematicCharacters'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% default substitute

assert(strcmp(removeProblematicCharacters('a b@c-d.e'), 'a_b_c_d_e'));

%% every problematic ASCII character

problem = 'a/b\c:d;e,f<g>h~i*j+k=l?m!n#o%p&q(r)s"t';
assert(strcmp(removeProblematicCharacters(problem), 'a_b_c_d_e_f_g_h_i_j_k_l_m_n_o_p_q_r_s_t'));

%% another substitute

assert(strcmp(removeProblematicCharacters('a b', 'x'), 'axb'));

%% an empty substitute deletes the characters

assert(strcmp(removeProblematicCharacters('a b@c', ''), 'abc'));

%% a substitute longer than one character is an error

verifyCobraFunctionError('removeProblematicCharacters', 'inputs', {'a b', 'xy'}, ...
    'testMessage', 'substitute string too long');

%% an empty text is returned unchanged

assert(isempty(removeProblematicCharacters('')));

%% text without problematic characters

assert(strcmp(removeProblematicCharacters('abc123_'), 'abc123_'));

% change the directory
cd(currentDir)
