function sortRDTfiles(rxnFile)
% Sort the molecules in the RXN file acording to the chemical formula
% in the 4th line of the RXN file.
%
% USAGE:
%
%    sortRDTfiles(rxnFile)
%
% INPUT:
%    rxnFile:        Name and path of the RXN file to sort.
%
% OUTPUT:
%    A RXN file with sorted molecules.
%
% EXAMPLE: 
%
%    rxnFile = ['rxnFileDir' filesep 'DOPACNNL.rxn'];
%    sortRDTfiles(rxnFile)
%
% .. Author: - German A. Preciat Gonzalez 25/05/2017

rxnFileData = regexp( fileread(rxnFile), '\n', 'split')'; % Read the RXN file
formula = strsplit(rxnFileData{4}, {'->', '<=>'});

substrates = strtrim(strsplit(formula{1}, '+'));
% Check if a metabolite is repeated in the substrates formula
repMetsSubInx = find(~cellfun(@isempty, regexp(substrates, ' ')));
if ~isempty(repMetsSubInx)
    for i = 1:length(repMetsSubInx)
        metRep = strsplit(substrates{repMetsSubInx(i)});
        timesRep = str2double(metRep{1});
        metRep = metRep{2};
        substrates{repMetsSubInx(i)} = strjoin(repmat({metRep}, [1 timesRep]));
    end
    substrates = strsplit(strjoin(substrates));
end

products = strtrim(strsplit(formula{2}, '+'));
% Check if a metabolite is repeated in the products formula
repMetsProInx = find(~cellfun(@isempty, regexp(products, ' ')));
if ~isempty(repMetsProInx)
    for i = 1:length(repMetsProInx)
        metRep = strsplit(products{repMetsProInx(i)});
        timesRep = str2double(metRep{1});
        metRep = metRep{2};
        products{repMetsProInx(i)} = strjoin(repmat({metRep}, [1 timesRep]));
    end
    products = strsplit(strjoin(products));
end


% Check if the molecules in the formula and the RXN file has the same order
begmol = strmatch('$MOL', rxnFileData);
substratesMol = rxnFileData(begmol(1:length(substrates)) + 1)';
productsMol = rxnFileData(begmol(length(substrates) + 1:length(substrates) + ...
    length(products)) + 1)';

% Sort the molecules if the molecules in the formula and the RXN file 
% don't have the same order
if ~isequal(substrates, substratesMol) || ~isequal(products, productsMol)
    
    noOfsubstrates = numel(substrates);
    noOfproducts = numel(products);
    
    % Save the header
    for i = 1:5
        newRXNfile{i} = rxnFileData{i};
    end
    
    endMol='M  END';
    
    %%% Sort substrates
    
    [~,idm] = sort(substratesMol);
    [~,ids] = sort(substrates);
    [~,ids] = sort(ids);
    indexes = idm(ids);
    
    for i = 1:noOfsubstrates
        lineInMol = 1;
        eval(sprintf('molS%d{%d} = rxnFileData{begmol(%d)};', i, lineInMol, i))
        while ~isequal(rxnFileData{begmol(i) + lineInMol}, endMol)
            eval(sprintf('molS%d{%d + 1} = rxnFileData{begmol(%d) + %d};', i, lineInMol, i, lineInMol))
            lineInMol = lineInMol + 1;
        end
        eval(sprintf('molS%d{%d + 1} = endMol;', i, lineInMol))
    end
    c = 5;
    for i = 1:noOfsubstrates
        eval(sprintf('noOfLines = numel(molS%d);', indexes(i)))
        for j = 1:noOfLines
            c = c + 1;
            eval(sprintf('newRXNfile{%d} = molS%d{%d};', c, indexes(i), j))
        end
    end
    
    %%% Sort products
    
    [~,idmp] = sort(productsMol);
    [~,idp] = sort(products);
    [~,idp] = sort(idp);
    indexes = idmp(idp);
    
    for i = noOfsubstrates + 1:noOfsubstrates + noOfproducts
        lineInMol=1;
        eval(sprintf('molP%d{%d} = rxnFileData{begmol(%d)};', i - noOfsubstrates, lineInMol, i))
        while ~isequal(rxnFileData{begmol(i) + lineInMol}, endMol)
            eval(sprintf('molP%d{%d + 1} = rxnFileData{begmol(%d) + %d};', i - noOfsubstrates, lineInMol, i, lineInMol))
            lineInMol = lineInMol + 1;
        end
        eval(sprintf('molP%d{%d + 1} = endMol;', i - noOfsubstrates, lineInMol))
    end
    for i = noOfsubstrates + 1:noOfsubstrates + noOfproducts
        molName = regexprep(products{i - noOfsubstrates}, '\[|\]', '_');
        eval(sprintf('noOfLines = numel(molP%d);', indexes(i - noOfsubstrates)))
        for j = 1:noOfLines
            c = c + 1;
            eval(sprintf('newRXNfile{%d} = molP%d{%d};', c, indexes(i - noOfsubstrates), j))
        end
    end
    
    % Rewrite the RXN file with sorted molecules (newRXNfile)
    fid2 = fopen(rxnFile, 'w');
    fprintf(fid2, '%s\n', newRXNfile{:}); 
    fclose(fid2);
    

end
end
