% This script reads in the organ file and assign biomass_maintenance coefficient according
% to relative fraction of organs.
%
% Ines Thiele - 2015/2016

% fileNameOrgan = '16_01_29_OrganWeights.xlsx';
% [Numbers, organWeightData] = xlsread(fileNameOrgan,'OrganWeights');
load Numbers_organWeightData_fromxls_16_01_29_OrganWeigths;

% find start of data
for i = 1 : size(organWeightData,1)
    Cols = find(ismember(organWeightData(i,:),'% of body weight'));
    if length(Cols)>0
        if strcmp(sex,'male')
            if  exist('weigth', 'var') && weigth == 100 % 100 kg male
                Col = Cols(3)-2;
            elseif  exist('weigth', 'var') && weigth ==125
                Col = Cols(4)-2;
            else
                Col = Cols(1)-2
            end
        elseif strcmp(sex,'female')
            Col = Cols(2)-2;
        end
    end
    if length(find(ismember(organWeightData(i,1),'Body weight')))>0
        organRow = i+1;
        break;
    end
end

OrganWeightFract = Numbers(2:end,Col)/100; % assumes that the relative organ weights are given in %
OrganWeight = Numbers(2:end,Col-1); % assumes that the organ weights appear in the col before the percentage
OrganNames = organWeightData(organRow:end,1);
BodyWeight = Numbers(1,Col-1); %total body weight is in first row of numbers
ObjectiveComponents = strcat(OrganNames,'_biomass_maintenance');
%make exception for non-translating organs
ObjectiveComponents(strmatch('Platelet',OrganNames)) ={'Platelet_biomass_maintenance_noTrTr'};
ObjectiveComponents(strmatch('RBC',OrganNames)) ={'RBC_biomass_maintenance_noTrTr'};
ObjectiveComponents(strmatch('sIEC',OrganNames)) ={'sIEC_biomass_reactionIEC01b'};

%clear Col* Numbers ans i organ*
