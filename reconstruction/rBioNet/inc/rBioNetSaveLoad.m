% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
%Through here the metabolite and reaction databases are loaded and saved.
%This script makes it possible to store datbases in any path set in matlab.
%missing for compartments, thats for later
%Stefan G. Thorleifsson
function output = rBioNetSaveLoad(mode,type,data)
%mode is save or load
%type is met or rxn or comp
%data to save
if nargin < 3
    data = [];
end
%output 
%   0 - empty if failed. 
%   data if load was successfull
%   1 if successfull
output = 0;

a = exist('rBioNetSettingsDB.mat','file');
if a == 2 %file exist and is one of the paths
    load rBioNetSettingsDB.mat;
else %File not found and has to be located.
    msgbox(['The rBioNetSettings file is not in a set path or it does not'...
        ' exist, please specify the path or get a new one from the rBioNet'...
        ' zip file.'],'rBioNetSettings.m file missing','error');
    return
end

rxn_exist  = exist(rxn_path,'file');
met_exist = exist(met_path,'file');
comp_exist = exist(met_path,'file');
if rxn_exist == 0
    msgbox(['Path for reaction database is not correct. Please set it using'...
        ' the rBioNetSettnigs file (>>rBioNetSettings).'],'Path incorrect','warn');
    output = [];
    return
elseif met_exist == 0
    msgbox(['Path for metabolite database is not correct. Please set it using'...
        ' the rBioNetSettnigs file (>>rBioNetSettings).'],'Path incorrect','warn');
    output = [];
    return
elseif comp_exist == 0
    msgbox(['Path for compartment database is not correct. Please set it using'...
        ' the rBioNetSettnigs file (>>rBioNetSettings).'],'Path incorrect','warn');
    output = [];
    return
end

switch mode
    case 'save'
        if isempty(data)
            msgbox('No data to save specified.');
            return;
        end
        
        if strcmp(type,'met')
            if ~isempty(regexpi(met_path,'/')) %Unix path
                split = regexpi(met_path,'/','split');%split path to get name
            else %windows path
                split = regexpi(met_path,'\','split');%split path to get name
            end
            split = regexpi(split{end},'\.','split');%remove .mat
            eval([split{1} ' =data'])
            save(met_path, split{1});
            output = 1;
        elseif strcmp(type,'rxn')
            if ~isempty(regexpi(rxn_path,'/')) %Unix path
                split = regexpi(rxn_path,'/','split');%split path to get name
            else %windows path
                split = regexpi(rxn_path,'\','split');%split path to get name
            end
            split = regexpi(split{end},'\.','split');
            eval([split{1} ' =data'])
            save(rxn_path, split{1});
            output = 1;
        elseif strcmp(type,'comp')
            if ~isempty(regexpi(comp_path,'/')) %Unix path
                split = regexpi(comp_path,'/','split');%split path to get name
            else %windows path
                split = regexpi(comp_path,'\','split');%split path to get name
            end
            split = regexpi(split{end},'\.','split');
            eval([split{1} ' =data'])
            save(comp_path, split{1});
            output = 1;
        else
            %incorrect input
            return;
        end
        
            
        
    case 'load'
        if strcmp(type,'met')
            dbase = load(met_path);
            name = fieldnames(dbase);
            output = eval(['dbase.' name{1}]);
        elseif strcmp(type,'rxn');
            dbase = load(rxn_path);
            name = fieldnames(dbase);
            output = eval(['dbase.' name{1}]);
        elseif strcmp(type,'comp')
            dbase = load(comp_path);
            name = fieldnames(dbase);
            output = eval(['dbase.' name{1}]);
        else
            %incorrect input
            return;
        end
    otherwise
        %incorrect output
        return;
end
