function [VMH_existance,rBioNet_existance,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet] = checkAbbrExists(list,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet)
% This function checks whether the abbreviations in the list exist already
% in the VMH or the most recent rBioNetDB either as reaction or metabolite
% abbr
%
% INPUT
% list                          List of abbreviations (either metabolite or reactions);
%                               Alternatively a metabolite structure can be given as input and more
%                               fields are compared
% metab_rBioNet_online
% rxn_rBioNet_online
% metabolite_structure_rBioNet
% 
% OUTPUT
% VMH_existance                 Lists whether the abbreviation exists in VMH (online),
%                               as a reaction (2nd entry) or as a metabolite (3rd entry)
% rBioNet_existance             Lists whether the abbreviation exists in rBioNet (as deposited in cobra toolbox online),
%                               as a reaction (2nd entry) or as a metabolite (3rd entry)
%
%
% Ines Thiele 09/2021

% create temporary folder for the rBioNetDB
mkdir('data');

check4 = {
    'keggId'
%     'biocyc'
     'hmdb'
%     'cheBIId'
%     'chembl'
%    % 'chemspider'
%     'drugbank'
%     'lipidmaps'
% %    'pubChemId'
%     'seed'
    'inchiString'
    'inchiKey'
    };

if isstruct(list)
    metabolite_structure = list;
    clear list
    F = fieldnames(metabolite_structure);
    % get VMHId's from metabolite structure
    for i = 1 : length(F)
        % contains the VMDID's for check for uniqueness as if a list would have
        % provided only
        list{i,1} = metabolite_structure.(F{i}).VMHId;
        fieldList{i,1} = metabolite_structure.(F{i}).VMHId;
        fieldList{i,2} = F{i};
        for k = 1 : length(check4)
            if isnumeric(metabolite_structure.(F{i}).(check4{k}))
                fieldList{i,k+2} = num2str(metabolite_structure.(F{i}).(check4{k}));
            else
                fieldList{i,k+2} = metabolite_structure.(F{i}).(check4{k});
            end
        end
    end
end

% load most recent version of rBioNetDB
if ~exist('metab_rBioNet_online','var') ||  ~exist('rxn_rBioNet_online','var')
    websave('data/MetaboliteDatabase.txt','https://raw.githubusercontent.com/opencobra/COBRA.papers/master/2021_demeter/input/MetaboliteDatabase.txt');
    websave('data/ReactionDatabase.txt','https://raw.githubusercontent.com/opencobra/COBRA.papers/master/2021_demeter/input/ReactionDatabase.txt');
    createRBioNetDBFromVMHDB('rBioNetDBFolder','data/');
    load('data/rxn.mat');
    load('data/metab.mat');
    metab_rBioNet_online = metab;
    rxn_rBioNet_online = rxn;
else
    metab = metab_rBioNet_online;
    rxn = rxn_rBioNet_online;
end

% load extended rBioNet -- Not implemented yet
if ~exist('metabolite_structure_rBioNet','var')
    load met_strc_rBioNet;
end
F = fieldnames(metabolite_structure_rBioNet);
for i = 1 : length(F)
    FR{i,1} = metabolite_structure_rBioNet.(F{i}).VMHId;
    FR{i,2} = F{i};
    for k = 1 : length(check4)
        if isnumeric(metabolite_structure_rBioNet.(F{i}).(check4{k}))
            FR{i,k+2} = num2str(metabolite_structure_rBioNet.(F{i}).(check4{k}));
        else
            FR{i,k+2} = metabolite_structure_rBioNet.(F{i}).(check4{k});
        end
    end
end

% check that rxn abbr does not exist in VMH or rBioNetDB
for i = 1 : size(list,1)
    % check by abbreviation
    % VMH check using the url
    VMH{i,1} = list{i};
    url1 = ['https://www.vmh.life/_api/reactions/?abbreviation=' list{i}];
    url2 = ['https://www.vmh.life/_api/metabolites/?abbreviation=' list{i}];
    output1 = webread(url1);
    output2 = webread(url2);
    if isempty(output1.results) %% rxn abbr does not exist
        VMH{i,2} = num2str(0);
    else
        VMH{i,2} = num2str(1);
    end
    if isempty(output2.results) %% met abbr does not exist
        VMH{i,3} = num2str(0);
    else
        VMH{i,3} = num2str(1);
    end
    % check by abbreviation
    % check rBioNet
    rBioNet{i,1} =  list{i};
    if ~isempty(find(ismember(rxn(:,1),list{i})))
        rBioNet{i,2} =  num2str(1);
    else
        rBioNet{i,2} =  num2str(0);
    end
    if ~isempty(find(ismember(metab(:,1),list{i})))
        rBioNet{i,3} =  num2str(1);
    else
        rBioNet{i,3} =  num2str(0);
    end
    % check against rBioNet structure
    if ~isempty(find(ismember(FR(:,1),list{i})))
        rBioNet{i,3} =  num2str(1);
        rBioNet{i,4} =  list{i};
    end
    % check using database ID's
    % against extended rBioNet structure
    if exist('metabolite_structure','var')
        for k = 1 : length(check4)
            if ~strcmp(fieldList{i,2+k},'NaN')
                if ~isempty(find(ismember(FR(:,2+k),fieldList(i,2+k))))
                    match = find(ismember(FR(:,2+k),fieldList(i,2+k)));
                    rBioNet{i,3}  =  num2str(1);
                    rBioNet{i,4}  = FR{match,1};
                    rBioNet{i,5}  = fieldList(i,2+k);
                end
            end
        end
    end
end
VMH_existance = VMH;
rBioNet_existance = rBioNet;

if ~isempty(find(contains(VMH_existance(:,2:3),'1')))
    % abbr exist in VMH
    fprintf('At least one abbrevation exists already in the VMH.\n');
else
    fprintf('All abbreviations are new to the VMH.\n');
end
if ~isempty(find(contains(rBioNet_existance(:,3),'1')))
    % abbr exist in VMH
    fprintf('At least one abbrevation exists already in rBioNet.\n');
else
    fprintf('All  abbreviations are new to rBioNet.\n ');
end

% remove temporary folder for the rBioNetDB
%warning off;
%rmdir('data','s');
