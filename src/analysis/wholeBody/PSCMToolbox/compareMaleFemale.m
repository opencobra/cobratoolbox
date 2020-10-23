function [ResultsMaleFemale] = compareMaleFemale(male,female)
% This function compares basic features of the male and female whole-body
% metabolic models
%
% [ResultsMaleFemale] = compareMaleFemale(male,female)
%
% INPUT
% male                  model structure (male whole-body metabolic model)
% female                model structure (female whole-body metabolic model)
%
% OUTPUT
% ResultsMaleFemale     structure containing the basic differences and
%                       commenalities between male and female model
%
% Ines Thiele 2017

% reactions unique to male
ResultsMaleFemale.MaleOnly = setdiff(male.rxns,female.rxns);
ResultsMaleFemale.FemaleOnly = setdiff(female.rxns,male.rxns);
ResultsMaleFemale.BothGender = intersect(female.rxns,male.rxns);

[maleOrgans]=unique(strtok(male.rxns,'_'));
[femaleOrgans]=unique(strtok(female.rxns,'_'));

for i = 1 : length(maleOrgans)
    ResultsMaleFemale.OrgansNumRxnMale(i,1) = length(strmatch(maleOrgans(i),male.rxns));   
    ResultsMaleFemale.OrgansNumRxnMale(i,2) = length(strmatch(maleOrgans(i),ResultsMaleFemale.MaleOnly));
    % fraction
    ResultsMaleFemale.OrgansNumRxnMale(i,3) = ResultsMaleFemale.OrgansNumRxnMale(i,2)/ResultsMaleFemale.OrgansNumRxnMale(i,1); 
end

for i = 1 : length(femaleOrgans)
    ResultsMaleFemale.OrgansNumRxnFemale(i,1) = length(strmatch(femaleOrgans(i),female.rxns));   
    ResultsMaleFemale.OrgansNumRxnFemale(i,2) = length(strmatch(femaleOrgans(i),ResultsMaleFemale.FemaleOnly));
    % fraction
    ResultsMaleFemale.OrgansNumRxnFemale(i,3) = ResultsMaleFemale.OrgansNumRxnFemale(i,2)/ResultsMaleFemale.OrgansNumRxnFemale(i,1); 
end

ResultsMaleFemale.maleOrgans = maleOrgans;
ResultsMaleFemale.femaleOrgans = femaleOrgans;

%get subsystems for gall rxns
FemaleSS = female.subSystems(find(ismember(female.rxns,ResultsMaleFemale.FemaleOnly(strmatch('Gall_',ResultsMaleFemale.FemaleOnly)))));
ResultsMaleFemale.FemaleGallSSEnrich = unique(FemaleSS);
for i = 1 : length(ResultsMaleFemale.FemaleGallSSEnrich)
    ResultsMaleFemale.FemaleGallSSEnrich{i,2} = num2str(length(strmatch(ResultsMaleFemale.FemaleGallSSEnrich{i},FemaleSS,'exact')));
end
MaleSS = male.subSystems(find(ismember(male.rxns,ResultsMaleFemale.MaleOnly(strmatch('Gall_',ResultsMaleFemale.MaleOnly)))));
ResultsMaleFemale.MaleGallSSEnrich = unique(MaleSS);
for i = 1 : length(ResultsMaleFemale.MaleGallSSEnrich)
    ResultsMaleFemale.MaleGallSSEnrich{i,2} = num2str(length(strmatch(ResultsMaleFemale.MaleGallSSEnrich{i},MaleSS,'exact')));
end

% unique biofluid exchange reactions

ResultsMaleFemale.MaleOnlyBiofluid = ResultsMaleFemale.MaleOnly(find(~cellfun(@isempty,strfind(ResultsMaleFemale.MaleOnly,'_EX_'))));
ResultsMaleFemale.FemaleOnlyBiofluid = ResultsMaleFemale.FemaleOnly(find(~cellfun(@isempty,strfind(ResultsMaleFemale.FemaleOnly,'_EX_'))));

