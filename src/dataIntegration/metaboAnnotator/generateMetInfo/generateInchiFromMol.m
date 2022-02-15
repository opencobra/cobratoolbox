function [metabolite_structure,IDsAdded,InchiKeyList,InchiStringList] = generateInchiFromMol(metabolite_structure,folder, inchiKey, smiles,formula,startSearch,endSearch)
% This function adds inchistrings to the metabolite structure entries if
% mol files are available (in folder) and no inchistring is present in
% metabolite structure for a given entry. It also calculated inchikeys and
% smiles if desired.
%
% INPUT
% metabolite_structure  metabolite structure
% folder                folder containing the mol files
% inchiKey              if 1 (default), then inchiKey will be generated
%                       from mol file
% smiles                if 1 (default), then smiles will be generated
%                       from mol file
% formula               if 1 (default), then inchiKey will be generated
%                       from inchistring file
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
%
% OUTPUT
% metabolite_structure  Updated metabolite structure
% IDsAddeed             List of IDs added to the metabolite structure
% InchiKeyList          List of inchikeys added
% InchiStringList       List of inchistrings added
%
%
% Ines Thiele, 2020-2021


if ~exist('inchiKey','var')
    inchiKey = 1;
end

if ~exist('smiles','var')
    smiles = 1;
end
if ~exist('formula','var')
    formula = 1;
end

% folder    folder containing all mol files
annotationSource = ['Mol files from ' folder];
annotationType = 'automatic';

Mets = fieldnames(metabolite_structure);

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end
cnt = 1;
for i = startSearch : endSearch
    
    VMHId{cnt,1} = Mets{i};
    if isfield(metabolite_structure.(Mets{i}),'VMHId')
        VMHId{cnt,2} = metabolite_structure.(Mets{i}).VMHId;
    else
        VMHId{cnt,2} = Mets{i};
        VMHId{cnt,2} =regexprep(  VMHId{i,2},'VMH_','');
        VMHId{cnt,2} =regexprep(  VMHId{i,2},'__','_');
    end
    cnt = cnt + 1;
end
a = 1;
IDsAdded = ''; a =  1;
InchiStringList = ''; b =1;
InchiKeyList = ''; c= 1;
%folder = 'FileDumps/molFiles/molFiles_AGORA2/';
files = dir(folder);
space =' ';

% this could be accelerated
for i = 1 :length(files)
    met = regexprep(files(i).name,'.mol','');
    match = VMHId(find(ismember(VMHId(:,2),met),1),1);
    
    if contains(files(i).name,'.mol') && ~isempty(match)
        
        metabolite_structure.(match{1}).hasmolfile = 1;
        metabolite_structure.(match{1}).hasmolfile_source = [annotationSource,':',annotationType,':',datestr(now)];
        
        if isempty(metabolite_structure.(match{1}).inchiString) || length(find(isnan(metabolite_structure.(match{1}).inchiString)))>0
            if ismac
                [status, result]=system(strcat('/usr/local/bin/obabel',[space folder filesep files(i).name],' -o inchi -h' ));
            elseif ispc % pc
                [status, result]=system(strcat('obabel',[space folder filesep files(i).name],' -o inchi -h' ));
            elseif isunix
                [status, result]=system(strcat('obabel',[space folder filesep files(i).name],' -o inchi -h' ));
            end
            
            if contains(result,'1 molecule converted')
                %result = regexprep(result,'1 molecule converted','');
                [tok,rem] = strtok(result,'=');
                result = regexprep(rem,'1 molecule converted','');
                result = regexprep(result,'\n','');
                if strfind(result,'==')
                    tokr = split(result,'==');
                    result = tokr{1};
                end
                if ~isempty(result)
                     inchiString = strcat('InChI',result);
                else
                    inchiString = {};
                end
                % find metabolite in metabolite_structure
                if ~isempty(inchiString)
                    inchiString = strcat('InChI',result);
                    metabolite_structure.(match{1}).inchiString = inchiString;
                    metabolite_structure.(match{1}).inchiString_source = [annotationSource,':',annotationType,':',datestr(now)];
                    IDsAdded{a,1} = match{1};
                    IDsAdded{a,2} = 'inchiString';
                    IDsAdded{a,3} = metabolite_structure.(match{1}).inchiString;
                    a = a + 1;
                    
                    InchiStringList{b,1} = match{1};
                    InchiStringList{b,2} = strcat(folder,files(i).name);
                    InchiStringList{b,3} = metabolite_structure.(match{1}).inchiString;
                    InchiStringList{b,4} = metabolite_structure.(match{1}).inchiString_source;
                    b = b + 1;
                end
                
                if inchiKey
                    if(isempty(metabolite_structure.(match{1}).inchiKey) || length(find(isnan(metabolite_structure.(match{1}).inchiKey)))>0)
                        if    ~isempty(metabolite_structure.(match{1}).inchiString) &&  length(find(isnan(metabolite_structure.(match{1}).inchiString)))==0
                            inchiString =  metabolite_structure.(match{1}).inchiString;
                            [result] = convertInchiString2format(inchiString,'inchiKey');
                            metabolite_structure.(match{1}).inchiKey = result;
                            metabolite_structure.(match{1}).inchiKey_source = [annotationSource,':',annotationType,':',datestr(now)];
                            IDsAdded{a,1} = match{1};
                            IDsAdded{a,2} = 'inchiKey';
                            IDsAdded{a,3} = metabolite_structure.(match{1}).inchiKey;
                            a = a + 1;
                            
                            InchiKeyList{c,1} = match{1};
                            InchiKeyList{c,2} = strcat(folder,files(i).name);
                            InchiKeyList{c,3} = metabolite_structure.(match{1}).inchiKey;
                            InchiKeyList{c,4} = metabolite_structure.(match{1}).inchiKey_source;
                            c = c + 1;
                        end
                    end
                end
                if smiles
                    if (isempty(metabolite_structure.(match{1}).smile) || length(find(isnan(metabolite_structure.(match{1}).smile)))>0)
                        if ~isempty(metabolite_structure.(match{1}).inchiString) &&  length(find(isnan(metabolite_structure.(match{1}).inchiString)))==0
                            inchiString =  metabolite_structure.(match{1}).inchiString;
                            
                            [result] = convertInchiString2format(inchiString,'smiles');
                            result = regexprep(result,'\W$','');
                            metabolite_structure.(match{1}).smile = result;
                            metabolite_structure.(match{1}).smile_source = [annotationSource,':',annotationType,':',datestr(now)];
                            IDsAdded{a,1} = match{1};
                            IDsAdded{a,2} = 'smiles';
                            IDsAdded{a,3} = metabolite_structure.(match{1}).smile;
                            a = a + 1;
                        end
                    end
                end
            end
        end
    end
end
if formula
    [metabolite_structure] = addMetFormulaCharge(metabolite_structure,startSearch,endSearch);
end
