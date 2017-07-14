function metList = newCompsNewMets(metList, Cmodel, Tmodel)
% Declares all metabolites in `Cmodel` that come from
% compartments NOT in `Tmodel` as new.
% Called by `driveModelBorgifier`.
%
% USAGE:
%    metList = newCompsNewMets(metList, Cmodel, Tmodel)
%
% INPUTS:
%    metList:    list of metabolites
%    Cmodel:     `Cmodel` structure
%    Tmodel:     `Tmodel` structure
%
% OUTPUTS:
%    metList:    list of metabolites
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

compNames = {''} ; %Determine compartments in Tmodel. Figure out what compartments are in the model.
for iMet = 1:length(Tmodel.mets)
    nowComp = Tmodel.mets{iMet}(end - 2:end) ;
    if ~strcmpi(nowComp,compNames)
        if isempty(compNames{1})
            % First compartment found.
            compNames{1} = nowComp ;
        else
            % Additional compartments.
            compNames{length(compNames) + 1, 1} = nowComp ;
        end
    end
end
compNames = sort(compNames) ;

%% Check Cmodel metabolite compartments
% Index of new metabolites in metList, either length of Tmodel.mets+1, or
% max of metList+1, whichever is higher.
if max(metList) <= length(Tmodel.mets)
    % The first new met index.
    tIndex = length(Tmodel.mets) + 1 ;
else
    tIndex = max(metList) + 1 ;
end

% Look through Cmodel.mets and mark ones from compartments not in T as new,
% as long as they have not already been declared.
for iMet = 1:length(Cmodel.mets)
    nowComp = Cmodel.mets{iMet}(end - 2:end) ;
    if ~sum(strcmpi(nowComp,compNames)) && ~metList(iMet)
        metList(iMet) = tIndex ;
        tIndex = tIndex + 1 ;
    end
end
