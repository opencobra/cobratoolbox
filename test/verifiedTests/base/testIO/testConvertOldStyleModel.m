% The COBRAToolbox: testConvertOldStyleModel.m
%
% Purpose:
%     - testConvertOldStyleModel tests, whether a model containing new style fields stays unchanged by the model conversion,
%       and whether an old style models FieldNames change and get replaced.
%       It also tests, whether an old style models fields get merged to
%       potentially existing new Style fields.
%
% Authors:
%     - Thomas Pfau

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertOldStyleModel'));
cd(fileDir);

% Test with 
fprintf('>> Testing Model conversion and field merging:\n');
%Explicitly load the model by load to ensure that its an old style model
%that we can convert.
load('Abiotrophia_defectiva_ATCC_49176','model')

convertedFields = {'metHMDB','metSmile','metInchiString','confidenceScores','ecNumbers','rxnKeggID','metKeggID'};
newFields = {'metHMDBID','metSmiles','metInChIString','rxnConfidenceScores','rxnECNumbers','rxnKEGGID','metKEGGID'};
%There are multiple old style fields.
for i = 1:numel(convertedFields)
    assert(isfield(model,convertedFields{i}));
end
modelnew = convertOldStyleModel(model);
%check that they are removed.
for i = 1:numel(convertedFields)
    assert(~isfield(modelnew,convertedFields{i}));
end
%and that the new ones are containing the old data
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end


model.metHMDBID = {'Lets','Test','Something'};

modelnew = convertOldStyleModel(model);
convertedFields = {'metSmile','metInchiString','confidenceScores','ecNumbers','rxnKeggID','metKeggID'};
newFields = {'metSmiles','metInChIString','rxnConfidenceScores','rxnECNumbers','rxnKEGGID','metKEGGID'};
retainedFields = {'metHMDBID','metHMDB'};
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end
for i = 1:numel(retainedFields)
    assert(all(cellfun(@(x,y) isequal(x,y), model.(retainedFields{i}), modelnew.(retainedFields{i}))));
end
newHMDBIDs = cellfun(@num2str, num2cell(1:numel(model.mets)),'UniformOutput',0);
model.metHMDB = newHMDBIDs;

modelnew = convertOldStyleModel(model);
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end
assert(all(cellfun(@(x,y) isequal(x,y), modelnew.metHMDBID,model.metHMDBID)));
randpos = randi(numel(model.mets),20,1);
newHMDBIDs(randpos) = {''};
model.metHMDBID = newHMDBIDs;
modelnew = convertOldStyleModel(model);
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end

assert(all(cellfun(@(x,y) isequal(x,y), modelnew.metHMDBID(randpos),model.metHMDB(randpos))));
newpos = setdiff(1:numel(model.mets),randpos);
assert(all(cellfun(@(x,y) isequal(x,y), modelnew.metHMDBID(newpos),model.metHMDBID(newpos))));
% change the directory
cd(currentDir)
