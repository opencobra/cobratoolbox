function [organs,OrganWeight,OrganWeightFract,IndividualParameters] = calcOrganFract(model, IndividualParameters)
% This function extrapolates the organ weight fractions based on polynomials given in
% http://www.ams.sunysb.edu/~hahn/psfile/pap_obesity.pdf (PMID 19267313), Table 3. Those ones that are not given are assumed to remain constant with weight
% using the fractions from the reference man and reference woman.
%
% [organs,OrganWeight,OrganWeightFract,IndividualParameters] = calcOrganFract(model, IndividualParameters)
%
% INPUT
% model                 Model structure
% IndividualParameters  Structure of individual parameters (sex, weight,
%                       blood volume)
% 
% OUTPUT
% organs                List of organs
% OrganWeight           List of organ weights (same order as organs)
% OrganWeightFract      List of organ weight fractions (same order as organs)
% IndividualParameters  Updated structure of individual parameters
% 
% Ines Thiele Nov 2017
%

% get sex from individual parameters
sex = IndividualParameters.sex;

% load reference organ weights/fractions from Ref man and Ref woman
getOrganWeightFraction;
RefOrganWeights = OrganWeight;
RefOrganWeightFract = OrganWeightFract;
RefBodyWeight = BodyWeight;
RefOrganNames = OrganNames;

% get individual parameters
Wt = IndividualParameters.bodyWeight*1000;

% IT - 27.02.2018 - I changed this default statement
% see line 100 onwards - important for calc of platelets and red blood
% cells
BloodVolume = IndividualParameters.CardiacOutput; % given in ml
%

% pre-define variables
OrganWeight = [];
OrganWeightFract = [];
organs = [];

% define polynomials for organ weights based on body weight
% based on polynomials given in
% http://www.ams.sunysb.edu/~hahn/psfile/pap_obesity.pdf, Table 3
%
if strcmp(sex,'male')
    OF={
        'Brain' '1.41e-01' '-5.54e-06' '9.30e-11' '-6.83e-16' '1.80e-21' '0.0'
        'Heart' '6.32e-03' '-1.67e-08' '0.0' '0.0' '0.0' '0.0'
        'Kidney' '7.26e-03' '-6.69e-08' '3.33e-13' '0.0' '0.0' '0.0'
        'Liver' '4.25e-02' '-1.01e-06' '1.99e-11' '-1.66e-16' '4.83e-22' '0.0'
        'Lungs' '1.86e-02' '-4.55e-08' '0.0' '0.0' '0.0' '0.0'
        'Spleen' '3.12e-03' '-5.57e-09' '0.0' '0.0' '0.0' '0.0'
        'Agland' '8.04e-04' '-1.98e-08' '2.01e-13' '-6.11e-19' '0.0' '0.0'
        'Pancreas' '1.48e-03' '0.0' '0.0' '0.0' '0.0' '0.0'
        'Thymus' '3.70e-03' '-1.05e-07' '7.94e-13' '0.0' '0.0' '0.0'
        'Thyroidgland' '2.42e-04' '0.0' '0.0' '0.0' '0.0' '0.0'
        'Adipocytes' '1.61e-01' '-3.59e-06' '8.28e-11' '-3.57e-16' '4.73e-22' '0.0'
        'Muscle' '9.68e-02' '-3.32e-06' '1.83e-10' '-1.24e-15' '0.0' '0.0'
        'Skin' '1.03e-01' '-2.56e-06' '3.68e-11' '-2.58e-16' '8.62e-22' '-1.10e-27'
        'Blood' '8.97e-02' '-3.50e-07' '6.54e-13' '0.0' '0.0' '0.0'
        };
    
elseif strcmp(sex,'female')
    OF={
        'Brain' '1.12e-01' '-3.33e-06' '4.30e-11' '-2.45e-16' '5.03e-22' '0.0'
        'Heart' '5.40e-03' '-1.07e-08' '0.0' '0.0' '0.0' '0.0'
        'Kidney' '7.56e-03' '-5.58e-08' '1.54e-13' '0.0' '0.0' '0.0'
        'Liver' '3.34e-02' '-1.89e-07' '5.34e-13' '0.0' '0.0' '0.0'
        'Lungs' '1.89e-02' '-5.94e-08' '0.0' '0.0' '0.0' '0.0'
        'Spleen' '2.96e-03' '-7.72e-09' '0.0' '0.0' '0.0' '0.0'
        'Agland' '8.04e-04' '-1.98e-08' '2.01e-13' '-6.11e-19' '0.0' '0.0'
        'Pancreas' '1.48e-03' '0.0' '0.0' '0.0' '0.0' '0.0'
        'Thymus' '3.70e-03' '-1.05e-07' '7.94e-13' '0.0' '0.0' '0.0'
        'Thyroidgland' '2.42e-04' '0.0' '0.0' '0.0' '0.0' '0.0'
        'Adipocytes' '1.84e-01' '-6.86e-06' '2.46e-10' '-2.11e-15' '7.58e-21' '-9.94e-27'
        'Muscle' '3.65e-02' '7.91e-06' '-5.74e-11' '0.0' '0.0' '0.0'
        'Skin' '9.81e-02' '-2.28e-06' '2.74e-11' '-1.58e-16' '4.30e-22' '-4.43e-28'
        'Blood' '8.97e-02' '-3.50e-07' '6.54e-13' '0.0' '0.0' '0.0'
        % these numbers come from Luebcke et al 2007
        % Postnatal Growth Considerations for PBPK Modeling
        'Breast' '0.01' '0.0' '0.0' '0.0' '0.0' '0.0'
        };
end

for i =1 : size(OF,1)
    x0= str2num(OF{i,2});
    x1=str2num(OF{i,3});
    x2=str2num(OF{i,4});
    x3=str2num(OF{i,5});
    x4=str2num(OF{i,6});
    x5=str2num(OF{i,7});
    % organ fraction for given weight
    OrganWeightFract(i,1) = x0 + x1*Wt + x2*Wt^2 + x3*Wt^3 + x4*Wt^4 + x5*Wt^5;
    % weight per organ for given weight
    OrganWeight(i,1) = OrganWeightFract(i,1)*Wt;
end
organs = OF(:,1);
r = size(organs,1)+1;
%% calculate blood cells

BloodRow = strmatch('Blood',OF(:,1));
BloodWeight = OrganWeight(BloodRow,1);

% IT 27.02.2018 - after HH submission I changed the calculation of the
% blood volume
% density of plasma: 1.0506 kg/m3 at 37 degrees: http://clinchem.aaccjnls.org/content/20/5/615
% => 1 l of blood = 1.0506 kg
% 
BloodVolume = BloodWeight/1.0506; % in ml
IndividualParameters.BloodVolume = BloodVolume;

% WBC make about 1% of blood
WBCWeight = 0.01*BloodWeight;
% Lymphocytes	15-40% of White Blood Cells; assumed 30% of WBC weight
LympWeight = 0.3*WBCWeight;
% Bcells	9% of Lymphocytes
organs{r} = 'Bcells';
OrganWeight(r,1) = 0.09*LympWeight;
OrganWeightFract(r,1) = OrganWeight(r,1)/Wt;
r = r+1;
% CD4Tcells	"45-75% of lymphocytes; 4 – 20% of leukocyte; assumed 15% of leukocytes"
organs{r} = 'CD4Tcells';
OrganWeight(r,1) = 0.15*WBCWeight;
OrganWeightFract(r,1) = OrganWeight(r,1)/Wt;
r = r+1;
% CD8Tcells	2 – 11% of leukocytes; assumed 8%
% Nkcells	Human and mouse NK cells constitute approximately 15% of all circulating lymphocytes
organs{r} = 'Nkcells';
OrganWeight(r,1) = 0.15*LympWeight;
OrganWeightFract(r,1) = OrganWeight(r,1)/Wt;
r = r+1;
% Monocyte	Monocyte (2-8% of peripheral WBCs); assumed 5%
organs{r} = 'Monocyte';
OrganWeight(r,1) = 0.05*WBCWeight;
OrganWeightFract(r,1) = OrganWeight(r,1)/Wt;
r = r+1;
% Platelet	150,000 to 400,000/mm3; 1mm3 = 1e-6 l; 10 pg per platelet (wet weight); assumed 400k/mm3; --> 4g/l; --> 20g/5l
organs{r} = 'Platelet';
OrganWeight(r,1) = 4*BloodVolume/1000;%495g/l
OrganWeightFract(r,1) = OrganWeight(r,1)/Wt;
r = r+1;
% RBC	The normal range in men is approximately 4.7 to 6.1 million cells/ul (microliter). The normal range in women range from 4.2 to 5.4 million cells/ul, according to NIH (National Institutes of Health) data. 27 pg dry weight of one RBC. Assumed 70% water in RBC --> 90 pg/RBC; --> 495g/l --> 2475 g/5l for male (assumed 5.5M) and 2050 g/l for female (assumed 4.5M)
organs{r} = 'RBC';
OrganWeight(r,1) = 495*BloodVolume/1000;%495g/l
OrganWeightFract(r,1) = OrganWeight(r,1)/Wt;
r = r+1;

% now readjust organ weight fraction from all other organs not covered by
% the polynomials and the equation based on the individual weight and the
% it is assumed that the weight of these organs does not change with
% increasing or decreasing body weight hence the fractions will be adjusted
% to the new body weight

% get all organs defined in the model
ObjectiveComponents = model.rxns(find(~cellfun(@isempty,strfind(model.rxns,'_biomass_maintenance'))));
ObjectiveComponents(end+1) ={'sIEC_biomass_reactionIEC01b'};
OrgansInModel = strtok(ObjectiveComponents,'_');

% organs not captured by polynomials
MissingOrgans = setdiff(unique(OrgansInModel), organs);
% their original weight:

for i = 1 : length(MissingOrgans)
    organs{r} = MissingOrgans{i};
    X = find(ismember(RefOrganNames,MissingOrgans{i}));
    OrganWeight(r,1) = RefOrganWeights(X);
    OrganWeightFract(r,1) =  RefOrganWeights(X)/Wt;
    r = r+1;
end

IndividualParameters.OrgansWeightsRefMan = IndividualParameters.OrgansWeights;
IndividualParameters = rmfield(IndividualParameters,'OrgansWeights');
for i = 1 : length(organs)
    IndividualParameters.OrgansWeights(i,:) = {organs{i}, num2str(OrganWeight(i)), num2str(OrganWeightFract(i)*100)};
end
