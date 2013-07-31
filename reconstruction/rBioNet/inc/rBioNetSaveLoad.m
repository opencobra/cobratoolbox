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
% output = rBioNetSaveLoad(mode,type,data)
%
% mode - save or load
% type - met or rxn or comp
% data to save
if nargin < 3
    data = [];
end
%output
%   0 - empty if failed.
%   data if load was successfull
%   1 if successfull
output = 0;

if 2 == exist('rBioNetSettingsDB.mat','file') %file exist and is one of the paths
    load rBioNetSettingsDB.mat;
else %File not found and has to be located.
    msgbox(['The rBioNetSettings file is not in a set path or it does not'...
        ' exist, please specify the path or get a new one from the rBioNet'...
        ' zip file.'],'rBioNetSettings.m file missing','error');
    return
end

paths = {rxn_path, met_path,comp_path};
paths_order = {'reaction','metabolite','compartment'};
for i = 1:length(paths)
    spl = regexpi(paths{i},os_slash,'split');
    if ~isvarname(spl{end}(1:regexpi(spl{end},'\.','end')-1))
        msgbox(['Invalid variable name: ' spl{end} ...
            '. Please change the file name to a Matlab legal variable name'...
            ' and then reselect the file with >>rBioNetSettings. '],...
            'Invalid file name.','warn');
        output = [];
        return;
    elseif exist(paths{i},'file') == 0
        msgbox(['Path for ' paths_order{i} ' database is not correct. Please set it using'...
            ' the rBioNetSettnigs file (>>rBioNetSettings).'],'Path incorrect','warn');
        output = [];
        return
    end
end

if strcmp(type,'met')
    wpath = met_path;
elseif strcmp(type,'rxn')
    wpath = rxn_path;
elseif strcmp(type,'comp')
    wpath = comp_path;
else
    %incorrect input
    disp(['save/load incorrect input type: ' type]);
    return;
end

switch mode
    case 'save'
        if isempty(data)
            msgbox('No data to save specified.');
            return;
        end
        
        split = regexpi(wpath,os_slash,'split');%split path to get name
        split = regexpi(split{end},'\.','split');%remove .mat
        eval([split{1} ' =data;']);
        save(wpath, split{1});
        output = 1;
    case 'load'
        dbase = load(wpath);
        name = fieldnames(dbase);
        output = eval(['dbase.' name{1}]);
    otherwise
        %incorrect output
        return;
end
