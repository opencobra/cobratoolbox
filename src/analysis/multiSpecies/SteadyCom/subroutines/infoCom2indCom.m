function indCom = infoCom2indCom(modelCom, infoCom, revFlag, spAbbr, spName)
% Interconvert between community reaction/metabolite IDs (indCom) and names (infoCom).
% Both infoCom and indCom can be obtained using with getMultiSpeciesModelId.m
% This function helps to quickly convert between the two if one is missing.
%
% USAGE:
%    [1] indCom = infoCom2indCom(modelCom, infoCom)
%      OR
%    [2] infoCom = infoCom2indCom(modelCom, indCom, true, spAbbr, spName)
%
% INPUTS:
%    modelCom:      community COBRA model.
%  (for converting infoCom to indCom, usage [1])
%    infoCom:       structure containing community reaction/metabolite names
%                     If modelCom.infoCom exists, can omit this argument.
%  (for converting indCom to infoCom, usage [2])
%    indCom:        structure containing community reaction/metabolite IDs
%    spAbbr:        organisms' abbreviations
%    spName:        organisms' names (optional, default = spAbbr)
if nargin < 2
    if ~isfield(modelCom, 'infoCom')
        error('infoCom must be provided.\n');
    end
    infoCom = modelCom.infoCom;
end
if nargin < 3
    revFlag = false;
end
indCom = struct();
if ~revFlag
    %from infoCom to indCom
    if isfield(infoCom, 'spBm')
        indCom.spBm = findRxnIDs(modelCom, infoCom.spBm);
    end
    if isfield(infoCom, 'spATPM')
        indCom.spATPM = findRxnIDs(modelCom, infoCom.spATPM);
    end
    if isfield(infoCom, 'rxnSD')
        indCom.rxnSD = findRxnIDs(modelCom, infoCom.rxnSD);
    end
    indCom.EXcom = findRxnIDs(modelCom, infoCom.EXcom);
    indCom.EXsp = zeros(size(infoCom.EXsp));
    SpCom = ~cellfun(@isempty, infoCom.EXsp);
    indCom.EXsp(SpCom) = findRxnIDs(modelCom, infoCom.EXsp(SpCom));
    if isfield(infoCom, 'EXhost') 
        if ~isempty(infoCom.EXhost)
            indCom.EXhost = findRxnIDs(modelCom, infoCom.EXhost);
        else
            indCom.EXhost = zeros(0, 1);
        end
    end
    indCom.Mcom = findMetIDs(modelCom, infoCom.Mcom);
    indCom.Msp = zeros(size(infoCom.Msp));
    if isfield(infoCom, 'Mhost') 
        if ~isempty(infoCom.Mhost)
            indCom.Mhost = findMetIDs(modelCom, infoCom.Mhost);
        else
            indCom.Mhost = zeros(0, 1);
        end 
    end
    SpCom = ~cellfun(@isempty, infoCom.Msp);
    indCom.Msp(SpCom) = findMetIDs(modelCom, infoCom.Msp(SpCom));
    [~, indCom.rxnSps] = ismember(infoCom.rxnSps, infoCom.spAbbr);
    [~, indCom.metSps] = ismember(infoCom.metSps, infoCom.spAbbr);
else
    %from indCom to infoCom
    if nargin < 4
        error('spAbbr must be provided to get the organisms'' abbreviations');
    end
    if nargin < 5
        spName = spAbbr;
    end
    if isfield(infoCom, 'spBm')
        indCom.spBm = modelCom.rxns(infoCom.spBm);
    end
    if isfield(infoCom,'spATPM')
        indCom.spATPM = modelCom.rxns(infoCom.spATPM);
    end
    if isfield(infoCom,'rxnSD')
        indCom.rxnSD = modelCom.rxns(infoCom.rxnSD);
    end
    indCom.EXcom = repmat({''}, size(infoCom.EXcom, 1), size(infoCom.EXcom, 2));
    indCom.EXcom(infoCom.EXcom ~= 0) = modelCom.rxns(infoCom.EXcom(infoCom.EXcom ~= 0));
    indCom.EXsp = repmat({''}, size(infoCom.EXsp, 1), size(infoCom.EXsp, 2));
    SpCom = infoCom.EXsp ~= 0;
    indCom.EXsp(SpCom) = modelCom.rxns(infoCom.EXsp(SpCom));
    if isfield(infoCom, 'EXhost') 
        if ~isempty(infoCom.EXhost)
            indCom.EXhost = modelCom.rxns(infoCom.EXhost);
        else
            indCom.EXhost = cell(0, 1);
        end
    end
    indCom.Mcom = modelCom.mets(infoCom.Mcom);
    indCom.Msp = repmat({''},size(infoCom.Msp,1), size(infoCom.Msp,2));
    SpCom = infoCom.Msp ~= 0;
    indCom.Msp(SpCom) = modelCom.mets(infoCom.Msp(SpCom));
    if isfield(infoCom, 'Mhost') 
        if ~isempty(infoCom.Mhost)
            indCom.Mhost = modelCom.mets(infoCom.Mhost);
        else
            indCom.Mhost = cell(0, 1);
        end
    end
    indCom.spAbbr = spAbbr;
    indCom.spName = spName;
    indCom.rxnSps = repmat({'com'}, numel(modelCom.rxns), 1);
    indCom.rxnSps(infoCom.rxnSps > 0) = spAbbr(infoCom.rxnSps(infoCom.rxnSps > 0));
    indCom.metSps = repmat({'com'}, numel(modelCom.mets), 1);
    indCom.metSps(infoCom.metSps > 0) = spAbbr(infoCom.metSps(infoCom.metSps > 0));
end
end