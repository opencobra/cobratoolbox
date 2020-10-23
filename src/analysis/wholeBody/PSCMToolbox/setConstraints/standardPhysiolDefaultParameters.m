% This script creates the IndividualParameters structure which contains
% standard physiological default parameters for the reference man or woman.
%
% Ines Thiele 2016-2019

% needs sex to be defined, otherwise this script will error.

% normal physiological DEFAULT parameters
getOrganWeightFraction;
IndividualParameters.OrgansWeights =  [OrganNames num2cell(OrganWeight) num2cell(OrganWeightFract)];
% these can be personalized if available
IndividualParameters.ID = 'Default';
if strcmp(sex,'male')
    IndividualParameters.bodyWeight = BodyWeight/1000; % in kg % as defined in getOrganWeightFraction.m - ref man
    IndividualParameters.Height = 170; % in cm
    IndividualParameters.sex = 'male'; % alternative female
    
elseif strcmp(sex,'female')
    IndividualParameters.bodyWeight = BodyWeight/1000; % in kg % as defined in getOrganWeightFraction.m - ref woman
    IndividualParameters.Height = 160; % in cm 
    IndividualParameters.sex = 'female'; % alternative female
end
IndividualParameters.HeartRate = 67; % beats per minute
IndividualParameters.StrokeVolume = 80; %ml/beat
%IndividualParameters.StrokeVolume.unit = 'ml/beat';
IndividualParameters.CardiacOutput = IndividualParameters.HeartRate * IndividualParameters.StrokeVolume; % in ml/min = beats/min * ml/beat
IndividualParameters.Hematocrit = 0.4; % 'packed cell volume; normally men: 46%, women: 41%
% creatinine concentration in urine
IndividualParameters.MConUrCreatinineMax = 1.2; % mg/dL Adult males: 0.5�1.2 mg/dL; Adult females: 0.4 � 1.1 mg/dL; http://emedicine.medscape.com/article/2054342-overview
IndividualParameters.MConUrCreatinineMin = 0.5; % mg/dL

% default maximum concetration of a metabolite in blood plasma
IndividualParameters.MConDefaultBc = 20; % uM abretary chosen

% default maximum concetration of a metabolite in csf
IndividualParameters.MConDefaultCSF = 20; % uM abretary chosen

% default maximum concetration of a metabolite in Ur
IndividualParameters.MConDefaultUrMax = 20; % umol/mmolcreatinine abretary chosen
IndividualParameters.MConDefaultUrMin = 0; % umol/mmolcreatinine

% CSF Flow rate
IndividualParameters.CSFFlowRate = 0.35;%ml/min based on Sundstrom 2010, Anal Neurol

% CSF to venous blood flow rate
IndividualParameters.CSFBloodFlowRate = 0.52; % 0.52 ml/min based on Pardridge 2011, Fluids and Barr of CNS

% Urine flow rate
IndividualParameters.UrFlowRate = 2000; %ml/day,
% https://www.healthline.com/health/urine-24-hour-volume

% GFR = Glomerular filtration rate
IndividualParameters.GlomerularFiltrationRate = 90;%ml/min, % 90 - 120 ml/min is reported for healthy range: https://www.nlm.nih.gov/medlineplus/ency/article/007305.htm

% Blood Flow rate per organ
fileNameOrgan = '16_01_26_BloodFlowRatesPercentages.xlsx';
[Numbers, IndividualParameters.bloodFlowData] = xlsread(fileNameOrgan,'BloodFlowPercentage');
% find start of data
for i = 1 : size(IndividualParameters.bloodFlowData,1)
    if length(find(ismember(IndividualParameters.bloodFlowData(i,:),'Blood flow percentage')))>0
        bloodFlowRow = i+1; % next line is sex
        IndividualParameters.bloodFlowRow = bloodFlowRow;
        IndividualParameters.bloodFlowPercCol = find(ismember(IndividualParameters.bloodFlowData(i,:),'Blood flow percentage'));
        IndividualParameters.bloodFlowOrganCol = find(ismember(IndividualParameters.bloodFlowData(i,:),'Organ'));
        break;
    end
end