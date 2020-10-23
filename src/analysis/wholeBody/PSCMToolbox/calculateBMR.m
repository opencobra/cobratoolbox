function BMR = calculateBMR(sex, weight, height, age)
% This function calculates the basal metabolic rate using the
% phenomenological model proposed by Harris-Benedict and derivations
% thereof (see below.
% Please also refer to the corresponding wikipedia entry:
% https://en.wikipedia.org/wiki/Harris%E2%80%93Benedict_equation for more
% details
% 
% function BMR = calculateBMR(sex, weight, height, age)
% 
% INPUT
% sex    'male' or 'female'
% weight    in kg
% height    in cm
% age       in years
%
% OUTPUT
% BMR       array with 3 numbers calculated based on 
%                1. original Harris Benedict equations [1],[2]
%                2. Harris Benedict equations revised by Roza and Shizgal in 1984.[3]
%                3. The Harris Benedict equations revised by Mifflin and St Jeor in 1990:[4]
%
% References:
% [1]    Harris JA, Benedict FG (1918). "A Biometric Study of Human Basal Metabolism". Proceedings of the National Academy of Sciences of the United States of America. 4 (12): 370?3. doi:10.1073/pnas.4.12.370. PMC 1091498?Freely accessible. PMID 16576330.
% [2]    A Biometric Study of Basal Metabolism in Man. J. Arthur Harris and Francis G. Benedict. Washington, DC: Carnegie Institution, 1919.
% [3]    Roza AM, Shizgal HM (1984). "The Harris Benedict equation reevaluated: resting energy requirements and the body cell mass". The American Journal of Clinical Nutrition. 40 (1): 168?82. PMID 6741850.
% [4]    Mifflin MD, St Jeor ST, Hill LA, Scott BJ, Daugherty SA, Koh YO (1990). "A new predictive equation for resting energy expenditure in healthy individuals". The American Journal of Clinical Nutrition. 51 (2): 241?7. PMID 2305711.
%
% Ines Thiele 01/2018

%% The original Harris-Benedict equations published in 1918 and 1919.
if strcmp(sex,'male') || strcmp(sex,'Male')
    % BMR = 66.5 + ( 13.75 × weight in kg ) + ( 5.003 × height in cm ) ? ( 6.755 × age in years )
    BMR(1,1) = 66.5 + ( 13.75 *weight ) + ( 5.003 * height) - ( 6.755 * age);
else % female
    %   BMR = 655.1 + ( 9.563 × weight in kg ) + ( 1.850 × height in cm ) ? ( 4.676 × age in years )
    BMR(1,1) = 655.1 + ( 9.563 * weight  ) + ( 1.850 * height  ) - ( 4.676 * age );
end

%% The Harris?Benedict equations revised by Roza and Shizgal in 1984.[3]
%
if strcmp(sex,'male')|| strcmp(sex,'Male')
    % Men	BMR = 88.362 + (13.397 × weight in kg) + (4.799 × height in cm) - (5.677 × age in years)
    BMR(2,1) = 88.362 + (13.397 * weight ) + (4.799 * height ) - (5.677 * age);
else % female
    % Women	BMR = 447.593 + (9.247 × weight in kg) + (3.098 × height in cm) - (4.330 × age in years)
    BMR(2,1) = 447.593 + (9.247 * weight ) + (3.098 * height ) - (4.330 * age );
end
% The 95% confidence range for men is ±213.0 kcal/day, and ±201.0 kcal/day for women.
%
%% The Harris?Benedict equations revised by Mifflin and St Jeor in 1990:[4]
%
if strcmp(sex,'male')|| strcmp(sex,'Male')
    % Men	BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + 5
    BMR(3,1) = (10 * weight ) + (6.25 * height ) - (5 * age ) + 5;
else % female
    % Women	BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) - 161
    BMR(3,1) = (10 * weight ) + (6.25 * height ) - (5 * age ) -161;
end

