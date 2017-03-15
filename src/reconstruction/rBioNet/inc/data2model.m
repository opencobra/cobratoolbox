%Takes in data from rbionet to create a complete reconstruction
%Stefan G. Thorleifsson 2011

function model_out = data2model(data,description)
model_out = [];
S = size(data);
data_in = {};
data_out = {};
cnt_in = 1; cnt_out = 1;
%The enable option...
for i = 1:size(data,1)
    if data{i,1} == true
        data_in(cnt_in,:) = data(i,:);
        cnt_in = cnt_in + 1;
    else
        data_out(cnt_out,:) = data(i,:);
        cnt_out = cnt_out + 1;
    end
end

data = data_in;

S = size(data);

%Duplicate entries in model.
u_data = unique(data(:,2));
d_entry = [];
if size(u_data,1) ~= size(data,1)
    for i = 1:size(u_data,1)
        if sum(strcmp(u_data{i}, data(:,2))) > 1
            % It's a short vector so the growing issue doesn't matter
            d_entry = [d_entry i];

        end
    end

    if isempty(d_entry)
        msgbox(['Reactions are non-unique but the script was unable to locate'...
            ' the duplicate entries.'],'Warning','warn');
    else
        %d_entry = unique(d_entry);
        str = 'Reactions: ';
        for i = 1:length(d_entry)
            % It's a short vector so the growing issue doesn't mattera
            str = [str u_data{d_entry(i)} ' '];
        end
        str = [str ' are accounted for more than once in this model. '...
            'Please fix this and try again.'];
    end
    msgbox(str,'Warning', 'warn');
    return;
end



%Flags set default = 1,
%---------------------------for createModel.m
%INPUTS
% rxnAbrList            List of names of the new reactions
% rxnNameList           List of names of the new reactions
% rxnList               List of reactions: format: {'A -> B + 2 C'}
%data(:,5)
% OPTIONAL INPUTS
% revFlagList           List of reversibility flag (opt, default = 1)
% lowerBoundList        List of lower bound (opt, default = 0 or -vMax)
% upperBoundList        List of upper bound (opt, default = vMax)
% subSystemList         List of subsystem (opt, default = '')
% grRuleList            List of gene-reaction rule in boolean format (and/or allowed)
%                       (opt, default = '');
% geneNameList          List of gene names (optional, used only for
%                       translation from common gene names to systematic gene
%                       names
% systNameList          List of systematic names (optional)
%
% OUTPUT
% model                 COBRA Toolbox model structure
if isempty(data)
    msgbox('There are no reactions to save.','No reactions.','error');
    return
end

%createModel has been altered from the cobra toolbox version.
UB = [];
LB = [];
rev = [];
for i = 1:S(1)
    UB(i) = data{i,8};%model creator can't take in cells for ub and lb
    LB(i) = data{i,7};
    if data{i,5} == 0
        rev(i) = false;
    else
        rev(i) = true;
    end
end

model = createModel(data(:,2),data(:,3),data(:,4),rev,LB,...
    UB,data(:,10), data(:,6));

%----createModel.m is missing some fields, fix...

model.mets = columnVector(model.mets);
model.rxns = columnVector(model.rxns);
model.rules = columnVector(model.rules);
model.lb = columnVector(model.lb);
model.ub = columnVector(model.ub);
model.rev = columnVector(model.rev);
model.c = columnVector(model.c);
model.grRules = columnVector(model.grRules);
model.subSystems = columnVector(model.subSystems);
model.rxnNames = data(:,3);
model.comments = data(:,12);
model.citations = data(:,11);
model.confidenceScores = data(:,9);
model.ecNumbers = data(:,13);
model.rxnKeggID = data(:,14);

%----createModel.m is missing some things, fix...

model.metCharge = {};


%Getting Metabolite info

%column 1 - abbreviation, column 2 - charged formula, column 3 - charge.
% met_list = cell(1,9); %size depends on size of met_k!
% met_list{1,1} = 'Thorleifsson';
% missing_mets = {'Thorleifsson'};missing_cnt = 0;
% max_msgbox = 0;
%

reactions   = rBioNetSaveLoad('load','rxn');
metabolites = rBioNetSaveLoad('load','met');

%----New
%Find all metabolites and reactions that are not in database
mets = model.mets;



S = length(mets);
missing_met = cell(1,1);
cnt_m = 0;
met_k = cell(S,9); %Add information that is not added with CreateModel.m

for k = 1:S(1) % Check all metabolites in model
    met = regexpi(mets{k},'[','split');
    line = find(strcmp(met{1},metabolites(:,1)),1);
    if isempty(line)
        cnt_m = cnt_m + 1;
        missing_met{cnt_m,1} = met{1};
    else
        met_k{k,1} = metabolites{line,2};   %metNames
        met_k{k,2} = metabolites{line,4};   %metFormulas
        met_k{k,3} = metabolites{line,5};   %metCharge
        met_k{k,4} = metabolites{line,8};   %metChEBIID
        met_k{k,5} = metabolites{line,6};   %metKeggID
        met_k{k,6} = metabolites{line,7};   %metPubChemID
        met_k{k,7} = metabolites{line,9};   %metInchiString
        met_k{k,8} = metabolites{line,11};  %metHMDB
        met_k{k,9} = metabolites{line,12};  %metSmile
    end
end


rxns = model.rxns;

S = length(rxns);
missing_rxn = cell(1,size(data,2));
cnt_r = 0;
for k = 1:S(1) % Check all reactions in model
    rxn = rxns{k};
    line = any(strcmp(rxn,reactions(:,1)),1);
    if line == 0

        cnt_r = cnt_r + 1;
        missing_rxn(cnt_r,:) = data(k,:);

    end
end
answer = [];

%There are reactions and metabolites in model that are not in database.
if cnt_r ~=0 || cnt_m ~=0

    if cnt_r ~=0 && cnt_m ~=0
        m_mets = ['Metabolites: ' mets2str(missing_met) '.'];
        m_rxns = ['Reactions: ' mets2str(missing_rxn(:,2)) '.'];

        answer = questdlg(char(m_mets,m_rxns,'',['Are missing from database.'...
            'The reconstruction cannot be completed without them. Do you want',...
            ' to add them now?']),'Missing metabolites/reactions','Yes',...
            'No','Yes');
    elseif cnt_r ~=0 && cnt_m == 0
        m_rxns = ['Reactions: ' mets2str(missing_rxn(:,2)) '.'];
        answer = questdlg(char(m_rxns,'',['Are missing from database.'...
            'The reconstruction cannot be completed without them. Do you want',...
            ' to add them now?']),'Missing metabolites/reactions','Yes',...
            'No','Yes');
    else
        m_mets = ['Metabolites: ' mets2str(missing_met) '.'];
        answer = questdlg(char(m_mets,'',['Are missing from database,'...
            'The reconstruction cannot be completed without them. Do you want',...
            ' to add them now?']),'Missing metabolites/reactions','Yes',...
            'No','Yes');
    end

    if isempty(answer)
        answer = 'No';
    end
end

if ~isempty(answer)
    switch answer
        case 'Yes'
            msgbox(['Sorry this option has been disabled. Please go to'...
                ' ReconstructionTool and try the Add reconstruction to db'...
                ' option.'],'Option disabled','error');
            %addmissing(missing_met,missing_rxn)
            return
        otherwise
            return
    end
end




%Missing metabolite information added to model
model.metNames = met_k(:,1);
model.metFormulas = met_k(:,2);
model.metCharge = str2double(met_k(:,3));
model.metChEBIID = met_k(:,4);
model.metKeggID = met_k(:,5);
model.metPubChemID = met_k(:,6);
model.metInchiString = met_k(:,7);
model.metHMDB = met_k(:,8);
model.metSmile = met_k(:,9);



time = clock;
date = [];
for i = 1:length(time)-3
    if isempty(date)
        date = [num2str(round(time(i)))];
    else

        date = [date '/' num2str(round(time(i)))];
    end
end

handles.model_description.date = date;
%Add description to model


model_description = struct;
model_description.name = description{1};
model_description.organism = description{2};
model_description.author = description{3};
model_description.geneindex = description{4};
model_description.genedate = description{5};
model_description.genesource = description{6};
model_description.notes = description{7};
model.description = model_description;

model.disabled = data_out; %the disabled data follows.

model_out = model;
