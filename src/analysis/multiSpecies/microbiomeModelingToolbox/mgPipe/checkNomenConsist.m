function [autoStat, fixVec, organisms] = checkNomenConsist(organisms, autoFix)
% This function checks consistence of inputs (organisms names). If the parameter
% autoFix == 0 the function halts execution with error msg when inconsistences are
% detected, otherwise it really tries hard to fix the problem and continues execution.
%
% USAGE:
%
%   [autoStat, fixVec, organisms] = checkNomenConsist(organisms, autoFix)
%
% INPUTS:
%   organisms:           nx1 cell array cell array with names of organisms in the study
%   autoFix:             double indicating if to try to automatically fix inconsistencies
%
% OUTPUTS:
%   autoStat:            double indicating if inconsistencies were found
%   fixVec:              nx1 cell array cell array with names of individuals in the study
%   organisms:           nx1 cell array cell array with non ambiguous names of organisms in the study
%
% .. Author: Federico Baldini 2017-2018

if autoFix == 0
    
    for i = 1:length(organisms)
        check = strmatch(organisms(i, 1), organisms);
        if length(check) > 1
            vecErr = organisms(check)
            msg = 'Nomenclature error: one or more organisms have ambiguous ID. Ambiguity indexes stored in check vector';
            error(msg)
        end
    end
else
    for i = 1:length(organisms)
        check = strmatch(organisms(i, 1), organisms);
        if length(check) > 1
            vecErr = organisms(check)
            % Autodebug, suffix '_extended' is added to solve ambiguity:
            organisms(i)
            fixVec(i) = organisms(i)
            fixNam = strcat(organisms(i), '_extended')
            organisms(i) = fixNam
            autoStat = 1
        else
            if i == length(organisms)
                disp('No potential problems found in checking organisms? nomenclature');
            end
            autoStat = 0;
            fixVec = {};
        end
    end
    
    % Second cycle: checking multiple times is always better idea
    for i = 1:length(organisms)
        check = strmatch(organisms(i, 1), organisms);
        if length(check) > 1
            vecErr = organisms(check)
            msg = 'Nomenclature error: one or more organisms have ambiguous ID. Ambiguity indexes stored in check vector';
            error(msg)
        end
    end
end
% end of Autofix part
end
