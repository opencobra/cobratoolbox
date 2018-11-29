% The COBRAToolbox: testMIRIAMAnnotation.m
%
% Purpose:
%     - testMIRIAMAnnotation tests the addMIRIAMAnnotation, and
%     getMIRIAMAnnotation functions. By testing whether newly added
%     annotations show up in the obtained annotations.
%     - It also tests the get/set/addAnnotation functions to see, whether
%     they work as expected.
%
% Authors:
%     - Thomas Pfau Jun 2018

global CBT_MISSING_REQUIREMENTS_ERROR_ID

% save the current path
currentDir = pwd;

model = getDistributedModel('ecoli_core_model.mat');


% this test can fail if no internet connection is present.
try
    dbs = getRegisteredDatabases();
catch
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, strjoin('Could not get the data from identifiers.org. Check your internet Connection.'));
end

errorMessage = sprintf('The following databases are not defined on identifiers.org:\n%s',strjoin({'NonExistentDB'},'\n'));
% add an invalid annotation to the model
assert(verifyCobraFunctionError('addMIRIAMAnnotations','inputs',{model,model.rxns(1),'NonExistentDB','blubb'},'testMessage',errorMessage))

% try to add an invalid ID
assert(verifyCobraFunctionError('addMIRIAMAnnotations','inputs',{model,model.rxns(1),'brenda','blubb'}))

% now, we will add a valid brenda ID
assert(~isfield(model,'rxnisbrendaID'));
validBrendaID = '1.2.3.4';
modelWithID = addMIRIAMAnnotations(model,model.rxns(1),'brenda',validBrendaID);
assert(isfield(modelWithID,'rxnisbrendaID'));
assert(all(strcmp(modelWithID.rxnisbrendaID(2:end),'')));
assert(strcmp(modelWithID.rxnisbrendaID{1},validBrendaID));
additionalIDs = {validBrendaID, '2.3.4.5', '5.6.7.8'};

% add multiple additional IDs (we need the ID 3 times.
modelWithID = addMIRIAMAnnotations(modelWithID,repmat(model.rxns(1),3,1),'brenda',additionalIDs);
assert(isempty(setxor(strsplit(modelWithID.rxnisbrendaID{1},'; '),additionalIDs)));
assert(length(strsplit(modelWithID.rxnisbrendaID{1},'; ')) == 3);

% lets add the ids again and see, that it did nmot change.
modelWithID = addMIRIAMAnnotations(modelWithID,repmat(model.rxns(1),3,1),'brenda',additionalIDs);
assert(isempty(setxor(strsplit(modelWithID.rxnisbrendaID{1},'; '),additionalIDs)));
assert(length(strsplit(modelWithID.rxnisbrendaID{1},'; ')) == 3);

% now, replace the annotation by the validBrendaID
modelWithID = addMIRIAMAnnotations(modelWithID,model.rxns(1),'brenda',validBrendaID,'replaceAnnotation',true);
assert(strcmp(modelWithID.rxnisbrendaID{1},validBrendaID));

% repeat the addition of all
modelWithID = addMIRIAMAnnotations(modelWithID,repmat(model.rxns(1),3,1),'brenda',additionalIDs);

% and lets test getMIRIAMAnnotations
annotations = getMIRIAMAnnotations(model,'referenceField','rxn','ids',model.rxns(1));

% this is all empty. There are no terms on the basic model.
assert(isempty(annotations.cvterms))

% now check that the Brenda Terms are correct
annotations = getMIRIAMAnnotations(modelWithID,'ids',model.rxns(1));
assert(strcmp(annotations.cvterms(1).qualifier,'is'))
assert(strcmp(annotations.cvterms(1).qualifierType,'bioQualifier'))

% it contains all those IDs.
assert(isempty(setxor({annotations.cvterms(1).ressources(:).id},additionalIDs)));

% and its the brenda database
assert(all(strcmp({annotations.cvterms(1).ressources(:).database},'brenda')));

% now, also check, whether we can add ,model annotations
modelWithID = addMIRIAMAnnotations(modelWithID,'','bigg.model','iJO1366','referenceField','model'); %This adds a bioModifier
modelWithID = addMIRIAMAnnotations(modelWithID,'','bigg.model','iJO1366','referenceField','model',...
                                   'annotationTypes','model','annotationQualifiers','isDerivedFrom'); %This adds a bioModifier
                              
assert(isfield(modelWithID,'modelbisbigg__46__modelID'));
assert(strcmp(modelWithID.modelbisbigg__46__modelID, 'iJO1366'));

annotations = getMIRIAMAnnotations(modelWithID,'referenceField','model');
isDerivedFromPos = ismember({annotations.cvterms.qualifier},'isDerivedFrom');

% this is a model qualifier
assert(strcmp(annotations.cvterms(isDerivedFromPos).qualifierType,'modelQualifier')) 

% and is named iJO1366
assert(strcmp(annotations.cvterms(isDerivedFromPos).ressources.id,'iJO1366')) 

% the other is a bioQualifier.
assert(strcmp(annotations.cvterms(~isDerivedFromPos).qualifierType,'bioQualifier')) 

% and also named iJO1366
assert(strcmp(annotations.cvterms(~isDerivedFromPos).ressources.id,'iJO1366')) 

% now, test the annotation functions 
modelWithModelID = rmfield(modelWithID,'rxnisbrendaID');

% test addition of model annotations via a annotation struct
modelWithID2 = addAnnotations(model,annotations,'referenceField','model');
assert(isSameCobraModel(modelWithModelID,modelWithID2));

% Get the list of annotations for reaction 1
annots = getAnnotations(modelWithID,'brenda',modelWithID.rxns(1:3));
% no annotations for the second and third element
assert(isempty(annots{2}) && isempty(annots{3}))
% proper annotation for the first element (i.e. all annotations are there.
assert(isempty(setxor(strsplit(annots{1},'; '), additionalIDs)));

% get output as a cell array of cell arrays
annots = getAnnotations(modelWithID,'brenda',modelWithID.rxns(1:3),'resultType','cellList');
assert(isempty(annots{2}) && isempty(annots{3}))
% no difference in the order.
assert(isempty(setxor(annots{1}, additionalIDs)));

% test qualifiers correct
[annots,qualifiers] = getAnnotations(modelWithID,'brenda',modelWithID.rxns{1});
assert(numel(strsplit(qualifiers,'; ')) == 3 && all(strcmp(strsplit(qualifiers,'; '),'is')));

% test addition
modelWithID = addAnnotations(modelWithID,'1.2.3.4','annotationQualifier','isDescribedBy','database','brenda','ids',modelWithID.rxns{1});
assert(isfield(modelWithID,'rxnisDescribedBybrendaID'))
assert(strcmp(modelWithID.rxnisDescribedBybrendaID{1},'1.2.3.4'))

% retrieve the additional (in addition to existing ones)
[annots,qualifiers] = getAnnotations(modelWithID,'brenda',modelWithID.rxns{1},'resultType','celllist','qualifier',getBioQualifiers());
assert(isempty(setxor(annots,additionalIDs)))
assert(numel(annots) == 4)

% 
%Test finished.
fprintf('>> Done ...\n');