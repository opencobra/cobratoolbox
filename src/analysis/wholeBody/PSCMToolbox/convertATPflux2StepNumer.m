function [Energy_kJ,Energy_kcal,Meter,StepNumber] = convertATPflux2StepNumber(ATP_hydrolysis_flux, sex, weight, height)
% This function converts an ATP hydrolysis flux (e.g., Muscle_DM_atp_c_
% into distance walked and step number). See below for assumptions and
% calculation details
%
% function [Energy_kJ,Energy_kcal,Meter,StepNumber] = convertATPflux2StepNumber(ATP_hydrolysis_flux, sex, weight, height)
% INPUT
% ATP_hydrolysis_flux   Flux value through the Muscle_DM_atp_c_ reaction
% sex                'male' or 'female'
% weight                in kg
% height                in cm
%
% OUTPUT
% Energy_kJ             Energy value in kJ corresponding to the Flux value through the Muscle_DM_atp_c_ reaction
% Energy_kcal           Energy value in kcal corresponding to the Flux value through the Muscle_DM_atp_c_ reaction
% Meter                 Corresponding meter of walking that can be achieved
% StepNumber            Corresponding step number that can be achieved
% 
% Ines Thiele 01/2018

% energy cost of walking (1 step)
% gross energy cost of 3 J/kg/m - taken from https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4879834/
%
% ATP_hydrolysis_flux in mmol/person/day
%
% calculation
% 1 mol ATP = 64KJ based on
% http://www.physiology.org/doi/pdf/10.1152/jappl.1998.85.6.2140, Table 1
% in resting human muscle
Energy_kJ = (ATP_hydrolysis_flux/1000) * 64; %in kJ per person per day
% 1 kJ = 0.239006 kcal
Energy_kcal = Energy_kJ*0.239006; %in kcal per person per day
% 1 meter = 3 J/kg
Meter = Energy_kJ*1000/(3*weight); % per person per day
% stride length - http://didyouknowstuff.blogspot.lu/p/how-many-kilometers-in-10000-steps.html
% Stride length can be measured or calculated:
% Women .413 * height in cm
% Men .415 * height in cm 
if strcmp(sex,'male')
    Stride = 0.415 * height; %in cm
else
    Stride = 0.413 * height; %in cm
end
    
StepNumber = Meter/(Stride/100);

