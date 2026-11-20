% The COBRAToolbox: testGetDietEnergy.m
%
% Purpose:
%     - getDietEnergy(diet, ...) returns the kcal of a diet: for food items (grams per day) from
%       the energy row of the USDA, Frida or BLS macro tables per 100 g, and for metabolite
%       fluxes (mmol per day, databaseType 'metabolites') from the macro category of each
%       metabolite in the three nutrient info files and its molecular weight (9 kcal/g for
%       lipids, 7 for alcohol, 4 for carbohydrates, sugars, proteins, starch and fibre, 0
%       otherwise). The test passes hand-built tables (round numbers, so every expected value is
%       a hand calculation), covers the USDA fall-back energy ids 2047 and 2048, missing energy
%       values and weights (warnings), duplicate items, a database per item, the error for an
%       unknown database, and the loading of each table from file with hand-made files of a
%       fictitious edition 1999 on the MATLAB path. One call uses the VMH metabolite database
%       and getMolecularMass for glucose.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getDietEnergy.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built tables; the VMH metabolite database text file of
%     the toolbox is read once (loadVMHDatabase).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDietEnergy'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% loadVMHDatabase declares two globals; they are removed at the end
globalsBefore = who('global');

% kcal values are sums of a few products of round numbers: 1e-10 covers the rounding
tol = 1e-10;

% hand-built macro tables per 100 g of food, in the layout of the shipped tables
foodMacroUsda = table([1008; 2047; 2048; 1003], [250; NaN; NaN; 1], [NaN; 300; NaN; 2], ...
    [NaN; NaN; 120; 3], [NaN; NaN; NaN; 4], ...
    'VariableNames', {'nutrient_id', '100001', '100002', '100003', '100004'});
foodMacroFrida = table({'Energy, labelling (kcal)'; 'Protein'}, [400; 5], [NaN; 1], ...
    'VariableNames', {'macroName', '1', '2'});
foodMacroBLS = table({'ENERCC'; 'PROT625'}, [90; 3], [NaN; 2], ...
    'VariableNames', {'componentCode', 'B100000', 'C200000'});

% hand-built nutrient info files: VMH id, macro category and whether the row is a metabolite.
% 'zzz' is no metabolite (metBool 0) and 'not in VMH' no valid VMH id: both are dropped
nutrientVmhTable = table({'glc_D'; 'hdca'; 'ala_L'; 'h2o'; 'sucr'; 'not in VMH'; 'zzz'}, ...
    {'Sugar'; 'Lipids'; 'Proteins'; 'Water'; 'Sugar'; 'Sugar'; 'Lipids'}, [1; 1; 1; 1; 1; 1; 0], ...
    'VariableNames', {'vmhID', 'macroCategory', 'metBool'});
% Frida writes Fibre (renamed to Fiber)
nutrientInfoFileFrida = table({'fib1'; 'etoh'; 'strch1'; 'cobalt2'}, ...
    {'Fibre'; 'Alcohol'; 'Starch'; 'Minerals and trace elements'}, [1; 1; 1; 1], ...
    'VariableNames', {'vmhID', 'macroCategory', 'metBool'});
% BLS writes Protein (renamed to Proteins)
nutrientInfoFileBLS = table({'prot1'; 'carb1'; 'oth1'; 'ni2'}, ...
    {'Protein'; 'Carbohydrates'; 'Other'; 'Minerals and trace elements'}, [1; 1; 1; 1], ...
    'VariableNames', {'vmhID', 'macroCategory', 'metBool'});
% molecular weights in g/mol (round numbers); sucr has none
metaboliteWeights = table({'glc_D'; 'hdca'; 'ala_L'; 'fib1'; 'etoh'; 'strch1'; 'prot1'; 'carb1'; 'cobalt2'; 'ni2'}, ...
    {'C6H12O6'; 'C16H31O2'; 'C3H7NO2'; 'X'; 'C2H6O'; 'X'; 'X'; 'X'; 'Co'; 'Ni'}, ...
    [180; 256; 89; 500; 46; 1000; 100; 200; NaN; NaN], ...
    'VariableNames', {'VMHID', 'formula', 'molecularWeight'});
infoTables = {'nutrientVmhTable', nutrientVmhTable, 'nutrientInfoFileFrida', nutrientInfoFileFrida, ...
    'nutrientInfoFileBLS', nutrientInfoFileBLS};

%% USDA food items: energy id 1008, fall-backs 2047 and 2048, no energy value

% 50 g x 250/100 + 10 g x 300/100 + 200 g x 120/100 = 125 + 30 + 240 kcal
diet = {'100001', 50; '100002', 10; '100003', 200};
calories = getDietEnergy(diet, 'foodMacroUsda', foodMacroUsda);
assert(abs(calories - 395) < tol);

% a food without any energy value counts 0 kcal and is reported with a warning
lastwarn('');
calories = getDietEnergy({'100001', 50; '100004', 80}, 'databaseType', 'usda', 'foodMacroUsda', foodMacroUsda);
assert(abs(calories - 125) < tol);
assert(contains(lastwarn, 'The following USDA food ID does not seem to have a KCAL') && contains(lastwarn, '100004'));

%% Frida and BLS food items, and a food without energy value in each

lastwarn('');
calories = getDietEnergy({'1', 25; '2', 10}, 'databaseType', 'frida', 'foodMacroFrida', foodMacroFrida);
% 25 g x 400/100 = 100 kcal; Frida food 2 has no energy value
assert(abs(calories - 100) < tol);
assert(contains(lastwarn, 'The following FRIDA food ID does not seem to have a KCAL') && contains(lastwarn, '2'));

lastwarn('');
calories = getDietEnergy({'B100000', 300; 'C200000', 5}, 'databaseType', 'bls', 'foodMacroBLS', foodMacroBLS);
% 300 g x 90/100 = 270 kcal; BLS food C200000 has no energy value
assert(abs(calories - 270) < tol);
assert(contains(lastwarn, 'The following BLS food ID does not seem to have a KCAL') && contains(lastwarn, 'C200000'));

%% one database per item (not case sensitive), and duplicate items are summed per database

% 20 + 30 g of USDA food 100001 (125 kcal), 10 + 15 g of Frida food 1 (100 kcal) and 100 + 200 g
% of BLS food B100000 (270 kcal)
diet = {'100001', 20; '1', 10; 'B100000', 100; '100001', 30; '1', 15; 'B100000', 200};
calories = getDietEnergy(diet, 'databaseType', {'usda'; 'FRIDA'; 'bls'; 'USDA'; 'frida'; 'Bls'}, ...
    'foodMacroUsda', foodMacroUsda, 'foodMacroFrida', foodMacroFrida, 'foodMacroBLS', foodMacroBLS);
assert(abs(calories - 495) < tol);

%% an unknown database is an error

assert(verifyCobraFunctionError('getDietEnergy', 'inputs', {{'100001', 50}, 'databaseType', 'ciqual'}, ...
    'testMessage', 'Unknown database(s): ciqual. Please use usda, frida, bls or metabolites.'));
assert(verifyCobraFunctionError('getDietEnergy', 'inputs', {{'100001', 50; '1', 5}, 'databaseType', {'usda'; 'x'}}, ...
    'testMessage', 'Unknown database(s): x. Please use usda, frida, bls or metabolites.'));

%% metabolites: calories per macro category from mmol x g/mol

% mmol x g/mol / 1000 = g; kcal = g x kcal/g:
%   glc_D  10 x 180 -> 1.8 g sugar      x 4 = 7.2      hdca   2 x 256 -> 0.512 g lipid x 9 = 4.608
%   ala_L   5 x 89  -> 0.445 g protein  x 4 = 1.78     fib1   1 x 500 -> 0.5 g fibre   x 4 = 2
%   etoh   10 x 46  -> 0.46 g alcohol   x 7 = 3.22     strch1 1 x 1000 -> 1 g starch   x 4 = 4
%   prot1  10 x 100 -> 1 g protein      x 4 = 4        carb1  5 x 200 -> 1 g carbohydrate x 4 = 4
% and 0 kcal for Other (oth1), Water (h2o), minerals (cobalt2, ni2 with the formulas Co and Ni),
% and a metabolite that is in no info file (unknown); total 30.808 kcal
diet = {'Diet_EX_glc_D[d]', 10; 'Diet_EX_hdca[d]', 2; 'Diet_EX_ala_L[d]', 5; 'Diet_EX_fib1[d]', 1; ...
    'Diet_EX_etoh[d]', 10; 'Diet_EX_strch1[d]', 1; 'Diet_EX_prot1[d]', 10; 'Diet_EX_carb1[d]', 5; ...
    'Diet_EX_oth1[d]', 3; 'Diet_EX_h2o[d]', 100; 'Diet_EX_cobalt2[d]', 1; 'Diet_EX_ni2[d]', 1; ...
    'Diet_EX_unknown[d]', 4};
calories = getDietEnergy(diet, 'databaseType', 'metabolites', infoTables{:}, 'metaboliteWeights', metaboliteWeights);
assert(abs(calories - 30.808) < tol);

% a metabolite with calories but without a molecular weight counts 0 kcal, with a warning
lastwarn('');
calories = getDietEnergy({'Diet_EX_sucr[d]', 3; 'Diet_EX_glc_D[d]', 10}, 'databaseType', 'metabolites', ...
    infoTables{:}, 'metaboliteWeights', metaboliteWeights);
assert(abs(calories - 7.2) < tol);
assert(strcmp(lastwarn, 'No molecular weight is available for sucr, its calories are not counted.'));

%% metabolites without given weights: formulas from the VMH database and getMolecularMass

% getMolecularMass gives the monoisotopic mass: C6H12O6 = 6 x 12 + 12 x 1.00782503207 +
% 6 x 15.99491461956 = 180.0633881 g/mol, so 10 mmol of glucose are 4 x 1.800633881 kcal.
% The relative tolerance 1e-6 allows for the isotope masses that getMolecularMass uses
calories = getDietEnergy({'Diet_EX_glc_D[d]', 10}, 'databaseType', 'metabolites', infoTables{:});
glucoseMass = 6 * 12 + 12 * 1.00782503207 + 6 * 15.99491461956;
assert(abs(calories / (4 * 10 * glucoseMass / 1000) - 1) < 1e-6);

%% every table loaded from file, with the editions given as text, number and string

% hand-made database files of the fictitious edition 1999 in a temporary folder on the path
pathBefore = path;
tempFolder = tempname;
mkdir(tempFolder);
save(fullfile(tempFolder, 'USDA1999_100gMacros.mat'), 'foodMacroUsda');
save(fullfile(tempFolder, 'frida1999_100gMacros.mat'), 'foodMacroFrida');
save(fullfile(tempFolder, 'BLS1999_100gMacros.mat'), 'foodMacroBLS');
save(fullfile(tempFolder, 'usda1999_infoFile.mat'), 'nutrientVmhTable');
save(fullfile(tempFolder, 'frida1999_infoFile.mat'), 'nutrientInfoFileFrida');
save(fullfile(tempFolder, 'BLS1999_infoFile.mat'), 'nutrientInfoFileBLS');
addpath(tempFolder);

% food items: 125 + 100 + 270 kcal as above
calories = getDietEnergy({'100001', 50; '1', 25; 'B100000', 300}, 'databaseType', {'usda'; 'frida'; 'bls'}, ...
    'usdaEdition', '1999', 'fridaEdition', 1999, 'blsEdition', "1999");
assert(abs(calories - 495) < tol);

% metabolites: the three info files; the same 30.808 kcal as above
calories = getDietEnergy(diet, 'databaseType', 'metabolites', 'usdaEdition', '1999', ...
    'fridaEdition', '1999', 'blsEdition', '1999', 'metaboliteWeights', metaboliteWeights);
assert(abs(calories - 30.808) < tol);

path(pathBefore);
rmdir(tempFolder, 's');

% remove the globals created by loadVMHDatabase
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clear('global', newGlobals{k});
end

% change the directory
cd(currentDir)
