function [ResultsMaleFemale] = compareMaleFemale(male, female)
% Compare basic features of the male and female whole-body metabolic models
%
% This function compares basic features of the male and female whole-body
% metabolic models, reporting shared and gender-unique reactions, per-organ
% reaction counts, gallbladder subsystem enrichment, and biofluid exchanges.
%
% USAGE:
%
%    [ResultsMaleFemale] = compareMaleFemale(male, female)
%
% INPUTS:
%    male:                Male whole-body metabolic model, with fields:
%
%                           * .rxns - reaction identifiers
%                           * .subSystems - subsystem annotations
%    female:              Female whole-body metabolic model, with fields:
%
%                           * .rxns - reaction identifiers
%                           * .subSystems - subsystem annotations
%
% OUTPUT:
%    ResultsMaleFemale:    Structure of differences and commonalities between the two models, with fields:
%
%                           * .MaleOnly - reactions unique to the male model
%                           * .FemaleOnly - reactions unique to the female model
%                           * .BothGender - reactions present in both models
%                           * .OrgansNumRxnMale - per-organ reaction counts (male): total, male-only, fraction
%                           * .OrgansNumRxnFemale - per-organ reaction counts (female): total, female-only, fraction
%                           * .maleOrgans - list of organs in the male model
%                           * .femaleOrgans - list of organs in the female model
%                           * .MaleGallSSEnrich - subsystems enriched among male-only gallbladder reactions
%                           * .FemaleGallSSEnrich - subsystems enriched among female-only gallbladder reactions
%                           * .MaleOnlyBiofluid - male-only biofluid exchange (_EX_) reactions
%                           * .FemaleOnlyBiofluid - female-only biofluid exchange (_EX_) reactions
%
% .. Author: - Ines Thiele, 2017

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

