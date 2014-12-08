function [atomMets,elements,metNrs,rxnNrs,reactantBool,instances,rxnPairs] = readAtomMappingFromRxnFile(rxn,rxnFileDir)

% Format inputs
rxn = regexprep(rxn,'(\.rxn)$',''); % Remove rxnfile ending from reaction identifier

if nargin < 2 || isempty(rxnFileDir)
    rxnFileDir = '';
else
    rxnFileDir = [regexprep(rxnFileDir,'(/|\\)$',''), filesep]; % Make sure input path ends with directory separator
end

% Read reaction file
rxnFilePath = [rxnFileDir rxn '.rxn'];
fileStr = fileread(rxnFilePath); % Read file contents into a string
fileCell = regexp(fileStr,'\$MOL\r?\n','split'); % Split file into text blocks

% Get reaction data
if strcmp(rxn,'3AIBtm (Case Conflict)')
    rxn = '3AIBTm';
end

headerStr = fileCell{1}; % First block contains reaction data
headerCell = regexp(headerStr,'\r?\n','split');

if ~strcmp(headerCell{2},rxn)
    warning('Reaction identifier in the rxnfile %s.rxn does not match file name.',rxn);
end

rxnFormula = headerCell{4}; % fourth line should contain the reaction formula
rxnFormula = strtrim(regexp(rxnFormula,'<=>|->','split'));
leftside = rxnFormula{1};
leftside = strtrim(regexp(leftside,'\+','split'));
rightside = rxnFormula{2};
rightside = strtrim(regexp(rightside,'\+','split'));

mets = cell(length(leftside) + length(rightside),1);
s = zeros(length(leftside) + length(rightside),1);
for i = 1:length(leftside)
    [w1,w2] = strtok(leftside{i});
    if isempty(w2)
        mets{i} = w1;
        s(i) = -1;
    else
        mets{i} = strtrim(w2);
        s(i) = -str2double(w1);
    end
end
for i = 1:length(rightside)
    [w1,w2] = strtok(rightside{i});
    if isempty(w2)
        mets{i + length(leftside)} = w1;
        s(i + length(leftside)) = 1;
    else
        mets{i + length(leftside)} = strtrim(w2);
        s(i + length(leftside)) = str2double(w1);
    end
end

nReactants = str2double(headerCell{5}(1:3)); % Fifth line is reactant/product line
nProducts = str2double(headerCell{5}(4:6));
if sum(abs(s)) ~= nReactants + nProducts
    hidx = [find(ismember(mets,'h')) strmatch('h[',mets)]; % Atom mapping may not include hydrogen atoms
    s = s(setdiff(1:length(s),hidx));
    mets = mets(setdiff(1:length(mets),hidx));
end

if sum(abs(s)) ~= nReactants + nProducts
    warning('Incorrect reaction formula in the rxnfile %s.',fileName);
end

% Get metabolite data
nAtoms = zeros(size(mets));

atomMets = {}; % metabolite identifiers
reactantBool = []; % true for reactants
instances = []; % order with repetitions
elements = {}; % element symbols
metNrs = []; % Atom numbers in metabolites
rxnNrs = []; % Atom numbers in reaction

counter = 1;
for i = 1:length(mets)
    id = mets{i};
    rbool = s(i) < 0;
    
    for j = 1:abs(s(i)) % Molfile is repeated abs(s(j)) times
        counter = counter + 1;
        molStr = fileCell{counter}; % Mol block for metabolite
        molCell = regexp(molStr,'\r?\n','split');
        %assert(strcmp(strtrim(molCell{1}),regexprep(id,'(\[\w\])$','')),'Metabolite identifiers do not match.'); % First line should be metabolite id without compartment assignment
        
        nAtoms(i) = str2double(molCell{4}(1:3)); % Fourth line is counts line. First three characters on the line are the number of atoms.
        
        for k = (1 + 4):(nAtoms(i) + 4)
            atomStr = molCell{k};
            
            atomMets = [atomMets; id];
            reactantBool = [reactantBool; rbool];
            instances = [instances; j];
            elements = [elements; strtrim(atomStr(31:33))];
            metNrs = [metNrs; (k - 4)];
            rxnNrs = [rxnNrs; str2double(strtok(atomStr(61:end)))];
            
        end
    end
end

reactantBool = logical(reactantBool);
assert(all(sort(rxnNrs(reactantBool)) == (1:sum(reactantBool))'),'Reaction file %s.rxn could not be parsed for atom mappings.\n',rxn)
assert(all(sort(rxnNrs(~reactantBool)) == (1:sum(~reactantBool))'),'Reaction file %s.rxn could not be parsed for atom mappings.\n',rxn)
assert(all(sort(rxnNrs(reactantBool)) == sort(rxnNrs(~reactantBool))),'Reaction file %s.rxn could not be parsed for atom mappings.\n',rxn)

rxnPairs = sparse(sum(nAtoms),sum(reactantBool)^2);
rPairCount = 1;

for i = find(s < 0)'
    rid = mets{i};
    
    for j = 1:abs(s(i))
        rRxnNrs = rxnNrs(strcmp(atomMets,rid) & instances == j);
        
        for k = find(s > 0)'
            pid = mets{k};
            
            for l = 1:s(k)
                pRxnNrs = rxnNrs(strcmp(atomMets,pid) & instances == l);
                
                pairRxnNrs = intersect(rRxnNrs,pRxnNrs);
                
                if ~isempty(pairRxnNrs)
                    rMetNrs = metNrs(ismember(rxnNrs,pairRxnNrs) & reactantBool);
                    [~,xi] = sort(rxnNrs(ismember(rxnNrs,pairRxnNrs) & ~reactantBool));
                    pMetNrs = rMetNrs(xi);
                    
                    if strcmp(regexprep(rid,'(\[\w\])$',''),regexprep(pid,'(\[\w\])$',''))
                        if ~all(pMetNrs == rMetNrs)
                            pMetNrs = rMetNrs;
                            rxnNrs(ismember(rxnNrs,pairRxnNrs) & ~reactantBool) = rxnNrs(ismember(rxnNrs,pairRxnNrs) & reactantBool);
                        end
                    end
                    
                    rxnPairs(ismember(rxnNrs,pairRxnNrs) & reactantBool,rPairCount) = rMetNrs;
                    rxnPairs(ismember(rxnNrs,pairRxnNrs) & ~reactantBool,rPairCount) = pMetNrs;
                    
                    rPairCount = rPairCount + 1;
                    
                end
            end
        end
    end
end

rxnPairs = rxnPairs(:,any(rxnPairs));

