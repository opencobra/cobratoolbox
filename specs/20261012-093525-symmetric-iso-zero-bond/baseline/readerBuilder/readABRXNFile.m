function [atoms, bonds] = readABRXNFile(rxnfileName, rxnfileDirectory, options)
% Read atom mappings from a MDL rxn file.
%
% USAGE:
%
%    [atoms, bonds] = readABRXNFile(rxnfileName, rxnfileDirectory, options)
%
% INPUT:
%    rxnfileName:         The file name.
%
% OPTIONAL INPUT:
%    rxnfileDirectory:    Path to directory containing the rxnfile. Defaults
%                         to current directory.
%    options:             structure of options, with field:
%
%                           * .readBonds - if true, also read and return the bond table (default = 1)
%
% OUTPUTS:
%    atoms:               Table of atom information, with `p` rows, one for each atom.
%                          * .mets - A `p` x 1 cell array of metabolite identifiers for atoms.
%                          * .elements - A `p` x 1 cell array of element symbols for atoms.
%                          * .metNrs - A `p` x 1 vector containing the numbering of atoms within
%                         each metabolite molfile.
%                          * .atomTransitionNrs - A `p` x 1 vector of atom transition indices.
%                          * .isSubstrate - A `p` x 1 logical array. True for substrates, false for
%                         products in the reaction.
%                          * .instances - A `p` x 1 vector indicating which instance of a repeated metabolite atom `i` belongs to.
%    bonds:                Table of bond information, with `q` rows, one for each bond.
%                          * .mets - A `q` x 1 cell array of metabolite identifiers for bonds.
%                          * .headAtoms - A `q` x 1 vector containing the numbering of the first atom forming the bond within each metabolite.
%                          * .tailAtoms -  A `q` x 1 vector containing the
%                          numbering of the second atom forming the bond within each metabolite.
%                          * .bTypes -  A `q` x 1 vector of the bond
%                          type within each metabolite (1 for a single bond, 2 for a double bond, and 3 for a triple bond).
%                          * .headAtomTransitionNrs -  A `q` x 1 vector of
%                          atom transition indice of the first atom forming
%                          the bond within each metabolite.
%                          * .tailAtomTransitionNrs -  A `q` x 1 vector of
%                          atom transition indice of the second atom forming
%                          the bond within each metabolite.
%                          * .isSubstrate - A `q` x 1 logical array. True for substrates, false for
%                         products in the reaction fpr bonds.
%                          * .instances - A `q` x 1 vector indicating which instance of a repeated metabolite atom `i` belongs to for bonds.
% .. Author: - Hulda S. Haraldsdóttir and Ronan M. T. Fleming, 2022.
% Hadjar Rahou (readBonds)

rxnfileName = regexprep(rxnfileName,'(\.rxn)$',''); % Format inputs and remove rxnfile ending from reaction identifier

if ~exist('rxnfileDirectory','var')
    rxnfileDirectory = pwd;
end
if ~exist('options','var')
    options=[];
end

if ~isfield(options,'readBonds')
    options.readBonds=1;
end
% Make sure input path ends with directory separator
rxnfileDirectory = [regexprep(rxnfileDirectory,'(/|\\)$',''), filesep];

% Read reaction file
rxnFilePath = [rxnfileDirectory rxnfileName '.rxn'];

fileStr = fileread(rxnFilePath); % Read file contents into a string
fileCell = regexp(fileStr, '\$MOL\r?\n', 'split'); % Split file into text blocks

% Get reaction data
headerStr = fileCell{1}; % First block contains reaction data
headerCell = regexp(headerStr, '\r?\n', 'split');

if ~strcmp(headerCell{2}, rxnfileName)
    warning('Reaction identifier in the rxnfile %s.rxn does not match file name.', rxnfileName);
end

rxnFormulaFull = headerCell{4}; % fourth line should contain the reaction formula
rxnFormula = strtrim(regexp(rxnFormulaFull,'<=>|->', 'split'));
leftside = rxnFormula{1};
leftside = strtrim(regexp(leftside, '\+', 'split'));
rightside = rxnFormula{2};
rightside = strtrim(regexp(rightside, '\+', 'split'));

umets = cell(length(leftside) + length(rightside), 1);
s = zeros(length(leftside) + length(rightside), 1);
for i = 1:length(leftside)
    [w1, w2] = strtok(leftside{i});
    if isempty(w2)
        umets{i} = w1;
        s(i) = - 1;
    else
        umets{i} = strtrim(w2);
        s(i) = - str2double(w1);
    end
end
for i = 1:length(rightside)
    [w1,w2] = strtok(rightside{i});
    if isempty(w2)
        umets{i + length(leftside)} = w1;
        s(i + length(leftside)) = 1;
    else
        umets{i + length(leftside)} = strtrim(w2);
        s(i + length(leftside)) = str2double(w1);
    end
end

nReactants = str2double(headerCell{5}(1:3)); % Fifth line is reactant/product line
nProducts = str2double(headerCell{5}(4:6));
if sum(abs(s)) ~= nReactants + nProducts
    hidx = [find(ismember(umets,'h')) strmatch('h[', umets)]; % Atom mapping may not include hydrogen atoms
    s = s(setdiff(1:length(s), hidx));
    umets = umets(setdiff(1:length(umets), hidx));
end

if sum(abs(s)) ~= nReactants + nProducts
    warning('Incorrect reaction formula in the rxnfile %s.', rxnfileName);
end

% Get metabolite data
%for atoms
nAtoms = zeros(size(umets));
aMets = {}; % metabolite identifiers for atoms
aIsSubstrate = []; % true for reactants for atoms
aInstances = []; % order with repetitions for atoms
aElements = {}; % element symbols
aMetNrs = []; % Atom numbers in metabolites
aAtomTransitionNrs = []; % Atom numbers in reaction
%for bonds
nBonds = zeros(size(umets));
bMets={}; %metabolite identifiers for bonds
bHeadAtom=[]; % first Atom number of bond in metabolites
bTailAtom=[]; % second Atom number of bond in metabolites
bTypes=[]; % type of bond in metabolites
bIsSubstrate=[]; % true for reactants for bonds
bInstances=[]; % order with repetitions for bonds
counter = 1;
for i = 1:length(umets)
    id = umets{i};
    rbool = s(i) < 0;
    for j = 1:abs(s(i)) % Molfile is repeated abs(s(j)) times
        counter = counter + 1;
        molStr = fileCell{counter}; % Mol block for metabolite
        molCell = regexp(molStr, '\r?\n', 'split');

        % Guard against $MOL blocks appearing in a different physical order
        % than the substrate/product list parsed from the $RXN header's
        % reaction-formula text line (line 4). This loop assumes positional
        % correspondence between `umets` and `fileCell` blocks; if that
        % assumption is violated (e.g. by an atom-mapping tool or
        % post-processing step that reorders/regenerates $MOL blocks without
        % also reordering the header formula, or vice versa), every atom in
        % the mismatched block is silently mislabelled with the wrong
        % metabolite identifier -- which then corrupts the shared atom/node
        % identity of that metabolite everywhere else it appears in a
        % network built from many such files, not just in this reaction.
        %
        % Block identity is compared to the expected metabolite by their
        % embedded numeric id (e.g. ChEBI number) rather than by exact
        % string equality, since $MOL blocks are conventionally headed by a
        % "CHEBI_<n>"-style comment while `id` may use a different naming
        % convention (e.g. "M_<n>[compartment]"). If either side has no
        % embedded number (e.g. a plain VMH abbreviation with no numeric
        % identifier), the check is skipped rather than raised, since there
        % is then no reliable cross-convention way to validate it here.
        molBlockId = strtrim(molCell{1});
        expectedId = regexprep(id, '\[\w+\]$', ''); % strip trailing compartment tag, e.g. "[e]"
        molNum = regexp(molBlockId, '\d+', 'match', 'once');
        expectedNum = regexp(expectedId, '\d+', 'match', 'once');
        if ~isempty(molNum) && ~isempty(expectedNum) && ~strcmp(molNum, expectedNum)
            error('readABRXNFile:blockOrderMismatch', ...
                ['%s.rxn: $MOL block order does not match the reaction-formula header order.\n', ...
                 'Expected metabolite "%s" at this position (block %d of the file), but the $MOL ', ...
                 'block declares "%s". This means the file''s physical $MOL block order diverges ', ...
                 'from its header text order (line 4) -- every atom in this block would otherwise ', ...
                 'be silently mislabelled as belonging to "%s".'], ...
                rxnfileName, id, counter - 1, molBlockId, id);
        end

        nAtoms(i) = str2double(molCell{4}(1:3)); % Fourth line is counts line. First three characters on the line are the number of atoms.

        for k = (1 + 4):(nAtoms(i) + 4)
            atomStr = molCell{k};

            aMets = [aMets; id];
            aIsSubstrate = [aIsSubstrate; rbool];
            aInstances = [aInstances; j];
            aElements = [aElements; strtrim(atomStr(31:33))];
            aMetNrs = [aMetNrs; (k - 4)];
            aAtomTransitionNrs = [aAtomTransitionNrs; str2double(strtok(atomStr(61:end)))];

        end
        nBonds(i)=str2double(molCell{4}(4:6)); % Fourth line is counts line. Second three characters on the line are the number of bonds.
        for l=(1 + 4 + nAtoms(i)):(nBonds(i) + nAtoms(i)+ 4)
            bondLine = molCell{l};
            headAMetNrs=str2num(bondLine(1:3));
            tailAMetNrs=str2num(bondLine(4:6));
            bType=str2num(bondLine(8:9));
            bMets = [bMets; id];
            bHeadAtom=[bHeadAtom; headAMetNrs ];
            bTailAtom=[bTailAtom; tailAMetNrs];
            bTypes=[bTypes; bType];
            bIsSubstrate = [bIsSubstrate; rbool];
            bInstances = [bInstances; j];

        end

    end
end

aIsSubstrate = logical(aIsSubstrate);

if mod(length(aElements),2)~=0
    fprintf('%s%s%s%s\n',rxnfileName,' ',rxnFormulaFull,' is elementally unbalanced.');
end


%checks specific for atom transitions
if ~all(aAtomTransitionNrs==0)
    if ~all(sort(aAtomTransitionNrs(aIsSubstrate)) == (1:sum(aIsSubstrate))')
        warning([rxnfileName, '.rxn, Substrate transition numbers not ordered 1:q.\n'])
    end
    if ~all(all(sort(aAtomTransitionNrs(~aIsSubstrate)) == (1:sum(~aIsSubstrate))'))
        warning([rxnfileName, '.rxn, Product transition numbers not ordered 1:q.\n'])
    end
    if ~all(sort(aAtomTransitionNrs(aIsSubstrate)) == sort(aAtomTransitionNrs(~aIsSubstrate)))
       % warning([rxnfileName, '.rxn, Substrate and product transition numbers not matching order 1:q.\n'])
        warning('Reaction file: %s.rxn, Substrate and product transition numbers not matching order 1:q.\n', rxnfileName)
    end

    nAtomTransitions = max(aAtomTransitionNrs);
    matchingElementBool=false(nAtomTransitions,1);
    for i=1:nAtomTransitions
        if strcmp(aElements(aAtomTransitionNrs==i & aIsSubstrate),aElements(aAtomTransitionNrs==i & ~aIsSubstrate))
            matchingElementBool(i)=1;
        end
    end
    if ~all(matchingElementBool)
        fprintf('%s%s%s%s%u%s\n',rxnfileName,' ',rxnFormulaFull,' contains ', nnz(~matchingElementBool), ' atom transitions violating elemental conservation.');
    end
end

%Create a table of atoms with the following variables: mets, elements,
%metNrs, atomTransitionNrs, isSubstrate,instances
atoms=table(aMets, aElements, aMetNrs, aAtomTransitionNrs, aIsSubstrate , aInstances,'VariableNames',{'mets','elements','metNrs','atomTransitionNrs','isSubstrate','instances'});
if  options.readBonds
    %Create a table of bonds with the following variables: bMets, headAtoms, tailAtoms, bTypes, isSubstrate,instances
    bonds=table(bMets, bHeadAtom, bTailAtom, bTypes, bIsSubstrate, bInstances, 'VariableNames',{'mets','headAtoms','tailAtoms','bTypes','isSubstrate','instances'});
else
    bonds=([]);
end
%Add tailAtomTransitionNrs and headAtomTransitionNrs to bonds
nAllBonds=size(bonds,1);
bonds.headAtomTransitionNrs=zeros(nAllBonds,1);
bonds.tailAtomTransitionNrs=zeros(nAllBonds,1);
% Lookup built once, keyed by (met, metNr, instance), replacing the previous
% per-bond, per-column find(...&ismember(...)) linear scans over the whole
% atoms table (feature 022-eliminate-table-object-hotspots, FR-001). Values
% accumulate every matching row index rather than overwriting, so a
% duplicate key (an existing-invariant violation) still reaches the same
% atoms.atomTransitionNrs(idx)/atoms.elements(idx) expression below with a
% multi-element idx, reproducing today's exact size-mismatch error instead
% of silently picking a different match.
atomIndexMap = containers.Map('KeyType','char','ValueType','any');
for r = 1:height(atoms)
    key = sprintf('%s\x1f%d\x1f%d', atoms.mets{r}, atoms.metNrs(r), atoms.instances(r));
    if isKey(atomIndexMap, key)
        atomIndexMap(key) = [atomIndexMap(key), r];
    else
        atomIndexMap(key) = r;
    end
end
for i=1:nAllBonds
    headKey = sprintf('%s\x1f%d\x1f%d', bonds.mets{i}, bonds.headAtoms(i), bonds.instances(i));
    tailKey = sprintf('%s\x1f%d\x1f%d', bonds.mets{i}, bonds.tailAtoms(i), bonds.instances(i));
    if isKey(atomIndexMap, headKey), headIdx = atomIndexMap(headKey); else, headIdx = []; end
    if isKey(atomIndexMap, tailKey), tailIdx = atomIndexMap(tailKey); else, tailIdx = []; end
    bonds.headAtomTransitionNrs(i)=atoms.atomTransitionNrs(headIdx);
    bonds.tailAtomTransitionNrs(i)=atoms.atomTransitionNrs(tailIdx);
    bonds.headAtomElements(i)=atoms.elements(headIdx);
    bonds.tailAtomElements(i)=atoms.elements(tailIdx);
end
%Reorder the variables in bonds
oldvariables = bonds.Properties.VariableNames;
newvariables = {'mets','headAtoms','tailAtoms','bTypes','headAtomElements','tailAtomElements','headAtomTransitionNrs','tailAtomTransitionNrs','isSubstrate','instances'};
[~,idx] = ismember(newvariables,oldvariables);
bonds = bonds(:,idx);