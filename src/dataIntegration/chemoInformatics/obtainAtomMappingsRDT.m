function standardisedRxns = obtainAtomMappingsRDT(model, molFileDir, outputDir, maxTime, standariseRxn)
% Compute atom mappings for reactions with implicit hydrogens in a
% metabolic network using RDT algorithm
%
% USAGE:
%
%    unmappedRxns = obtainAtomMappingsRDT(model, molFileDir, rxnDir, maxTime, standariseRxn)
%
% INPUTS:
%    model:         COBRA model with following fields:
%
%                       * .S - The m x n stoichiometric matrix for the
%                              metabolic network.
%                       * .mets - An m x 1 array of metabolite identifiers.
%                                 Should match metabolite identifiers in
%                                 RXN.
%                       * .metFormulas - An m x 1 array of metabolite
%                                 identifiers. Should match metabolite
%                                 identifiers in RXN.
%                       * .rxns - An n x 1 array of reaction identifiers.
%                                 Should match rxnfile names in rxnFileDir.
%    molFileDir:    Path to the directory containing MOL files for
%                   metabolites in S. File names should correspond to
%                   reaction identifiers in input mets.
%
% OPTIONAL INPUTS:
%    rxnDir:        Path to directory that will contain the RXN files with
%                   atom mappings (default current directory).
%    maxTime:       Maximum time assigned to compute atom mapping (default
%                   1800s).
%    standariseRxn: Logic value for standardising the atom mapped RXN file.
%                   ChemAxon license is required (default TRUE).
%
% OUTPUTS:
%    balancedRxns:	List of standadised atom mapped reactions.
%    A directory with standardised RXN files.
%    A directory with atom mapped RXN files.
%    A directory images for atom mapped reactions.
%    A directory with txt files with data of the atom mappings (SMILES,
%    REACTANT INPUT ATOM INDEX, PRODUCT INPUT ATOM INDEX).
%
% EXAMPLE:
%
%    example 1:
%    molFileDir = ['data' filesep]
%    standariseRxn = true;
%    unmappedRxns = obtainAtomMappingsRDT(model, molFileDir, pwd, 1800, standariseRxn)
%    example 2:
%    molFileDir = ['data' filesep]
%    standariseRxn = false;
%    standardisedRxns = obtainAtomMappingsRDT(model, molFileDir, pwd, 1800, standariseRxn)
%
% .. Author: - German A. Preciat Gonzalez 25/05/2017

if nargin < 3 || isempty(outputDir)
    outputDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    outputDir = [regexprep(outputDir,'(/|\\)$',''), filesep];
end
if nargin < 4 || isempty(maxTime)
    maxTime = 1800;
end
if nargin < 5 || isempty(standariseRxn)
    standariseRxn = true;
end

% Generating new directories
mkdir([outputDir filesep 'rxnFiles'])
mkdir([outputDir filesep 'atomMapped'])
mkdir([outputDir filesep 'images'])
mkdir([outputDir filesep 'txtData'])

% Download the RDT algorithm
if ~exist([outputDir filesep 'rdtAlgorithm.jar'], 'file')
    urlwrite('https://github.com/asad/ReactionDecoder/releases/download/1.5.1/rdt-1.5.1-SNAPSHOT-jar-with-dependencies.jar',[outputDir filesep 'rdtAlgorithm.jar']);
end

% Delete the protons (hydrogens) for the metabolic network
% From metabolites
S = full(model.S);
if isfield(model,'metFormulas')
    hToDelete = ismember(model.metFormulas, 'H');
    S(hToDelete, :) = [];
    model.mets(hToDelete) = [];
    % From reactions
    hydrogenCols = all(S == 0, 1);
    S(:, hydrogenCols) = [];
    model.rxns(hydrogenCols) = [];
    model.S = S;
end


% Format inputs
mets = model.mets;
fmets = regexprep(mets, '(\[\w\])', '');
rxns = model.rxns;
clear model

% Get list of MOL files
d = dir(molFileDir);
d = d(~[d.isdir]);
aMets = {d.name}';
aMets = aMets(~cellfun('isempty',regexp(aMets,'(\.mol)$')));
% Identifiers for atom mapped reactions
aMets = regexprep(aMets, '(\.mol)$','');
assert(~isempty(aMets), 'MOL files directory is empty or nonexistent.');

% Extract MOL files
% True if MOL files are present in the model
mbool = (ismember(fmets, aMets));

assert(any(mbool), 'No MOL files found for model metabolites.\nCheck that MOL files names match reaction identifiers in mets.');
fprintf('\n\nGenerating RXN files.\n');

% Create the RXN files. Three conditions are required: 1) To have all the
% MOL files in the reaction, 2) No exchange reactions, 3) Only integers in
% the stoichiometry
for i=1:length(rxns)
    a = ismember(regexprep(mets(find(S(:,i))), '(\[\w\])', ''), aMets);
    s = S(find(S(:, i)), i);
    if all(a(:) > 0) && length(a) ~= 1 && all(abs(round(s) - s) < (1e-2))
        writeRxnfile(S(:, i), mets, fmets, molFileDir, rxns{i}, [outputDir...
            filesep 'rxnFiles' filesep])
    end
end

% Atom map RXN files
fnames = dir([outputDir filesep 'rxnFiles' filesep '*.rxn']);
fprintf('Computing atom mappings for %d reactions.\n\n', length(fnames));

% Start from the lighter RXN to the heavier
[~,bytes] = sort([fnames.bytes]);
counterBalanced = 0;
counterNotMapped = 0;
counterUnbalanced = 0;
for i=1:length(fnames)
    name = [outputDir 'rxnFiles' filesep fnames(bytes(i)).name];
    command = ['timeout ' num2str(maxTime) 's java -jar ' outputDir 'rdtAlgorithm.jar -Q RXN -q "' name '" -g -j AAM -f TEXT'];
    if ismac
        command = ['g' command];
    end
    [status, result] = system(command);
    if status ~= 0
        fprintf(result);
        error('Command %s could not be run.\n', command);
    end
    
    mNames = dir('ECBLAST_*');
    if length(mNames) == 3
        name = regexprep({mNames.name}, 'ECBLAST_|_AAM', '');
        cellfun(@movefile, {mNames.name}, name)
        cellfun(@movefile, name, {[outputDir 'images'], [outputDir...
            'atomMapped'], [outputDir 'txtData']})
    elseif ~isempty(mNames)
        delete(mNames.name)
        counterNotMapped = counterNotMapped + 1;
    else
        counterNotMapped = counterNotMapped + 1;
    end
end

% Standarize reactions
if standariseRxn == true
    fnames = dir([outputDir filesep 'atomMapped' filesep '*.rxn']);
    for i = 1:length(fnames)
        standardised = canonicalRxn(fnames(i).name, [outputDir...
            'atomMapped'], [outputDir 'rxnFiles']);
        if standardised
            counterBalanced = counterBalanced + 1;
            standardisedRxns{counterBalanced} = regexprep(fnames(i).name, '.rxn', '');
        else
            counterUnbalanced = counterUnbalanced + 1;
        end
    end
else
    standardisedRxns = [];
    counterUnbalanced = length(dir([outputDir 'atomMapped' filesep '*.rxn']));
end

fprintf('\n%d reactions were atom mapped\n', length(dir([outputDir 'atomMapped' filesep '*.rxn'])));
fprintf('%d reactions are not standardised\n', counterUnbalanced);
fprintf('%d reactions were not mapped\n\n\n', counterNotMapped);

fprintf('RDT algorithm was developed by:\n');
fprintf('SA Rahman et al.: Reaction Decoder Tool (RDT): Extracting Features from Chemical\n');
fprintf('Reactions, Bioinformatics (2016), doi: 10.1093/bioinformatics/btw096\n');
