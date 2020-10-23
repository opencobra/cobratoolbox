% annotate OrganAtlas
load('OrganAtlas_Harvetta_2.mat')

annotateRxns = 1;
annotateMets = 1;
 
O = fieldnames(OrganCompendium_female);
for i = 1 : length(O)
    if ~(strcmp(O{i},'sex')) && ~(strcmp(O{i},'Recon3DHarvey'))
        O{i}
        modelID = strcat(O{i},'_female');
        modelName = strcat(O{i},'extracted from the female whole body metabolic reconstruction, Harvetta.');
          modelAnnotation = {strcat('This is a metabolic reconstruction of: ', modelID);...
    'Authors: Ines Thiele, NUI Galway, Ireland';...
    'Please cite when using one or more reconstructions from the Organ compendium: Thiele et al.,Molecular Systems Biology, 2020.';...
    'This reconstruction has been extensively curated against experimental data from literature.';...
    'Please contact: ines(dot)thiele(at)nuigalway.ie';...
    'This work is licensed under a <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.'};
             tic;OrganCompendium_female.(O{i}).modelAllComp = annotateModel(OrganCompendium_female.(O{i}).modelAllComp, annotateRxns,annotateMets,modelID,modelName,modelAnnotation);toc;
                     fileNameOut = strcat(O{i},'_female.xml');
      %  writeCbModel(OrganCompendium_female.(O{i}).modelAllComp, 'format', 'sbml', 'fileName', fileNameOut);

    end
end
clearvars -except OrganCompendium_female
save OrganAtlas_Harvetta OrganCompendium_female 
clear

load('OrganAtlas_Harvey_2.mat')

annotateRxns = 1;
annotateMets = 1;
O = fieldnames(OrganCompendium_male);
for i = 1 : length(O)
    if ~(strcmp(O{i},'sex')) && ~(strcmp(O{i},'Recon3DHarvey'))
        O{i}
            modelID = strcat(O{i},'_male');
        modelName = strcat(O{i},'extracted from the male whole body metabolic reconstruction, Harvey.');
  modelAnnotation = {strcat('This is a metabolic reconstruction of: ', modelID);...
    'Authors: Ines Thiele, NUI Galway, Ireland';...
    'Please cite when using one or more reconstructions from the Organ compendium: Thiele et al.,Molecular Systems Biology, 2020.';...
    'This reconstruction has been extensively curated against experimental data from literature.';...
    'Please contact: ines(dot)thiele(at)nuigalway.ie';...
    'This work is licensed under a <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.'};
        tic;OrganCompendium_male.(O{i}).modelAllComp = annotateModel(OrganCompendium_male.(O{i}).modelAllComp, annotateRxns,annotateMets,modelID,modelName,modelAnnotation);toc;
        fileNameOut = strcat(O{i},'_male.xml');
      %  writeCbModel(OrganCompendium_male.(O{i}).modelAllComp, 'format', 'sbml', 'fileName', fileNameOut);

    end
end
clearvars -except OrganCompendium_male
save OrganAtlas_Harvey OrganCompendium_male 