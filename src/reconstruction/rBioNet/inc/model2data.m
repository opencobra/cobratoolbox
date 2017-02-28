% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011

%Load complete reconstructions and output format for rBioNets
%ReconstructionCreator.
%Stefan G. Thorleifsson March 2011


function data_out = model2data(model,fordb)
%data_out
%fordb is when metabolite table is wanted ass well, value should be 1,
%otherwise default is 0.
if nargin < 2
    fordb = 0;
end
%   rxn table ->data
%   description
%   genes
%   model with setup change. 

handles.model = model;


names = fieldnames(handles.model);

name = {'genes','data','description'};
match = zeros(size(names));
for i = 1:size(name,2)
    match(i) = strcmp(name{i},names{i});
end

if sum(match) == length(name)
    msgbox(['This file is not an complete reconstruction. Try opening'...
        ' it as a mat file.'], 'Incorrect file type','Help');
    return
end
Mandatory = {'rxns','rxnNames', 'rev','grRules', 'lb', 'ub','S','genes'};
%Opt numbers: CS = 1, subsystem = 2, citations = 3, comments = 4, ecNumbers = 5,
% rxnKeggID = 6, description = 7


% reaction data lineup:
% 1.rxns
% 2.rxnNames
% 3.formula
% 4.reversible
% 5.grRules,
% 6.lb
% 7.ub
% 8.confidenceScores
% 9.subSystems
% 10.citations
% 11.comments
% 12.ecNumbers
% 13.KeggID.

%enable is set infront afterwards. 

%Check Mandatory


for i = 1:length(Mandatory)
    k = ismember(Mandatory(i),names);
    if k == 0
        msgbox(['Group ' Mandatory{i} ' is missing from structure of model.']...
            ,'Structure incorrect.','error');
        return
    end
end



S1 = size(handles.model.rxns); %Get size of model
data = cell(S1(1),13); %create cell matrix for data
data(:,1) = handles.model.rxns;
data(:,2) = handles.model.rxnNames;
data(:,3) = printRxnFormula(handles.model, handles.model.rxns,false);
data(:,4) = num2cell(handles.model.rev);
data(:,5) = handles.model.grRules;
data(:,6) = num2cell(handles.model.lb);
data(:,7) = num2cell(handles.model.ub);

Optional = {'confidenceScores', 'subSystems','citations', 'comments', 'ecNumbers',...
    'rxnKeggID','description'};
%Check Optional
opt = [];
for i = 1:length(Optional)
    
    % Recon had different names of fields, this is a quick fix. 
    if strcmp(Optional{i},'ecNumbers')
        if ismember('rxnECNumbers',names);
            Optional{i} = 'rxnECNumbers';
            continue;
        end
    
    elseif strcmp(Optional{i},'subSystems')
        if ismember('rxnSubSystems',names);
            Optional{i} = 'rxnSubSystems';
            continue;
        end
    
    elseif strcmp(Optional{i},'confidenceScores')
        if ismember('rxnConfidenceScores',names);
            Optional{i} = 'rxnConfidenceScores';
            continue;
        end
    
    elseif strcmp(Optional{i},'citations')
        if ismember('rxnReferences',names);
            Optional{i} = 'rxnReferences';
            continue;
        end
        
    elseif strcmp(Optional{i},'comments')
        if ismember('rxnNotes',names);
            Optional{i} = 'rxnNotes';
            continue;
        end
    end
    k = ismember(Optional(i),names);
    if k == 0
        opt = [opt,i]; %data missing
    end
end
%Opt numbers: CS = 1, subsystem = 2, citations = 3, comments = 4,
%ecNumbers = 5, rxnKeggID = 6, description = 7
for i = 1:length(Optional)-1
    if isfield(model,Optional{i})
        data(:,i+7) = model.(Optional{i});
    else %data missing
        data(:,i+7) = cell(S1(1),1);
    end
end


%description
if ~any(ismember(opt,7)) %data exist
    if isa(handles.model.description,'char');
       
        s_b = [NaN NaN];
        description{1} = handles.model.description;
        description{2} = '';
        description{3} = '';
        description{4} = '';
        description{5} = '';
        description{6} = '';
        description{7} = '';
        handles.description = description;
    elseif isa(handles.model.description,'struct');
        b = fieldnames(handles.model.description);
        s_b = size(b);
    else
        s_b = [NaN NaN];
    end

    
    if s_b(1) == 7 %Date is not loaded into description.
        description{1} = handles.model.description.name;
        description{2} = handles.model.description.organism;
        description{3} = handles.model.description.author;
        description{4} = handles.model.description.geneindex;
        description{5} = handles.model.description.genedate;
        description{6} = handles.model.description.genesource;
        description{7} = handles.model.description.notes;
        handles.description = description;
    end
    
end



%This is a quick fix after adding the logical term in the front of the
%reaction table: 4. Mar. 2011
data(:,2:end+1) = data;
%Matlab does not allow data(:,1) = true;
for k=1:size(data,1)
    data{k,1} = true;
end
disabled = {};
if isfield(handles.model,'disabled') 
    for i = 1:size(handles.model.disabled,1)
        disabled(i,:) = handles.model.disabled(i,:);
    end
else
    handles.model.disabled = {};
end


% Note disabled data does not carry metabolite data. 

if fordb == 0
    data_out = {[data; disabled], description, handles.model.genes, handles.model};
elseif fordb == 1
    % From the metabolite database the only thing missing is the Neutral
    % formula. 
     met_fields = {'mets','metNames','metFormulas','metCharge','metKeggID',...
         'metPubChemID','metChEBIID','metInchiString','metSmile','metHMDB',...
         'metHepatoNetID','metEHMNID'};
     
     names = fieldnames(model);
     %Fix incorrect cases compared to structure
     for i=1:length(met_fields)
         if isempty(find(strcmp(names,met_fields{i}),1)) %Fannst ekki
             match = find(strcmpi(names,met_fields{i}),1);
             if isempty(match) % Field not here
                 continue;
             else % Field named incorrectly regarding case.
                 met_fields{i} = names{match};
             end
         end
     end
     
     metabolites={};
     for i = 1:length(met_fields)
         if isfield(model,met_fields{i})
             if isempty(model.(met_fields{i})) %fields can exist but be empty. 
                 metabolites(:,i) = cell(size(model.mets,1),1);
             elseif strcmp(met_fields{i}, 'metCharge') %numeric fix
                 metabolites(:,i) = num2cell(model.(met_fields{i}));
             else
                 metabolites(:,i) = model.(met_fields{i});
             end
         else %no data
             metabolites(:,i) = cell(size(model.mets,1),1);
         end
     end
     data_out = {[data; disabled], description, handles.model.genes, handles.model, metabolites};
     
else %input incorrect
    error('fordb is supposed to be 0 or 1.');
end


