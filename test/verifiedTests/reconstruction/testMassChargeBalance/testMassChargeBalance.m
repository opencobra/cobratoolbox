% The COBRAToolbox: testMassChargeBalance.m
%
% Purpose:
%     - testMassChargeBalance tests the checkMassChargeBalance function using a small toy model
%       (createToyModel: eight variants with or without a missing formula, a wrong charge and a
%       mass imbalanced reaction, at printLevel -1 to 2).
%     - The sections after the toy-model loop use hand-built models (createModel and a struct):
%       every reaction mass balanced and one charge imbalanced (imBalancedMass is [], the
%       documented convention; printLevel -1 file and printLevel 2 printed list), a model with a
%       mass imbalanced reaction (each reaction is tested by its own mass balance), reactions
%       marked as not internal (SIntRxnBool), a metabolite with a formula but no charge, and a
%       1000-reaction model without a rxns field. Printed output is read from a diary file and
%       the printLevel -1 files are written with a modelName prefix in a tempname folder.
%     - The defects recorded on 2026-11-23 (printLevel -1/2 errors, stale index p) were fixed by
%       feature 20261125-161147-blocker-fixes-two and are tested below; the empty
%       imBalancedMass is the documented convention.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/checkMassChargeBalance.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model analysis without a solver; hand-built models (createToyModel, createModel,
%     a struct) and a tempname folder for the printLevel -1 files.
%
% Coverage exemptions:
%     Lines 230-234 (the printLevel -1 list of metabolites with a formula but no charge, in
%     [modelName 'metabolites_without_charge.txt']): the input is skipped because of the defect
%     "metabolites_without_charge.txt is left open" below. Every other executable line is
%     reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: metabolites_without_charge.txt is left open
%       SEVERITY: cosmetic
%       TRIGGER: cm = createModel({'R1','R2'}, {'',''}, {'a[c] -> b[c]', 'b[c] -> c[c]'},
%         'printLevel', 0); cm.metFormulas = {'C';'C';'C'}; cm.metCharges = [0;NaN;0];
%         checkMassChargeBalance(cm, -1, prefix)
%       OBSERVED: (R2025a, 2026-11-25) the file [prefix 'metabolites_without_charge.txt'] is
%         written, but its file identifier, opened at line 231, is never closed: openedFiles
%         still lists it after the call
%       EXPECTED: the file closed before the function returns, as the other printLevel -1
%         files are (lines 186-188, 261-263)
%       LINES: 229-234
%     - DEFECT: the printLevel -1 message names a file that is not written
%       SEVERITY: cosmetic
%       TRIGGER: any model with a mass balanced, charge imbalanced internal reaction,
%         checkMassChargeBalance(model, -1, prefix), e.g. the model above with metCharges [0;0;1]
%       OBSERVED: (R2025a, 2026-11-25) "There are mass balanced, but charge imbalanced
%         reactions, see <prefix>charge_imbalanced_reactions.txt", while the list is written to
%         <prefix>mass_balanced_charge_imbalanced_reactions.txt (line 248)
%       EXPECTED: the message names the file written at line 248
%       LINES: 249
%     - DEFECT: the progress line every 1000 reactions is never printed
%       SEVERITY: cosmetic
%       TRIGGER: any model with 1000 reactions or more, e.g. the 1000-reaction chain below,
%         checkMassChargeBalance(model, 2)
%       OBSERVED: (R2025a, 2026-11-25) nothing is printed at line 158: '%n' is not an fprintf
%         conversion, so fprintf stops there; the line is also not gated by printLevel and
%         names elements{j} with j left at the last element (FULLR). The test reaches the line
%         but asserts nothing about its output
%       EXPECTED: a progress line such as '1000 reactions checked' at printLevel > 0 only, as
%         the element progress lines (lines 115-117, 122-124)
%       LINES: 157-159
%
% Authors:
%     - Original file: Thomas Pfau 09/02/2017
%     - CI integration: Laurent Heirendt Feburary 2017
%     - Sections for printLevel -1 and 2 after the fix (feature 20261125-161147-blocker-fixes-two),
%       2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMassChargeBalance'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% the toy model of createToyModel: eight variants at printLevel -1 to 2

options = logical([0 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1]);

for i= 1:size(options, 1)
    for printLevel = -1:2
        model = createToyModel(options(i, 1), options(i, 2), options(i, 3));
        [massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool, ~, missingFormulaeBool, balancedMetBool] = checkMassChargeBalance(model, printLevel);

        if options(i, 1)
            % there should be at least one imbalanced internal reaction and
            % one missing formula bool if we look at a network with missing
            % formulas Also, if we have unknown formulas, we should have NaN
            % values.
            %assert(~any(imBalancedRxnBool(2:4)) || ~any(missingFormulaeBool) || ~any(any(isnan(massImbalance))))
            assert(any(imBalancedRxnBool(2:4)) && any(missingFormulaeBool) && any(any(isnan(massImbalance))))
        else
            % there should be no missing formulas (but we can't say anything more)
            assert(~any(missingFormulaeBool))

            % if we don't have a problem with the balancing of reaction 4 we should have at least one balanced Metabolite
            if ~options(i, 3)
                assert(any(balancedMetBool))
            end
        end

        if options(i, 2)
            %if we have a wrong charge this should come up in at least one internal
            assert(~isempty(imBalancedCharge) && any(imBalancedCharge(2:4)))
        else
            % Our reaction imbalanceing is happening in reaction 4, so 2 and 3
            % should have acceptable charge balances
            assert(isempty(imBalancedCharge) || ~any(imBalancedCharge(2:3)))
        end

        if options(i, 3)
            % Now, we have an imbalanced reaction
            assert( ~(~any(imBalancedRxnBool(2:4)) || isempty(imBalancedCharge) || (~isempty(imBalancedCharge) && ~any(imBalancedCharge(2:4))) || ~any(cellfun(@isempty , imBalancedMass(2:4)))))
        elseif ~options(i, 1) && ~options(i, 2)
            assert(~(any(imBalancedRxnBool(2:4)) || ( ~isempty(imBalancedCharge) && any(imBalancedCharge(2:4))) || any(any(massImbalance(2:4,:)))))
        end
    end
end

% remove the files that printLevel -1 wrote into the test folder (no modelName prefix)
fileNames = {'charge_imbalanced_reactions.txt', 'mass_imbalanced_reactions.txt', 'metabolites_without_formulae.txt', ...
             'mass_balanced_charge_imbalanced_reactions.txt'};

for i = 1:length(fileNames)
    % remove the generated files
    fullFileNamePath = [fileDir, filesep, fileNames{i}];
    if exist(fullFileNamePath, 'file') == 2
        delete(fullFileNamePath);
    end
end

% printed output is read from a diary file, and the printLevel -1 files are written with a
% modelName prefix, in a temporary folder
outFolder = tempname;
mkdir(outFolder);
diaryFile = fullfile(outFolder, 'checkMassChargeBalance.txt');
massFileName = 'mass_imbalanced_reactions.txt';
chargeFileName = 'mass_balanced_charge_imbalanced_reactions.txt';
heading = 'Mass balanced, but charged imbalanced reactions:';
allElements = {'H', 'C', 'O', 'P', 'S', 'N', 'Mg', 'X', 'Fe', 'Zn', 'Co', 'Ca', 'Y', 'I', 'Na', 'Cl', 'K', 'R', 'FULLR'};
% the reactions of a list of mass balanced, charge imbalanced reactions: each reaction is a
% line '<index>\t<reaction>\t<equation>' (the lines of its metabolites start with spaces)
listedReactions = @(text) cellfun(@(token) token{1}, regexp(text, '^\d+\t(\S+)\t', 'tokens', 'lineanchors'), ...
                                  'UniformOutput', false);

%% every reaction mass balanced, one charge imbalanced: imBalancedMass is [] (documented convention)

% R1: a -> b is mass and charge balanced; R2: b -> c is mass balanced, its charge goes 0 -> 1
modelBalanced = createModel({'R1', 'R2'}, {'', ''}, {'a[c] -> b[c]', 'b[c] -> c[c]'}, 'printLevel', 0);
assert(isequal(modelBalanced.mets, {'a[c]'; 'b[c]'; 'c[c]'}));
modelBalanced.metFormulas = {'C'; 'C'; 'C'};
modelBalanced.metCharges = [0; 0; 1];

[massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool, elements, missingFormulaeBool, balancedMetBool] = ...
    checkMassChargeBalance(modelBalanced);
% no element changes in any reaction, so imBalancedMass is empty (OUTPUTS: "empty if every
% reaction is mass balanced"); the charge imbalance is nRxn x 1 (integer charges, so the
% comparisons are exact)
assert(isequal(imBalancedMass, []));
assert(isequal(elements, allElements));
assert(issparse(massImbalance) && isequal(size(massImbalance), [2, numel(allElements)]) && nnz(massImbalance) == 0);
assert(isequal(imBalancedCharge, [0; 1]));
assert(isequal(imBalancedRxnBool, [false; true]));
assert(isequal(missingFormulaeBool, false(3, 1)));
% only a is used exclusively by the balanced reaction R1
assert(isequal(balancedMetBool, [true; false; false]));

%% printLevel -1 writes the mass balanced, charge imbalanced reactions to a file

% (before feature 20261125-161147-blocker-fixes-two this call stopped with an indexing error)
prefix = fullfile(outFolder, 'balanced_');
[massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool] = checkMassChargeBalance(modelBalanced, -1, prefix);
% the outputs are those of printLevel 0
assert(isequal(imBalancedMass, []) && nnz(massImbalance) == 0);
assert(isequal(imBalancedCharge, [0; 1]) && isequal(imBalancedRxnBool, [false; true]));
% the file lists R2 (index 2) and only R2; no mass imbalanced reaction file is written
written = fileread([prefix chargeFileName]);
assert(isequal(listedReactions(written), {'R2'}));
assert(~isempty(regexp(written, '^2\tR2\tb\[c\]\s+->\s+c\[c\]', 'once', 'lineanchors')));
assert(exist([prefix massFileName], 'file') ~= 2);

%% printLevel 2 prints the mass balanced, charge imbalanced reactions

% (before feature 20261125-161147-blocker-fixes-two this call stopped with an indexing error)
diary(diaryFile);
[~, imBalancedMass, imBalancedCharge] = checkMassChargeBalance(modelBalanced, 2);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(isequal(imBalancedMass, []) && isequal(imBalancedCharge, [0; 1]));
% under the heading R2 is listed, with its metabolites (index, name, coefficient, charge,
% formula); R1, mass and charge balanced, is not
assert(contains(printed, heading));
underHeading = extractAfter(printed, heading);
assert(isequal(listedReactions(underHeading), {'R2'}));
assert(~isempty(regexp(underHeading, '^\s+2\t\s+b\[c\]\t-1\t0\tC\s*$', 'once', 'lineanchors')));
assert(~isempty(regexp(underHeading, '^\s+3\t\s+c\[c\]\t1\t1\tC\s*$', 'once', 'lineanchors')));
% printLevel > 0 reports each element as it is checked
assert(contains(printed, 'Checked element H') && contains(printed, 'Checking element FULLR'));

%% a mass imbalanced reaction: each reaction is listed by its own mass balance

% R1: a -> b is mass balanced (C -> C), its charge goes 0 -> 1
% R2: b -> c gains one H (C -> CH), its charge goes 1 -> 2
% R3: c -> d is mass and charge balanced (CH -> CH, 2 -> 2), and is the last reaction
modelMixed = createModel({'R1', 'R2', 'R3'}, {'', '', ''}, {'a[c] -> b[c]', 'b[c] -> c[c]', 'c[c] -> d[c]'}, ...
                         'printLevel', 0);
assert(isequal(modelMixed.mets, {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'}));
modelMixed.metFormulas = {'C'; 'C'; 'CH'; 'CH'};
modelMixed.metCharges = [0; 1; 2; 2];

[massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool] = checkMassChargeBalance(modelMixed);
% with a mass imbalanced reaction, imBalancedMass is an nRxn x 1 cell, '' for the balanced ones
assert(isequal(imBalancedMass, {''; '1 H'; ''}));
assert(isequal(full(massImbalance(:, strcmp(allElements, 'H'))), [0; 1; 0]) && nnz(massImbalance) == 1);
assert(isequal(imBalancedCharge, [1; 1; 0]));
assert(isequal(imBalancedRxnBool, [true; true; false]));

diary(diaryFile);
checkMassChargeBalance(modelMixed, 2);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(contains(printed, heading));
% the mass imbalanced reaction R2 is printed with its imbalance before the heading
assert(~isempty(regexp(extractBefore(printed, heading), '^\s*2\t\s*R2\t\s*1 H\t', 'once', 'lineanchors')));
% under the heading R1 only: R2 is charge imbalanced but not mass balanced, R3 is balanced
% (before the fix every reaction was tested by the mass balance of the last one, R3, so R2
% was listed too)
assert(isequal(listedReactions(extractAfter(printed, heading)), {'R1'}));

% printLevel -1 writes the same two lists to files
prefix = fullfile(outFolder, 'mixed_');
checkMassChargeBalance(modelMixed, -1, prefix);
written = fileread([prefix massFileName]);
% two header lines and an empty line, then R2 with its imbalance and equation, then its two
% metabolites (index, name, coefficient, formula); R2 is the only reaction
assert(startsWith(written, sprintf('j;rxns{j};imbalance;equation\ni;mets{i};S(i,j);metFormulas{i}\n\n')));
assert(~isempty(regexp(written, '^2;R2;1 H;b\[c\]\s+->\s+c\[c\]', 'once', 'lineanchors')));
assert(~isempty(regexp(written, '^\s+2\t\s+b\[c\]\t-1\tC\s*$', 'once', 'lineanchors')));
assert(~isempty(regexp(written, '^\s+3\t\s+c\[c\]\t1\tCH\s*$', 'once', 'lineanchors')));
assert(numel(regexp(written, '^\d+;', 'match', 'lineanchors')) == 1);
written = fileread([prefix chargeFileName]);
assert(isequal(listedReactions(written), {'R1'}));

% when the last reaction is the mass imbalanced one (R1 charge imbalanced, R2 gains one H),
% R1 is still listed (before the fix nothing was listed)
modelLastImbalanced = modelBalanced;
modelLastImbalanced.metFormulas = {'C'; 'C'; 'CH'};
modelLastImbalanced.metCharges = [0; 1; 1];
diary(diaryFile);
[~, imBalancedMass, imBalancedCharge] = checkMassChargeBalance(modelLastImbalanced, 2);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(isequal(imBalancedMass, {''; '1 H'}) && isequal(imBalancedCharge, [1; 0]));
assert(isequal(listedReactions(extractAfter(printed, heading)), {'R1'}));

%% reactions marked as not internal (SIntRxnBool) are imbalanced and not listed

% modelBalanced with R2 marked as an exchange: its mass imbalance is set to 1 for every element
modelExchange = modelBalanced;
modelExchange.SIntRxnBool = [true; false];
[massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool] = checkMassChargeBalance(modelExchange);
assert(isequal(full(massImbalance), [zeros(1, numel(allElements)); ones(1, numel(allElements))]));
expectedExchange = strjoin(cellfun(@(element) ['1 ' element], allElements, 'UniformOutput', false), ', ');
assert(isequal(imBalancedMass, {''; expectedExchange}));
assert(isequal(imBalancedCharge, [0; 1]) && isequal(imBalancedRxnBool, [false; true]));

% R2 is printed neither as mass imbalanced nor under the heading, and no file is written
diary(diaryFile);
checkMassChargeBalance(modelExchange, 2);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(contains(printed, heading));
assert(isempty(regexp(extractBefore(printed, heading), '^\s*\d+\t\s*R\d\t', 'once', 'lineanchors')));
assert(isempty(listedReactions(extractAfter(printed, heading))));
prefix = fullfile(outFolder, 'exchange_');
checkMassChargeBalance(modelExchange, -1, prefix);
assert(exist([prefix massFileName], 'file') ~= 2 && exist([prefix chargeFileName], 'file') ~= 2);

%% a metabolite with a formula but no charge: its reactions have a NaN charge imbalance

% b has no charge; both reactions use it
modelNoCharge = modelBalanced;
modelNoCharge.metCharges = [0; NaN; 0];
[~, imBalancedMass, imBalancedCharge, imBalancedRxnBool] = checkMassChargeBalance(modelNoCharge);
assert(isequal(imBalancedMass, []) && isequal(size(imBalancedCharge), [2, 1]) && all(isnan(imBalancedCharge)));
assert(isequal(imBalancedRxnBool, [true; true]));

% printLevel 2 names the metabolite and warns (the warning is shown, not suppressed)
lastwarn('');
diary(diaryFile);
checkMassChargeBalance(modelNoCharge, 2);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(contains(printed, sprintf('2\tb[c] has no charge but has formula.')));
assert(contains(lastwarn, 'model structure must contain model.metCharges field for each metabolite'));
% printLevel -1 is not called here: see the defect "metabolites_without_charge.txt is left open"

%% 1000 reactions and no rxns field: reaction names rxn1, rxn2, ... are generated

% a chain m1 -> m2 -> ... -> m1001; every formula is C except m1001 (CH), so only the last
% reaction rxn1000 gains one H; there is no metCharges field
nChain = 1000;
modelChain = struct();
modelChain.S = spdiags([-ones(nChain, 1), ones(nChain, 1)], [0, -1], nChain + 1, nChain);
modelChain.mets = arrayfun(@(i) sprintf('m%d', i), (1:nChain + 1)', 'UniformOutput', false);
modelChain.metFormulas = [repmat({'C'}, nChain, 1); {'CH'}];

diary(diaryFile);
[massImbalance, imBalancedMass, imBalancedCharge, imBalancedRxnBool, ~, ~, balancedMetBool] = ...
    checkMassChargeBalance(modelChain, 2);
diary('off');
printed = fileread(diaryFile);
delete(diaryFile);
assert(isequal(find(imBalancedRxnBool), nChain) && nnz(massImbalance) == 1);
assert(strcmp(imBalancedMass{nChain}, '1 H') && all(strcmp(imBalancedMass(1:nChain - 1), '')));
% without metCharges the charge imbalance is NaN for every reaction
assert(isequal(size(imBalancedCharge), [nChain, 1]) && all(isnan(imBalancedCharge)));
% m1001 and m1000 are used by the imbalanced reaction rxn1000, the others only by balanced ones
assert(isequal(balancedMetBool, [true(nChain - 1, 1); false; false]));
% the mass imbalanced reaction is printed with its generated name
assert(~isempty(regexp(printed, '^\s*1000\t\s*rxn1000\t\s*1 H\t', 'once', 'lineanchors')));

% remove the temporary folder
rmdir(outFolder, 's');

% change the directory
cd(currentDir)
