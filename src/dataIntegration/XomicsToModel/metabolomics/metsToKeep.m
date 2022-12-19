function [cleanedData, metToKeepSummary] = metsToKeep(dataOrg, metRep, calRelErr, param)
%
% removes the metabolomics measurements from the 
% dataOrg table that have low measurement quality based on the relative SD 
% of technical replicate sample (RSDqc provided in the metRep variable) 
% and/or the average relative error (measured vs actual concentration) of 
% the calibration line samples (RE provided in the calRelErr variable)
%
% USAGE:
%   [cleanedData, metToKeepSummary] = metsToKeep(dataOrg, metRep, calRelErr, param)
%
% INPUTS:
%  dataOrg:     A table with original metabolomics data in a long format 
%               with information about measured samples, compounds, 
%               retention times (RT), area(s), concentrations, etc. 
%               the following column is required for the analysis:
%
%                     * .compound - compound (metabolite names) identical
%                                   to the names used in the metRep and 
%                                   calRE variables       
%  metRep:      A table with quality information based on the dataOrg 
%               in a long format (output from mzQuality tool).
%               The following columns are required for the analysis:
%
%                     * .compound - compound (metabolite names) identical
%                                   to the names used in the dataOrg and 
%                                   calRE variables 
%                     * .RSDqc_* - one or more columns specifying the
%                                  relative standard deviation of the 
%                                  repeated measurement of a (quality) 
%                                  sample (per batch) per metabolite         
%  calRelErr:   A table with quality information about the relative 
%               error (RE) of the concentration estimation of the 
%               calibration line samples based on the dataOrg 
%               in a long format with information about measured samples, 
%               compounds, retention times (RT), known concentrations, 
%               estimated concentrations, and relative error etc. 
%               The following columns are required for the analysis:
%
%                     * .compound - compound (metabolite names) identical
%                                   to the names used in the dataOrg and 
%                                   calRE variables 
%                     * .RE* - a columns specifying the relative error of 
%                              the concentration estimation of the
%                              calibration line samples
%  param.tresholdRSDqc: the treshold value for the relative SD of the repeated 
%                       measurement of sample (default = 25 (%); based on 
%                       the based on the "Guidelines and considerations for 
%                       the use of system suitability and quality control 
%                       samples in mass spectrometry assays applied in 
%                       untargeted clinical metabolomic studies")
%  param.tresholdCalRE: the treshold value for the relative error of the 
%                       concentration estimation of the calibration line 
%                       samples (default = 25 (%)
%
% OUTPUTS:
%  cleanedData:         table in the same format as dataOrg without the 
%                       metabolites of low quality (above set tresholds)
%  metToKeepSummary:    table in the same format as metRep variable with an
%                       added columns: 
%                     
%                     * .keep -     specifies whether a metabolite is to be 
%                                   kept (1) or removed (0) from the further 
%                                   analysis
%                     * .REcheck - specifies whether a metabolite passed
%                                   (1) or failed (0) the check based on 
%                                   the relative error of the concentration 
%                                   estimation of the calibration line sample 
%                     * .RSDqcCheck - specifies whether a metabolite passed
%                                     (1) or failed (0) the check based on 
%                                     the relative standard deviation of 
%                                     the repeated measurement of a (QC) sample
%                     * .sumRE -    shows the average relative error of the 
%                                   concentration estimation of the 
%                                   calibration line sample per metabolite
%
% EXAMPLE:
%
% NOTE:
%
% Author(s): Agnieszka Wegrzyn (2021)


if exist('param', 'var')
    if isfield(param, "tresholdRSDqc")
        tresholdRSDqc = param.tresholdRSDqc;
    else
        tresholdRSDqc = 25;
    end
    if isfield(param, "tresholdCalRE")
        tresholdCalRE = param.tresholdCalRE;
    else
        tresholdCalRE = 25;
    end
else
    tresholdRSDqc = 25;
    tresholdCalRE = 25;
end

metToKeep = metRep;
calRE = calRelErr;
calRE.RE(isnan(calRE.RE)) = 0;
calRE.RE(isinf(calRE.RE)) = NaN;
metToKeep.REcheck = zeros(length(metToKeep.compound),1);
metToKeep.RSDqcCheck = zeros(length(metToKeep.compound),1);
for i=1:length(metToKeep.compound)
    if sum(ismember(calRE.compound,metToKeep.compound(i))) ~= 0
        avrCalRE = mean(calRE.RE(ismember(calRE.compound,metToKeep.compound(i))),'omitnan');
        sdCalRE = std(calRE.RE(ismember(calRE.compound,metToKeep.compound(i))),'omitnan');
        metToKeep.sumRE(i) = avrCalRE;
        %check if average + 1SD (to account for an outlier) of RE is below the set treshold
        if (avrCalRE + sdCalRE) > tresholdCalRE
            metToKeep.REcheck(i) = 0;
        else
            metToKeep.REcheck(i) = 1;
        end
    else
        metToKeep.sumRE(i) = NaN;
    end
    if all(table2array(metToKeep(i,contains(metToKeep.Properties.VariableNames, 'RSDqc_'))) <= tresholdRSDqc)
        metToKeep.RSDqcCheck(i) = 1;
    else
        metToKeep.RSDqcCheck(i) = 0;
    end
    if metToKeep.RSDqcCheck(i) == 1 && metToKeep.REcheck(i) == 1
        metToKeep.Var1(i) = 1;
    else
        metToKeep.Var1(i) = 0;
    end
end
metToKeepSummary = metToKeep;
metToKeepSummary.Properties.VariableNames(1) = "keep";
cleanedData = dataOrg;
cleanedData(contains(cleanedData.compound,metToKeepSummary.compound(metToKeepSummary.keep == 0)),:)= [];
cleanedData(:,1)= [];
disp(' ')
disp('--------------------------------------------------------------')
disp(['Number of metabolites in the dataset: ' num2str(numel(metToKeepSummary.compound))])
disp(['Number of metabolites left after quality check: ' num2str(sum(metToKeepSummary.keep))])
disp(' ')




