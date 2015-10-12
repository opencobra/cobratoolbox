function [modelSBMLfbc,listCorrectedFields]=convertCobra2Fbc2(modelSBML,filename)

%
% This function first compares a Matlab SBML structure converted from a
% COBRA model and a reference Matlab SBML structure produced by
% "TranslateSBML" funciton. If any discrepancies exist between the two SBML
% structures, such as missing or inconsistent field names, the function
% then resolves the differences according to the reference SBML structure;
% Finally, the function converts the corrected SBML structure into a
% valid SBML with FBCv2 file.
%
%
%INPUTS
% modelSBML                A SBML structure produced by
%                          "convertCobraToSBML" function
%OPTIONAL INPUTS
% filename                 xml file name

%OUTPUT
% modelSBMLfbc             A corrected SBML variable that serves as an
%                          input for "OutputSBML" function.
%
% listCorrectedFields      Lists of field names of the COBRA SBML
%                          sturctures that are different from the SBML with
%                          FBCv2 file.
%                       
%
% Longfei Mao 28/09/2015
%
%
if nargin<2
    filename='sbmlModel'
end
modelSBMLfbc=modelSBML;

if ~isfield(modelSBMLfbc,'fbc2str'); % the model structure doesn't contain the 'fbc2str' field.  
    errordlg('The input COBRA model structure doesn''t contain a subfield "fbc2str". This issue is caused by the fact that the input COBRA structure might not be imported from a valid SBML with FBC file.','The reference subfield doesn''t exist');

    return
end

modelSBMLfbc=rmfield(modelSBMLfbc,'fbc2str');
mini_fbc2=modelSBML.fbc2str;
% Correct the missing fields
mini_fbc2=orderfields(mini_fbc2);
modelSBMLfbc=orderfields(modelSBMLfbc);
listCorrectedFields={};
% Identify the difference bewteen two main fields of two structures

listCOBRA=fieldnames(modelSBMLfbc); % the COBRA SBML structure
listSBML=fieldnames(mini_fbc2); % the reference SBML structure

ind=find(~ismember(listSBML,listCOBRA)); % idenify fields that are not present in the reference SBML structure

for i=1:length(ind)
    modelSBMLfbc.(listSBML{ind(i)})=mini_fbc2.(listSBML{ind(i)});
    listCorrectedFields{ind,1}=listSBML{ind(i)}; % record the names of fields that are corrected according to the reference SBML file.
end
% Check if any discrepancies exist between the subfields of the two structure variables
fbc2=structfun(@numel,mini_fbc2);  % the number of the 
cobra_test=structfun(@numel,modelSBMLfbc);

result=[];% Initilise the variable
d=0;

for i=1:length(fbc2);
    a=fbc2(i)-cobra_test(i); % Compare the number of the subfields of each fields of the two structures
    switch a;
        case 0;
        otherwise
            d=d+1;
            result(d,1)=i;
    end
end

for d=1:length(result);
    if isempty(find(ismember(listSBML{result(d)},{'reaction';'species';'fbc_fluxBound'}))); %'species';
        listCorrectedFields{d,2}=listSBML{result(d)};
        modelSBMLfbc.(listSBML{result(d)})=mini_fbc2.(listSBML{result(d)});
    end
end

listKey={'species'}; % The species field of a SBML with fBCv2 structure is different from that of a conventional COBRA SBML structure

% Retrieve the sub-field names of the species field
listSpeciesSBML=fieldnames(mini_fbc2.(listKey{1}));
listSpeciesCOBRA=fieldnames(modelSBMLfbc.(listKey{1}));
% mini_fbc2.(listKey{1})(:,1).fbc_charge
% Synchronise the fields of the COBRA SBML structure with the reference SBML structure
ind_species=find(~ismember(listSpeciesSBML,listSpeciesCOBRA)); % Check if any differences exist 
for in=1:length(ind_species);
    for dd=1:size(mini_fbc2.(listKey{1}),2);
        modelSBMLfbc.(listKey{1})(dd).(listSpeciesSBML{ind_species(in)})=mini_fbc2.(listKey{1})(dd).(listSpeciesSBML{ind_species(in)}); % Correct discrepancies according to the reference SBML structure.
    end
end
% Double check if any discrepancies exist between the corrected COBRA model and the reference model
listSpeciesSBML=fieldnames(mini_fbc2.(listKey{1}));
listSpeciesCOBRA=fieldnames(modelSBMLfbc.(listKey{1}));
for in =1:length(listSpeciesSBML)
    for dd=1:size(mini_fbc2.(listKey{1}),2);
        if isempty(modelSBMLfbc.(listKey{1})(in).(listSpeciesSBML{in}));
            modelSBMLfbc.(listKey{1})(in).(listSpeciesSBML{in})=mini_fbc2.(listKey{1})(dd).(listSpeciesSBML{in});
            listCorrectedFields(in,3)={listSpeciesSBML{in}};
        end
    end
end
OutputSBML(modelSBMLfbc, filename);