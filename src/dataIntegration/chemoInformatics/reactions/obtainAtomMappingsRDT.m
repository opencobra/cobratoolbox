function atomMappingReport = obtainAtomMappingsRDT(model, molFileDir, rxnDir, rxnsToAM, hMapping, onlyUnmapped)
% Using the reaction decoder tool, compute atom mappings for reactions in a
% COBRA model. Atom mapping data is presented in a variety of formats,
% including MDL RXN, SMILES, and images. If this option is selected, the
% function can remove all protons from the model and represent the
% reactions as a hydrogen suppressed chemical graph.
%
% USAGE:
%
%    standardisedRxns = obtainAtomMappingsRDT(model, molFileDir, rxnDir, rxnsToAM, hMapping, maxTime, standariseRxn)
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
%                   atom mappings (default: current directory).
%    rxnsToAM:      List of reactions to atom map (default: all in the
%                   model).
%    hMapping:      Logic value to select if hydrogen atoms will be atom
%                   mapped (default: TRUE).
%    onlyUnmapped:  Logic value to select create only unmapped MDL RXN
%                   files (default: FALSE).
%
% OUTPUTS:
%    atomMappingReport:	A report with the atom mapping data
%        *. rxnFilesWritten the MDL RXN written written
%        *. balanced the balanced reactions
%        *. unbalancedBool the unbalanced reactions
%        *. inconsistentBool the inconsistent reactions
%        *. notMapped the that couldn't be mapped
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

if nargin < 3 || isempty(rxnDir)
    rxnDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    rxnDir = [regexprep(rxnDir,'(/|\\)$',''), filesep];
end
if nargin < 4 || isempty(rxnsToAM)
    rxnsToAM = model.rxns;
end
if nargin < 5 || isempty(hMapping)
    hMapping = true;
end
if nargin < 6 || isempty(onlyUnmapped)
    onlyUnmapped = false;
end

% Maximum time for atom mapping each reaction in seconds
maxTime = 1800;

% Check installation
[cxcalcInstalled, ~] = system('cxcalc');
cxcalcInstalled = ~cxcalcInstalled;
if ismac || ispc 
    obabelCommand = 'obabel';
else
    obabelCommand = 'openbabel.obabel';
end
[oBabelInstalled, ~] = system(obabelCommand);
[javaInstalled, ~] = system('java');

% Generating new directories
if ~exist([rxnDir filesep 'unMapped'],'dir')
    mkdir([rxnDir filesep 'unMapped'])
end
if javaInstalled && ~onlyUnmapped
    if ~exist([rxnDir filesep 'atomMapped'],'dir')
        mkdir([rxnDir filesep 'atomMapped'])
    end
    if ~exist([rxnDir filesep 'images'],'dir')
        mkdir([rxnDir filesep 'images'])
    end
    if ~exist([rxnDir filesep 'txtData'],'dir')
        mkdir([rxnDir filesep 'txtData'])
    end
end

% Download the RDT algorithm, if it is not present in the output directory
if exist([rxnDir filesep 'rdtAlgorithm.jar']) ~= 2 && javaInstalled && ~onlyUnmapped
    urlwrite('https://github.com/asad/ReactionDecoder/releases/download/v2.4.1/rdt-2.4.1-jar-with-dependencies.jar',[rxnDir filesep 'rdtAlgorithm.jar']);
    % Previous releases:
    if ispc % go with an older version due to java version issues
        %     urlwrite('https://github.com/asad/ReactionDecoder/releases/download/v2.1.0/rdt-2.1.0-SNAPSHOT-jar-with-dependencies.jar',[outputDir filesep 'rdtAlgorithm.jar']);
        urlwrite('https://github.com/asad/ReactionDecoder/releases/download/1.5.1/rdt-1.5.1-SNAPSHOT-jar-with-dependencies.jar',[rxnDir filesep 'rdtAlgorithm.jar']);
    end
end

% Delete the protons (hydrogens) for the metabolic network
% From metabolites
S = full(model.S);
if ~hMapping && isfield(model,'metFormulas')
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
rxns = rxnsToAM;
rxnsInModel = model.rxns;
clear model

% Get list of MOL files
d = dir(molFileDir);
d = d(~[d.isdir]);
aMets = {d.name}';
aMets = aMets(~cellfun('isempty', regexp(aMets,'(\.mol)$')));
% Identifiers for atom mapped reactions
aMets = regexprep(aMets, '(\.mol)$', '');
assert(~isempty(aMets), 'MOL files directory is empty or nonexistent.');

% Extract MOL files
% True if MOL files are present in the model
mbool = (ismember(fmets, aMets));

assert(any(mbool), 'No MOL files found for model metabolites.\nCheck that MOL files names match reaction identifiers in mets.');
fprintf('\n\nGenerating RXN files.\n');

% Create the RXN files. Three conditions are required: 1) To have all the
% MOL files in the reaction, 2) No exchange reactions, 3) Only integers in
% the stoichiometry
rxnFilesWrittenBool = false(length(rxns), 1);
for i = 1:length(rxns)
    rxnBool = ismember(rxnsInModel, rxns{i});
    metsInRxns = ismember(fmets(find(S(:, rxnBool))), aMets);
    stoichiometry = S(find(S(:, rxnBool)), rxnBool);
    if ~any(~metsInRxns) && length(metsInRxns) > 1 && all(abs(round(stoichiometry) - stoichiometry) < (1e-2))
        writeRxnfile(S(:, rxnBool), mets, fmets, molFileDir, rxns{i}, [rxnDir...
            filesep 'unMapped' filesep])
        rxnFilesWrittenBool(i) = true;
    end
end
atomMappingReport.rxnFilesWritten = rxns(rxnFilesWrittenBool);

% Get list of new RXN files
d = dir([rxnDir filesep 'unMapped' filesep]);
d = d(~[d.isdir]);
aRxns = regexprep({d.name}', '.rxn', '');
assert(~isempty(aRxns), 'No rxn file was written.');
rxnsToAM = rxnsToAM(ismember(rxnsToAM, aRxns));

mappedBool = false(length(rxnsToAM), 1);

% Atom map RXN files
if javaInstalled == 1 && ~onlyUnmapped
    
    % Atom map RXN files
    fprintf('Computing atom mappings for %d reactions.\n\n', length(rxnsToAM));
    
    % Download the RDT algorithm, if it is not present in the output directory
    if exist([rxnDir filesep 'rdtAlgorithm.jar']) ~= 2 && javaInstalled && ~onlyUnmapped
        urlwrite('https://github.com/asad/ReactionDecoder/releases/download/v2.4.1/rdt-2.4.1-jar-with-dependencies.jar',[rxnDir filesep 'rdtAlgorithm.jar']);
        % Previous releases:
        %     urlwrite('https://github.com/asad/ReactionDecoder/releases/download/v2.1.0/rdt-2.1.0-SNAPSHOT-jar-with-dependencies.jar',[outputDir filesep 'rdtAlgorithm.jar']);
        %     urlwrite('https://github.com/asad/ReactionDecoder/releases/download/1.5.1/rdt-1.5.1-SNAPSHOT-jar-with-dependencies.jar',[outputDir filesep 'rdtAlgorithm.jar']);
    end
    
    % Atom map passive transport reactions; The atoms are mapped for the
    % same molecular structures in the substrates as they are in the
    % products i.e. A[m] + B[c] -> A[c] + B[m].
    mappedTransportRxns = transportRxnAM([rxnDir 'unMapped'], [rxnDir 'atomMapped']);
    if ~isempty(mappedTransportRxns)
        mappedBool = false(size(rxnsToAM));
        transportBool = ismember(rxnsToAM, mappedTransportRxns);
        mappedBool(transportBool) = true;
        nonTransport = setdiff(rxnsToAM, rxnsToAM(mappedBool));
    else
        nonTransport = rxnsToAM;
    end
    
    % Atom map the rest
    for i = 1:length(nonTransport)
        name = [rxnDir 'unMapped' filesep nonTransport{i} '.rxn'];
        command = ['timeout ' num2str(maxTime) 's java -jar ' rxnDir 'rdtAlgorithm.jar -Q RXN -q "' name '" -g -j AAM -f TEXT'];
        
        if ismac
            command = ['g' command];
        elseif ispc
            command = ['java -jar ' rxnDir 'rdtAlgorithm.jar -Q RXN -q "' name '" -g -j AAM -f TEXT'];
            
        end
        [status, result] = system(command);
        if ~contains(result, 'ECBLAST')
            [status, result] = system(command);
        end
        
        % RXN not found
        if contains(result, 'file not found!')
            warning(['The file ' name ' was not found'])
        end
        if ~status && ~ispc
            fprintf(result);
            error('Command %s could not be run.\n', command);
        end
        
        % Save files in the corresponding directory
        mNames = dir('ECBLAST_*');
        if length(mNames) == 3
            name = regexprep({mNames.name}, 'ECBLAST_|_AAM', '');
            cellfun(@movefile, {mNames.name}, name)
            cellfun(@movefile, name, {[rxnDir 'images'], [rxnDir...
                'atomMapped'], [rxnDir 'txtData']})
            mappedBool(ismember(rxnsToAM, nonTransport{i})) = true;
        elseif ~isempty(mNames)
            delete(mNames.name)
        end
        
    end
    % I do not think that the algorithm should be downloaded all the time
    if 1
        delete([rxnDir 'rdtAlgorithm.jar'])
    end
    
    mappedRxns = rxnsToAM(mappedBool);
    atomMappingReport.mappedRxns = mappedRxns;
    [unbalancedBool, inconsistentBool] = deal(false(size(rxnsToAM)));
    for i = 1:length(mappedRxns)
        
        name = [mappedRxns{i} '.rxn'];
        
        % Add header
        mappedFile = regexp(fileread([rxnDir 'atomMapped' filesep name]), '\n', 'split')';
        standardFile = regexp(fileread([rxnDir 'unMapped' filesep name]), '\n', 'split')';
        mappedFile{2} = standardFile{2};
        mappedFile{3} = ['COBRA Toolbox v3.0 - Atom mapped - ' datestr(datetime)];
        mappedFile{4} = standardFile{4};
        
        formula = strsplit(mappedFile{4}, {'->', '<=>'});
        
        substratesFormula = strtrim(strsplit(formula{1}, '+'));
        % Check if a metabolite is modified in the substrate's formula;
        % metabolites with an iron atom but no bonds are splited by the RDT
        % algorithm, which modifies the stoichiometry.
        repMetsSubInx = find(~cellfun(@isempty, regexp(substratesFormula, ' ')));
        if ~isempty(repMetsSubInx)
            for j = 1:length(repMetsSubInx)
                metRep = strsplit(substratesFormula{repMetsSubInx(j)});
                timesRep = str2double(metRep{1});
                metRep = metRep{2};
                substratesFormula{repMetsSubInx(j)} = strjoin(repmat({metRep}, [1 timesRep]));
            end
            substratesFormula = strsplit(strjoin(substratesFormula));
        end
        
        productsFormula = strtrim(strsplit(formula{2}, '+'));
        % Check if a metabolite is modified in the product's formula;
        % metabolites with an iron atom but no bonds are splited by the RDT
        % algorithm, which modifies the stoichiometry.
        repMetsProInx = find(~cellfun(@isempty, regexp(productsFormula, ' ')));
        if ~isempty(repMetsProInx)
            for     j = 1:length(repMetsProInx)
                metRep = strsplit(productsFormula{repMetsProInx(j)});
                timesRep = str2double(metRep{1});
                metRep = metRep{2};
                productsFormula{repMetsProInx(j)} = strjoin(repmat({metRep}, [1 timesRep]));
            end
            productsFormula = strsplit(strjoin(productsFormula));
        end
        
        % RXN file data
        begmol = strmatch('$MOL', mappedFile);
        noOfMolSubstrates = str2double(mappedFile{5}(1:3));
        if isnan(noOfMolSubstrates)
            if ~isfolder([rxnDir 'atomMapped' filesep 'v3000'])
                mkdir([rxnDir 'atomMapped' filesep 'v3000']);
            end
            movefile([rxnDir 'atomMapped' filesep name], [rxnDir 'atomMapped' filesep 'v3000'])
            continue
        end
        substratesMol = mappedFile(begmol(1:noOfMolSubstrates) + 1)';
        noOfMolProducts = str2double(mappedFile{5}(4:6));
        productsMol = mappedFile(begmol(noOfMolSubstrates + 1:noOfMolSubstrates + noOfMolProducts) + 1)';
        
        % Formula data
        noOfsubstrates = numel(substratesFormula);
        noOfproducts = numel(productsFormula);
        
        % Check if the stoichemestry is correct
        if ~isequal(noOfsubstrates, substratesMol) || ~isequal(noOfproducts, productsMol)
            mappedFile = sortMets(mappedFile, substratesMol, substratesFormula, productsMol, productsFormula, rxnDir);
        end
        
        % SMILES TO MOL
        begmol = strmatch('$MOL', mappedFile);
        if cxcalcInstalled && ~inconsistentBool(i) && ~isempty(begmol)
            
            begmolStd = strmatch('$MOL', standardFile);
            newMappedFile = {};
            newMappedFile = mappedFile(1:5);
            for j = 1:str2double(mappedFile{5, 1}(1:3)) + str2double(mappedFile{5, 1}(4:6))
                
                % Write a new MOL file and save it
                c = 0;
                molFile = {};
                while ~isequal(mappedFile{begmol(j) + 1 + c},  '$MOL') && begmol(j) + 1 + c < length(mappedFile)
                    c = c + 1;
                    molFile{c, 1} = regexprep(mappedFile{begmol(j) + c}, '\*', 'A');
                end
                fid2 = fopen('tmp.mol', 'w');
                fprintf(fid2, '%s\n', molFile{:});
                fclose(fid2);
                
                % Rewrite the MOL file
                command = ['molconvert smiles ' pwd filesep 'tmp.mol -o ' pwd filesep 'tmp.smiles'];
                [~, ~] = system(command);
                command = ['molconvert rxn ' pwd filesep 'tmp.smiles -o ' pwd filesep 'tmp.mol'];
                [~, ~] = system(command);
                delete([pwd filesep 'tmp.smiles'])
                molFile = regexp(fileread([pwd filesep 'tmp.mol']), '\n', 'split')';
                newMappedFile(length(newMappedFile) + 1: length(newMappedFile) + 4) = standardFile(begmolStd(j): begmolStd(j) + 3);
                newMappedFile(length(newMappedFile) + 1: length(newMappedFile)  + length(molFile) - 4) = molFile(4:end - 1);
                
            end
            mappedFile = newMappedFile;
        end
        
        % Sort the atoms in the substrates in ascending order and then map
        % them to the atoms in the products.
        if any(contains(mappedFile, '$MOL'))
            mappedFile = sortAtomMappingIdx(mappedFile);
        else
            inconsistentBool(i) = true;
        end
        
        % Check if the reaction is atomically balanced
        if ~inconsistentBool(i)
            begmol = strmatch('$MOL', mappedFile);
            atomsSubstrates = [];
            for j = 1:noOfsubstrates
                for k = 1:str2double(mappedFile{begmol(j) + 4}(1:3))
                    atomsSubstrates = [atomsSubstrates strtrim(mappedFile{begmol(j) + 4 + k}(32:33))];
                end
            end
            atomsProducts = [];
            for j = noOfsubstrates + 1:noOfsubstrates + noOfproducts
                for k = 1:str2double(mappedFile{begmol(j) + 4}(1:3))
                    atomsProducts = [atomsProducts strtrim(mappedFile{begmol(j) + 4 + k}(32:33))];
                end
            end
            if ~isequal(sort(atomsSubstrates), sort(atomsProducts))
                unbalancedBool(i) = true;
            end
        end
        
        % Rewrite the file
        if ~unbalancedBool(i) && ~inconsistentBool(i)
            fid2 = fopen([rxnDir 'atomMapped' filesep name], 'w');
            fprintf(fid2, '%s\n', mappedFile{:});
            fclose(fid2);
        elseif inconsistentBool(i)
            if ~exist([rxnDir filesep 'atomMapped' filesep 'inconsistent'],'dir')
                mkdir([rxnDir filesep 'atomMapped' filesep 'inconsistent'])
            end
            movefile([rxnDir 'atomMapped' filesep name], ...
                [rxnDir 'atomMapped' filesep 'inconsistent'])
        elseif unbalancedBool(i)
            if ~exist([rxnDir filesep 'atomMapped' filesep 'unbalanced'],'dir')
                mkdir([rxnDir filesep 'atomMapped' filesep 'unbalanced'])
            end
            fid2 = fopen([rxnDir 'atomMapped' filesep 'unbalanced' filesep name], 'w');
            fprintf(fid2, '%s\n', mappedFile{:});
            fclose(fid2);
            delete([rxnDir 'atomMapped' filesep name])
        end
        
        if oBabelInstalled
            
            % Get rinchis
            command = [obabelCommand ' -irxn ' [rxnDir 'unMapped' filesep rxnsToAM{i}] '.rxn -orinchi'];
            [~, result] = system(command);
            if ~any(contains(result, '0 molecules converted'))
                result = split(result);
                atomMappingReport.rinchi{i, 1} = [result{~cellfun(@isempty, ...
                    regexp(result, 'RInChI='))} ' - ' rxnsToAM{i}];
            end
            
            % Get rsmi
            command = [obabelCommand ' -irxn ' [rxnDir 'unMapped' filesep rxnsToAM{i}] '.rxn -osmi'];
            [~, result] = system(command);
            if ~any(contains(result, '0 molecules converted'))
                result = splitlines(result);
                result = split(result{end - 2});
                atomMappingReport.rsmi{i, 1} = result{1};
            end
            
        end
    end
    
    delete([pwd filesep 'tmp.mol'])
    atomMappingReport.rxnFilesWritten = rxnsToAM;
    atomMappingReport.balanced = rxnsToAM(~unbalancedBool);
    atomMappingReport.unbalanced = rxnsToAM(unbalancedBool);
    atomMappingReport.inconsistentBool = rxnsToAM(inconsistentBool);
    atomMappingReport.notMapped = setdiff(rxnsToAM, mappedRxns);
    
else
    atomMappingReport.mappedRxns = [];
end

% fprintf('\n%d reactions were atom mapped\n', length(dir([outputDir 'atomMapped' filesep '*.rxn'])));
% fprintf('%d reactions are not standardised\n', counterUnbalanced);
% fprintf('%d reactions were not mapped\n\n\n', counterNotMapped);
%
% fprintf('RDT algorithm was developed by:\n');
% fprintf('SA Rahman et al.: Reaction Decoder Tool (RDT): Extracting Features from Chemical\n');
% fprintf('Reactions, Bioinformatics (2016), doi: 10.1093/bioinformatics/btw096\n');
end

function newFile = sortMets(mappedFile, substratesMol, substratesFormula, productsMol, productsFormula, outputDir)
% Function to sort the metabolites as in the model's stoichiometry

begmol = strmatch('$MOL', mappedFile);

% Check if bondless atoms were divided
if numel(substratesFormula) ~= numel(substratesMol) || numel(productsFormula) ~= numel(productsMol)
    
    if ~exist([outputDir filesep 'atomMapped' filesep 'inconsistent'],'dir')
        mkdir([outputDir filesep 'atomMapped' filesep 'inconsistent'])
    end
    copyfile([outputDir filesep 'atomMapped' filesep mappedFile{2} '.rxn'], [outputDir filesep 'atomMapped' filesep 'inconsistent'])
    newFile(1:5, 1) = mappedFile(1:5);
else
    
    newFile(1:5, 1) = mappedFile(1:5);
    
    %%% Sort substrates
    [~,idm] = sort(substratesMol);
    [~,ids] = sort(substratesFormula);
    [~,ids] = sort(ids);
    indexes = idm(ids);
    
    % Save each metabolite
    for k = 1:numel(substratesFormula)
        lineInMol = 1;
        eval(sprintf('molS%d{%d} = mappedFile{begmol(%d)};', k, lineInMol, k));
        while ~isequal(strtrim(mappedFile{begmol(k) + lineInMol}), 'M  END') % added strtrim IT 07.10.2021
            eval(sprintf('molS%d{%d + 1} = mappedFile{begmol(%d) + %d};', k, lineInMol, k, lineInMol));
            lineInMol = lineInMol + 1;
        end
        eval(sprintf('molS%d{%d + 1} = ''M  END'';', k, lineInMol))
    end
    % From the start of the mol files
    c = 5;
    for k = 1:numel(substratesFormula)
        eval(sprintf('noOfLines = numel(molS%d);', indexes(k)))
        for j = 1:noOfLines
            c = c + 1;
            eval(sprintf('newFile{%d} = molS%d{%d};', c, indexes(k), j))
        end
    end
    
    %%% Sort products
    [~,idmp] = sort(productsMol);
    [~,idp] = sort(productsFormula);
    [~,idp] = sort(idp);
    indexes = idmp(idp);
    
    for i = numel(substratesFormula) + 1:numel(substratesFormula) + numel(productsFormula)
        lineInMol=1;
        eval(sprintf('molP%d{%d} = mappedFile{begmol(%d)};', i - numel(substratesFormula), lineInMol, i));
        while ~isequal(strtrim(mappedFile{begmol(i) + lineInMol}), 'M  END')% added strtrim IT 07.10.2021
            eval(sprintf('molP%d{%d + 1} = mappedFile{begmol(%d) + %d};', i - numel(substratesFormula), lineInMol, i, lineInMol));
            lineInMol = lineInMol + 1;
        end
        eval(sprintf('molP%d{%d + 1} = ''M  END'';', i - numel(substratesFormula), lineInMol))
    end
    for i = numel(substratesFormula) + 1:numel(substratesFormula) + numel(productsFormula)
        molName = regexprep(productsFormula{i - numel(substratesFormula)}, '\[|\]', '_');
        eval(sprintf('noOfLines = numel(molP%d);', indexes(i - numel(substratesFormula))))
        for j = 1:noOfLines
            c = c + 1;
            eval(sprintf('newFile{%d} = molP%d{%d};', c, indexes(i - numel(substratesFormula)), j))
        end
    end
end
end

function mappedRxns = transportRxnAM(rxnDir, outputDir)
% This function atom maps the transport reactions for a given directory in
% MDL RXN file format.
%
% USAGE:
%
% mappedRxns = transportRxnAM(rxnDir, outputDir)
%
% INPUTS:
%    rxnDir:               Path to directory that contains the RXN files
%                          (default: current directory).
%
% OPTIONAL INPUTS:
%    outputDir:            Path to directory that will contain the atom
%                          mapped transport reactions (default: current
%                          directory).
%
% OUTPUTS:
%    mappedRxns:           List of missing MOL files atom mapped transport
%                          reactions.

rxnDir = [regexprep(rxnDir,'(/|\\)$',''), filesep]; % Make sure input path ends with directory separator
if nargin < 2 || isempty(outputDir)
    outputDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    outputDir = [regexprep(outputDir,'(/|\\)$',''), filesep];
end

% Create directory if it is missing
if exist(outputDir) ~= 7
    mkdir('transportRxnsAM')
end

% Check if the directory is not empty
fnames = dir([rxnDir '*.rxn']);
assert(~isempty(fnames), '''rxnDir'' does not contain RXN files');

c = 0;
for i = 1:length(fnames)
    
    % Read the MOL file
    rxnFile = regexp( fileread([rxnDir fnames(i).name]), '\n', 'split')';
    rxnFormula = rxnFile{4};
    assert(~isempty(rxnFormula), 'There is not a chemical formula.');
    % Check if it is a transport reaction
    rxnFormula = split(rxnFormula, {' -> ', ' <=> '});
    substrates = split(rxnFormula{1}, ' + ');
    substrates = expandMets(substrates);
    products = split(rxnFormula{2}, ' + ');
    products = expandMets(products);
    if isequal(substrates, products)
        
        % Identify the corresponding metabolites in the substrates and
        % products
        begMol = strmatch('$MOL', rxnFile);
        for j = 1:length(begMol)
            if j <= numel(substrates)
                metSubs{j} = regexprep((rxnFile{begMol(j) + 1}), '(\[\w\])', '');
            else
                metProds{j - numel(substrates)} = regexprep((rxnFile{begMol(j) + 1}), '(\[\w\])', '');
            end
        end
        
        % Atom map
        atom = 0;
        for j = 1:numel(metSubs)
            nuOfAtoms = str2double(rxnFile{begMol(j) + 4}(1:3));
            productIdx = strmatch(metSubs{j}, metProds, 'exact');
            for k = 1:nuOfAtoms
                atom = atom + 1;
                switch length(num2str(atom))
                    case 1
                        data2print = ['  ' num2str(atom) '  0  0'];
                    case 2
                        data2print = [' ' num2str(atom) '  0  0'];
                    case 3
                        data2print = [num2str(atom) '  0  0'];
                end
                rxnFile{begMol(j) + 4 + k} = [rxnFile{begMol(j) + 4 + k}(1:60) data2print];
                rxnFile{begMol(productIdx(1) + numel(metSubs)) + 4 + k} = [rxnFile{begMol(productIdx(1) + numel(metSubs)) + 4 + k}(1:60) data2print];
            end
            metProds(productIdx(1)) = {'done'};
        end
        
        % Write the file
        fid2 = fopen([outputDir fnames(i).name], 'w');
        fprintf(fid2, '%s\n', rxnFile{:});
        fclose(fid2);
        
        c = c + 1;
        mappedRxns{c} = regexprep(fnames(i).name, '.rxn', '');
        clear metSubs metProds
        
    end
end

if ~exist('mappedRxns', 'var')
    mappedRxns = [];
end
end

function newMetList = expandMets(metList)

% Check if a metabolite has an number to be expanded
idxsCheck = ~cellfun(@isempty, regexp(metList, ' '));
if any(idxsCheck)
    idx = find(idxsCheck);
    % Add repeated metabolites
    for i = 1:length(idx)
        met2expand = split(metList(idx(i)));
        metList = [metList; repelem(met2expand(2), str2double(met2expand(1)))'];
    end
    metList(idx) = [];
end

% Create the new list with metabolites sorted and without a compartment
newMetList = metList;
newMetList = sort(regexprep(newMetList, '(\[\w\])', ''));

end
