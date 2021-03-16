% The COBRAToolbox: testReconMap.m
%
% Purpose:
%     - tests the functionality of ReconMap to submit a minerva layout.
%       This is done using a test account, that only has 1 layout available
%       the responsewill always be that a layout with that name already exists.
%
% Authors:
%     - Original file: Alberto Noronha 21/03/2017
%

%TODO, this needs to be fixed
if 1
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReconMap'));
cd(fileDir);

% load the ecoli core model
model = getDistributedModel('ecoli_core_model.mat');

% Get the minerva structure
load('minerva.mat');

prepareTest('needsWebAddress','https://www.vmh.life/minerva/')

% check if the URL exists
% Set the user to testing user
oldLogin = minerva.login;
oldPassword = minerva.password;

minerva.login = 'cobratoolbox-test';
minerva.password = 'test';
minerva.googleLicenseConsent = 'true';

% FBA solution for flux distribution
changeCobraSolver('glpk', 'LP');
FBAsolution = optimizeCbModel(model, 'max');

% Send the flux distribution to MINERVA
response = buildFluxDistLayout(minerva, model, FBAsolution, 'Test - Flux distribution 1');

% 2 Correct responses, either successful or layout exists already
%assert(~isempty(regexp(response, strcat('"creator":"', minerva.login, '"'))) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));
assert(strcmp(response,'Overlay generated successfully.'));

% Send the subsystem layout to MINERVA
response = generateSubsytemsLayout(minerva, model, 'Pyruvate metabolism', '#6617B5');

% Same as before - two possible correct responses
%assert(~isempty(regexp(response, strcat('"creator":"', minerva.login, '"'))) | ~isempty(regexp(response, 'ERROR. Layout with given identifier ("Pyruvate metabolism") already exists.')));
assert(strcmp(response,'Overlay generated successfully.'));

minerva.login = oldLogin;
minerva.password = oldPassword;

% change the directory
cd(currentDir)
else
    assert(1==1)
    load('Recon3DModel_301.mat')
    load('minerva.mat')
    minerva.minervaURL = 'http://www.vmh.life/minerva/index.xhtml';
    minerva.map = 'ReconMap-3';
    minerva.login = 'ronan.fleming';
    minerva.password = 'ronan.fleming1';
    minerva.googleLicenseConsent = 'true';
    
    organID2= (find(~cellfun(@isempty,strfind(model.subSystems,'Glycolysis/gluconeogenesis'))));
    
    V = sign(rand(length(organID2),1)-0.5);
    
    R = model.rxns(organID2);
    R = strcat('R_',R);

    clear content
    
    Color1 = '#EB254C'; % red
    
    Color2 = '#3825EB'; % blue
    
    content = 'name%09reactionIdentifier%09lineWidth%09color%0D';
    
    thickness = 3;

    for i = 1: length(V)   
        if V(i) == -1
            line = strcat('%09', R{i}, '%09', num2str(thickness), '%09', Color2, '%0D');
            content = strcat(content, line);
        elseif V(i) == 1
            line = strcat('%09', R{i}, '%09', num2str(thickness), '%09', Color1, '%0D');
            content = strcat(content, line);
        end
    end
    
    serverResponse = buildFluxDistLayout(minerva, model, 0, 'Glycolysis/gluconeogenesis','#EB254C',5,content)
end
