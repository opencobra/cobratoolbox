function fgffail = testFastGapFill()
%testFastGapFill tests the functionality of FastGapFill
%
% fgffail = testFastGapFill()
%
% OUTPUT
% 
% fgffail   - integer value 0 if success and 1 if failure

%Move to testing folder
oriFolder = pwd;
test_folder = what('testFastGapFill');
cd(test_folder(1).path);

%Specify test files
modelFile='fgf_test_model.xml';
dbFile='fgf_test_rxn_db.lst';
dictFile='fgf_test_dict.tsv';
listCompartments={'[c]'};

fprintf('Testing FastGapFill ...\n');

%Test DB import
dbfail=0;
try
    evalc('U_model = createUniversalReactionModel2(dbFile,[],true);');
catch
    fprintf('Creation of universal reaction model failed\n');
    dbfail=1;
end
if exist('U_model','var')
    rxnCount = length(U_model.rxns);
    metCount = length(U_model.mets);
    if rxnCount ~= 3 || metCount ~= 5
        fprintf('Universal reaction model imported incorrectly\n');
        dbfail=1;
    end
end

%Test dict conversion
dictfail=0;
if dbfail == 0
    file_handle = fopen(dictFile);
    u = textscan(file_handle,'%s\t%s');
    dictionary = {};
    for i = 1:length(u{1})
        dictionary{i,1} = u{1}{i};
        dictionary{i,2} = u{2}{i};
    end
    fclose(file_handle);
    try
        evalc('translated_model = transformKEGG2Model(U_model,dictionary);');
    catch
        fprintf('Creation of translated universal model failed\n')
        dictfail=1;
    end
    if exist('translated_model','var')
        if sum(cellfun(@(s) ~isempty(strfind('A[c]', s)), translated_model.mets)) ~= 1
                fprintf('Universal model translated incorrectly\n')
                dictfail=1;
        end
    end
else
    dictfail=1;
end
    
%Test SUX creation
suxfail=0;
evalc('modelFull = readCbModel(modelFile);');
if ~exist('modelFull.subSystems') || length(modelFull.subSystems) ~= length(modelFull.rxnNames)
    modelFull.subSystems = repmat({''},length(modelFull.rxnNames));
end
if ~exist('modelFull.genes')
    modelFull.genes = repmat({'no_gene'},1);
end
if ~exist('modelFull.rxnGeneMat')
    modelFull.rxnGeneMat = zeros(length(modelFull.rxnNames),1);
end
if ~exist('modelFull.grRules')
    modelFull.grRules = repmat({''},length(modelFull.rxnNames));
end
evalc('[modelConsistent, ~] = identifyBlockedRxns(modelFull,1e-4);');

if dictfail == 0
    try
        evalc('MatricesSUX=generateSUXComp(modelConsistent,dictionary,dbFile,[],listCompartments);');
    catch
        fprintf('Creation of SUX model failed\n');
        suxfail=1;
    end
    if exist('MatricesSUX','var')
        rxnCount = length(MatricesSUX.rxns);
        metCount = length(MatricesSUX.mets);
        if rxnCount ~= 23 || metCount ~= 14
            fprintf('SUX model created incorrectly\n');
            suxfail=1;
        end
    end
else
    suxfail=1;
end

%Test full FastGapFill
fgffail=0;
if (~dbfail && ~dictfail && ~suxfail)
    try
        evalc('[AddedRxns]=submitFastGapFill(modelFile,dbFile,dictFile,[],[],true,[],[],listCompartments);');
    catch
        fprintf('Exception caused FastGapFill to exit.\n');
        fgffail=1;
    end
    %Look for RXN1013 in solution, which fills test model gap
    if exist('AddedRxns','var')
        if sum(cellfun(@(s) ~isempty(strfind('RXN1013', s)), AddedRxns.rxns)) ~= 1
            fprintf('FastGapFill failed to find gap solution.\n')
            fgffail=1;
        end
    end
else
    fgffail=1;
end

if fgffail == 0
    fprintf('success.\n')
else
    fprintf('failure.\n')
end

try
    delete matlab.mat;
catch
end
try
    delete KEGGMatrix.mat;
catch
end

cd(oriFolder);

end

