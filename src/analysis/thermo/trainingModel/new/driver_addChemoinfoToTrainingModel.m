% Generate database

% Clear workspace
clear

% Load training data
load('~/work/sbgCloud/programExperimental/projects/xomics/data/thermoChemicalTrainingModel/trainingModel.mat');

%% Prepare user-defined parameters

currentDirectory = pwd;
options.printlevel = 1;
options.debug = true;
options.standardisationApproach = 'explicitH';
options.adjustToModelpH = false;
options.keepMolComparison = false;
options.onlyUnmapped = true;

%% Function generateChemicalDatabase

dbType = {'inchi'; 'kegg'; 'best'};

for i = 1:size(dbType, 1)
    switch dbType{i}
        case 'kegg'
            model = trainingModel;
            model = rmfield(model, {'inchi', 'inchiBool', 'compositeInchiBool'});
            options.outputDir = [currentDirectory filesep dbType{i}];
            info = generateChemicalDatabase(model, options);
        case 'inchi'
            model = trainingModel;
            model.Inchi = model.inchi.standardWithStereoAndCharge;
            model = rmfield(model, {'metKEGGID', 'inchiBool', 'compositeInchiBool', 'inchi'});
            options.outputDir = [currentDirectory filesep dbType{i}];
            info = generateChemicalDatabase(model, options);
        case 'best'
            model = trainingModel;
            model.Inchi = model.inchi.standardWithStereoAndCharge;
            model = rmfield(model, {'inchiBool', 'compositeInchiBool', 'inchi'});
            options.outputDir = [currentDirectory filesep dbType{i}];
            info = generateChemicalDatabase(model, options);
    end
end
