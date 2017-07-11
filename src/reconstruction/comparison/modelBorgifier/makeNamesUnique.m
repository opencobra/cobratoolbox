function nameList = makeNamesUnique(nameList, varargin)
% Identifies duplicate names in a list of names (cell array)
% and prompts the user to input new names.
% Called by `cleanTmodel`, `verifyModel`, `addSEEDInfo`, calls `countUnique`.
%
% USAGE:
%
%    nameList = makeNamesUnique(nameList, [nameInfo])
%
% INPUTS:
%    nameList:    Cell array of entires that contains duplicates.
%
% OPTIONAL INPUTS:
%    nameInfo:    Cell array the same length as nameList that contains
%                 information pertaining to the matching entry in `nameList`. This
%                 array can help the renaming process.
%
% OUTPUTS:
%    nameList:    Version of nameList with all unique entires.
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

if (nargin > 1) % Declare variables.
    nameInfo = varargin{1} ;
end

% List of unique names, sorted.
uniqList = unique(nameList) ;

% Automatically rename entities?
[names, cnt] = countUnique(nameList);
nameInd = find(cnt > 1);
if ~isempty(nameInd)

    fprintf('%d non-unique names. ', length(nameInd))
    renameFlag = input(['Rename automatically?\n' ...
                     'Otherwise manual renaming will proceed. (y/n): '],...
                      's') ;
    if strcmpi(renameFlag, 'y') || strcmpi(renameFlag, 'yes')
        for i = 1:length(nameInd)
           thisName = names{nameInd(i)} ;
           fprintf('Renaming non-unique name %s (%d instances): ',...
                thisName,cnt(nameInd(i)));
           searchString = regexprep(thisName, '\[', '\\[') ;
           searchString = regexprep(searchString,'\]', '\\]') ;
           searchString = ['^' searchString '$'] ;
           IDs = find(~cellfun(@isempty, regexp(nameList, searchString))) ;
           for j = 1:length(IDs)
               if regexp(nameList{IDs(j)}, '\[\w\]$')
                   nameList{IDs(j)} = [thisName(1:end - 3) '_' num2str(j) ...
                                       thisName(end - 2:end)] ;
               else
                   nameList{IDs(j)} = [thisName '_' num2str(j)] ;
               end
               fprintf('%s\t', nameList{IDs(j)}) ;
           end
           fprintf('\n')
        end
    end
end

%% Find duplicate names.
for iName = 1:length(uniqList)
    dupPos = find(strcmp(uniqList{iName}, nameList)) ;
    % If there are duplicates.
    if length(dupPos) > 1
        dupNo = length(dupPos) ;
        % Duplicate name
        dupName = uniqList{iName} ;
        fprintf('%s has duplicates:\n', dupName)
        % Go through each duplicate and print info.
        for iDup = 1:dupNo
            if exist('nameInfo','var')
                string = [num2str(dupPos(iDup)), '\t', ...
                          nameInfo{dupPos(iDup)}, '\n'] ;
                fprintf(string)
            else
                fprintf('%d\n', num2str(dupPos(iDup)))
            end
        end
        % Ask for how names should be renamed.
        for iDup = 1:dupNo
            while 1
                prompt = ['Rename ' num2str(dupPos(iDup)) ' as: '] ;
                newName = input(prompt,'s') ;
                alreadytherepos = strcmp(newName, nameList) ;
                alreadytherepos(dupPos) = false ;
                % Check to see if name is already taken
                if sum(alreadytherepos) == 0
                    nameList{dupPos(iDup)} = newName ;
                    break
                else
                    errorPrompt = 'Name already taken. Proceed (y/n)?: ' ;
                    proceed = input(errorPrompt, 's') ;
                    if strcmpi(proceed, 'y') || strcmpi(proceed, 'yes')
                        nameList{dupPos(iDup)} = newName ;
                        break
                    else
                        continue
                    end
                end
            end
        end
    end
end

%% Check to make sure it worked.
if length(unique(nameList)) ~= length(nameList)
    fprintf('ERROR: Duplicate names still exist!\n')
end
