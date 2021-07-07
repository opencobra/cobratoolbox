function mappedRxns = transportRxnAM(rxnDir, outputDir)
% This function atom maps the transport reactions for a given director in 
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
