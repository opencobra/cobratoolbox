% annotate Harvey and Harvetta

annotateRxns = 1;
annotateMets = 1;

male = loadPSCMfile('Harvey');
modelID = strcat('Harvey');
modelName = strcat('Male whole body metabolic reconstruction, Harvey.');
modelAnnotation = {strcat('This is a metabolic reconstruction of: ', modelID);...
    'Authors: Ines Thiele, NUI Galway, Ireland';...
    'Please cite when using one or more reconstructions from the Organ compendium: Thiele et al.,Molecular Systems Biology, 2020.';...
    'This reconstruction has been extensively curated against experimental data from literature.';...
    'Please contact: ines(dot)thiele(at)nuigalway.ie';...
    'This work is licensed under a <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.'};
tic;male = annotateModel(male, annotateRxns,annotateMets,modelID,modelName,modelAnnotation);toc;

save Harvey male
clear

female = loadPSCMfile('Harvetta');
annotateRxns = 1;
annotateMets = 1;
modelID = strcat('Harvetta');
modelName = strcat('Male whole body metabolic reconstruction, Harvetta.');
modelAnnotation = {strcat('This is a metabolic reconstruction of: ', modelID);...
    'Authors: Ines Thiele, NUI Galway, Ireland';...
    'Please cite when using one or more reconstructions from the Organ compendium: Thiele et al., Molecular Systems Biology, 2020.';...
    'This reconstruction has been extensively curated against experimental data from literature.';...
    'Please contact: ines(dot)thiele(at)nuigalway.ie';...
    'This work is licensed under a <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.'};
tic;female = annotateModel(female, annotateRxns,annotateMets,modelID,modelName,modelAnnotation);toc;


save Harvetta female