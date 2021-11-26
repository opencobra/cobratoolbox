function [metabolite_structure,IDAdded] = addInfoFromMolFiles(metabolite_structure,folderName,startSearch,endSearch)
% This function creates inchiStrings, smiles, and inchiKeys from provided mol files,
% in the case that these fields are empty (NaN) in the structure.
%
% INPUT
% metabolite_structure  metabolite structure
% folderName            name of folder that contains the mol structures
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
%
% OUTPUT
% metabolite_structure  Updated metabolite structure
%
%
% Ines Thiele, 09/2021


F = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end

if ~exist('folderName','var')
    folderName= 'ctf-main/mets/molFiles';
end
files = dir(folderName);
for i = 1 : length(files)
    fileNames{i,1} = files(i).name;
end
cnt =1;

if exist('fileNames','var')
    for i = startSearch : endSearch
        VMHId = metabolite_structure.(F{i}).VMHId ;
        
        if isempty(metabolite_structure.(F{i}).inchiString) || length(find(isnan(metabolite_structure.(F{i}).inchiString))) >0 % no inchistring exists
            
            if strmatch([metabolite_structure.(F{i}).VMHId '.mol'],fileNames,'exact') % but mol file
                % generate inchistring from mol file
                [~,tmp] = system(['obabel ' folderName filesep VMHId  '.mol -o inchi']);
                tmp2=split(tmp,'==');
                inchiString = strtrim(tmp2{1});
                inchiString = regexprep(inchiString,'1 molecule converted','');
                inchiString = regexprep(inchiString,'\n','');
                if ~isempty(inchiString)
                    metabolite_structure.(F{i}).inchiString = inchiString;
                    metabolite_structure.(F{i}).inchiString_source = ['Mol File in ' folderName];
                    IDAdded{cnt,1} = VMHId;
                    IDAdded{cnt,2} = inchiString;
                    IDAdded{cnt,3} = VMHId;cnt = cnt + 1;
                end
                metabolite_structure.(F{i}).hasmolfile =1;
                metabolite_structure.(F{i}).hasmolfile_source = ['Mol File in ' folderName];
            end
        end
        
        if ~isempty(metabolite_structure.(F{i}).inchiString) && length(find(isnan(metabolite_structure.(F{i}).inchiString))) ==0 % no inchistring exists
            if  isempty(metabolite_structure.(F{i}).inchiKey) || length(find(isnan(metabolite_structure.(F{i}).inchiKey))) >0 % no inchistring exists
                inchiString =metabolite_structure.(F{i}).inchiString;
                [result] = convertInchiString2format(inchiString,'inchiKey');
                
                if ~isnan(result)
                    
                    metabolite_structure.(F{i}).inchiKey = (result);
                    metabolite_structure.(F{i}).inchiKey_source = ['Mol File in ' folderName];
                    IDAdded{cnt,1} = VMHId;
                    IDAdded{cnt,2} = metabolite_structure.(F{i}).inchiKey;
                    IDAdded{cnt,3} = VMHId;cnt = cnt + 1;
                end
            end
            if  isempty(metabolite_structure.(F{i}).smile) || length(find(isnan(metabolite_structure.(F{i}).smile))) >0 % no inchistring exists
                
                inchiString =metabolite_structure.(F{i}).inchiString;
                [result] = convertInchiString2format(inchiString,'smiles');
                
                if ~isnan(result)
                    
                    metabolite_structure.(F{i}).smile_source = ['Mol File in ' folderName];
                    metabolite_structure.(F{i}).smile = (result);
                    IDAdded{cnt,1} = VMHId;
                    IDAdded{cnt,2} =    metabolite_structure.(F{i}).smile;
                    IDAdded{cnt,3} = VMHId;cnt = cnt + 1;
                end
            end
        end
    end
end
