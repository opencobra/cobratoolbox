%% mk table S3
filename = {'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\AdipocyteReconstruction\AdipocyteStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\AdrenalGlandRecononstruction\AdrenalglandStart.xls'
%'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\BCellReconstuction\BcellStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\BrainReconstruction\BrainStart.xls'
%'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\Cdcells\CD4Start.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ColonReconstruction\ColonStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\Gallbladder Reconstruction\GallBladderStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\HeartReconstruction\HeartStartUp.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\KidneyReconstruction\KidneyStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\LiverReconstruction\LiverStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\LungReconstruction\LungStart.xls'
%'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\MonocyteReconstruction\MonocyteStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\MuscleReconstruction\myocyteStart.xls'
%'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\NkCellsReconstrcution\NkcellStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\PancreasReconstruction\PancreasStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\PlateletReconstruction\PlateletStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ParathyroidReconstruction\ParathyroidglandStart.xls'
%'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\RBCReconstruction\RBCStart.xls'
%'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\RetinaReconstruction\RetinaStart.xls'
%'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\SpinalCordReconstruction\SpinalcordStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\SkinReconstruction\SkinStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\SpleenReconstruction\SpleenStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\StomachReconstruction\StomachStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ThyroidReconstruction\ThyroidglandStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\UrinaryBladderReconstruction\UrinarybladderStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\OvaryReconstruction\OvaryStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\UterusReconstruction\UterusStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\BreastReconstruction\BreastStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\CervixReconstruction\CervixStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\TestisReconstruction\TestisStart.xls'
'Y:\SemiAutomated_Organ_Models\MetabolicUnits\metunits\MetabolicUnits\ProstrateReconstruction\ProstrateStart.xls'
%sIEC
 
};
   



tabS3 = [];
for i=1:length(filename)
  

[num,txt,raw] = xlsread(filename{i,1},'HPA');

if i~=1
    raw(1,:)=[];

end 
if size(raw,2)==8
  raw(:,8)=[];
  i
end  
    
tabS3 = [tabS3; raw];
clear raw
end

% filename = 'C:\Users\maike.aurich\Dropbox\HarveyDraft\SI_material\TableS3.xls';
% 
% csvwrite(filename,tabS3);