function [main, mid] = optEnvelope(model, desiredProduct, varargin)
% optEnvelope uses MILP to find minimum active reactions and then finds 
% smallest set of reactions in the pool of inactive reactions that offers  
% same production envelope.
% Algorith provides multiple ways to reinsert reactions - sequential,
% MILP, GA(under construction)
%
%   EXAMPLE: [knockouts, midKnockouts] = optEnvelope(model, 'EX_ac_e', 'timeLimit', 600, 'protectedRxns', {'H2Ot_f','H2Ot_b'}, 'midPoints', 15);
%
% INPUT
%  model              COBRA model structure
%  desiredProduct     Reaction ID of desired product
%
%  protectedRxns      (opt) Aditional reactions to ignore (must be in irreversible form) (default: {})
%  numTries           (opt) Number of iteration for finding best possible set of deletions (default: [])
%  numKO              (opt) Number of reactions to remove for final result (triggers MILP for reaction reinsertion) (default: [])
%  prodMol            (opt) Molar mass of product for yield plot (g/mol) (default: [])
%  midPoints          (opt) Number of points to check along the edge for best envelope (default: 10)
%  timeLimit          (opt) Time limit for gurobi optimization (also limits time for numTries) (default: inf)
%  printLevel         (opt) Print level for gurobi optimization (default: 0)
%  drawEnvelope       (opt) Binary value to determine if algorithm should draw envelopes (default: true)
%  delGenes           (unfinished function)
%  delEnzymes         (unfinished function)
%  GAon               (unfinished function)
%
% OUTPUT
%  knockouts          List of which reactions to remove for the optimal
%                     envelope
%  midKnockoutsTable  Table of reactions to remove for midpoint envelopes
%
% NOTES
%  It should be mentioned that a figure (desired product versus biomass)
%  including plots for wild-type and opt enveople is presented after
%  running optEnvelope
%  Mid Envelopes currently work only for sequential (default) reinsertions
%
% created by  Ehsan Motamedian     02/09/2022
% modified by Kristaps Berzins     06/12/2022
% modified by Ehsan Motamedian     25/01/2023 switch to middle points was added
% modified by Kristaps Berzins     30/09/2024 improved algorightms, fixed bugs, added functionality


%% 0. Set parameters
parser = inputParser();
parser.addRequired('model', @(x) isstruct(x) && isfield(x, 'S') && isfield(model, 'rxns')...
    && isfield(model, 'mets') && isfield(model, 'lb') && isfield(model, 'ub') && isfield(model, 'b')...
    && isfield(model, 'c'))
parser.addRequired('desiredProduct', @(x) ischar(x))
parser.addParameter('protectedRxns', {}, @(x) iscell(x) && ismatrix(x));
parser.addParameter('numTries', [], @(x) isnumeric(x));
parser.addParameter('numKO', [], @(x) isnumeric(x));
parser.addParameter('prodMol', [], @(x) isnumeric(x));
parser.addParameter('midPoints', 0, @(x) isnumeric(x));
parser.addParameter('timeLimit', inf, @(x) isnumeric(x));
parser.addParameter('printLevel', 0, @(x) isnumeric(x) || islogical(x));
parser.addParameter('drawEnvelope', true, @(x) islogical(x));
parser.addParameter('delGenes', false, @(x) islogical(x));
parser.addParameter('delEnzymes', false, @(x) islogical(x));
parser.addParameter('GAon', false, @(x) islogical(x));

parser.parse(model, desiredProduct, varargin{:});
model = parser.Results.model;
desiredProduct = parser.Results.desiredProduct;
protectedRxns = parser.Results.protectedRxns;
numTries = parser.Results.numTries;
numKO = parser.Results.numKO;
prodMol = parser.Results.prodMol;
midPoints = parser.Results.midPoints;
timeLimit = parser.Results.timeLimit;
printLevel = parser.Results.printLevel;
drawEnvelope = parser.Results.drawEnvelope;
delGenes = parser.Results.delGenes;
delEnzymes = parser.Results.delEnzymes;
GAon = parser.Results.GAon;

if isempty(prodMol)
    prodMolIs = false;
else
    prodMolIs = true;
end

[model, matchRev, ~, ~] = convertToIrreversible(model);
toDel = [];
if ~delGenes && ~delEnzymes
    toDel = 0;
    K = findExcRxns(model); K = model.rxns(K); K = findRxnIDs(model, K);
    if ~isempty(protectedRxns)
        KOid = findRxnIDs(model, protectedRxns);
        if any(KOid == 0)
            disp('At least one of reactions are not in the model - ignoring those')
            KOid(KOid == 0) = [];
        end
        K = [K; KOid'];
    end
    K = unique(K);
elseif delGenes && isfield(model, 'grRules')
    error('Gene deletion part is not finished in this version of optEnvelope');
    toDel = 1;
    if delEnzymes
        disp('Deleting genes only') %change this later
    end
    K = find(cellfun(@isempty, model.grRules));
elseif delEnzymes
    error('Enzyme deletion part is not finished in this version of optEnvelope');
    toDel = 2;
end

biomass = model.rxns(model.c == 1);
biomass = biomass{1};

desiredProductName = model.metNames(logical(abs(model.S(:, findRxnIDs(model, desiredProduct)))));
desiredProductName = desiredProductName{1};

if prodMolIs
    input = model.rxns(model.ub < max(model.ub));
    numSub = size(input, 1);
    if numSub > 1
        prompt = {'Choose substrate reaction'};
        answer = listdlg('PromptString', prompt, 'SelectionMode', 'single', 'ListString', input);
    else
        answer = 1;
    end
    subUptake = model.ub(findRxnIDs(model, input(answer)));
    formula = model.metFormulas(logical(abs(model.S(:, findRxnIDs(model, input(answer))))));
    formula = formula{:};
    C = 12;
    H = 1;
    O = 16;
    indC = strfind(formula, 'C');
    indH = strfind(formula, 'H');
    indO = strfind(formula, 'O');
    C = C * str2double(formula(indC + 1:indH - 1));
    H = H * str2double(formula(indH + 1:indO - 1));
    O = O * str2double(formula(indO + 1:end));
    molarSum = C + H + O;
end

%% 1. Create wild-type envelope

if drawEnvelope
    figure('Name', 'optEnvelope')
    hold on
    if prodMolIs
        p1 = addEnv(model, biomass, desiredProduct, {}, 'b', prodMol, subUptake, molarSum);
        xlabel('Biomass(1/h)')
        ylabel([desiredProductName, ' production (mmol/gDCW/h)'])
    else
        p1 = addEnv(model, biomass, desiredProduct, {}, 'b');
        xlabel('Biomass(1/h)')
        ylabel([desiredProductName, ' production (mmol/gDCW/h)'])
    end
end

%% 2. Find MAR

% Setup for minActiveRxns function
sTemp = optimizeCbModel(model);
minP = struct;
minP.bioID = findRxnIDs(model, biomass);
minP.bioMin = 0.01 * sTemp.f;
minP.bioMax = sTemp.f;
minP.proID = findRxnIDs(model, desiredProduct);
modelTemp = changeObjective(model, desiredProduct);
sTemp = optimizeCbModel(modelTemp);
minP.proMin = 0.01 * sTemp.f;
minP.proMax = sTemp.f;
% Main function to find MAR
[data]=minActiveRxns(model, matchRev, K,  minP, toDel, timeLimit, midPoints, printLevel);

%% 2. Reduce the number of knockouts to minimum possible and calculate midEnvelopes

warning off
if isempty(numKO)
    [knockouts, midKnockouts] = sequentialOEReinserts(model, data, K, toDel, minP, midPoints, numTries, timeLimit);
else
    [knockouts] = milpOEReinserts(model, data, K, toDel, minP, numKO, timeLimit, printLevel);
end
warning on

%% 3. Plot envelopes

if drawEnvelope
    if ~isempty(knockouts)
        if prodMolIs
            p3 = addEnv(model,biomass, desiredProduct, knockouts, 'r', prodMol, subUptake, molarSum);
        else
            p3 = addEnv(model,biomass, desiredProduct, knockouts, 'r');
        end
        [x_main, idx] = max(p3.XData);
        y_main = p3.YData(idx);
        main.peak.x = x_main;
        main.peak.y = y_main;

        if midPoints ~= 0
            p={};
            mem = zeros(midPoints,2);
            for i=1:midPoints
                tempKOs = midKnockouts(:,i);
                tempKOs = tempKOs(~cellfun('isempty',tempKOs));
                tempKOs = cat(1, tempKOs{:});
            	formula = 1-exp(-0.08*length(tempKOs));%1/(1+exp((length(knockouts)-length(tempKOs))/4));
                colour = [0,1-formula,0];
                legendInfo{i}=[num2str(i),'. Deletions = ',num2str(length(tempKOs))];
                if prodMolIs
                    p{i} = addEnv(model, biomass, desiredProduct, tempKOs, colour, prodMol, subUptake, molarSum);
                else
                    p{i} = addEnv(model, biomass, desiredProduct, tempKOs, colour);
                    [x, idx] = max(p{i}.XData);
                    y = p{i}.YData(idx);
                    mem(i,:) = [x,y];
                end
            end
            [C, ~, ic] = unique(mem, 'rows');
            for i = 1:size(C, 1)
                str = [];
                for j = 1:length(ic)
                    if i == ic(j)
                        str = char(str, num2str(j));
                    end
                end
                text(C(i, 1), C(i, 2), str)
            end
            try
                legend([[p1 p3],p{:}],[{'Wild-type','optEnvelope - Primary Envelope'},legendInfo])
            catch
                legend([p1 p3],{'Wild-type','optEnvelope - Primary Envelope'})
            end
        else
            legend([p1 p3],{'Wild-type','optEnvelope'})
            midKnockouts = [];
        end
    else
        disp('No envelope found')
    end
    hold off
end

for i=1:length(knockouts)
    if contains(knockouts{i},'_f') || contains(knockouts{i},'_r') || contains(knockouts{i},'_b')
        knockouts{i} = knockouts{i}(1:end-2);
    end
end
main.knockouts = knockouts; %preparing output for main envelope

if ~isempty(midKnockouts)
    for i=1:numel(midKnockouts)        
        for j=1:length(midKnockouts{i})
            if contains(midKnockouts{i}{j},'_f') || contains(midKnockouts{i}{j},'_r') || contains(midKnockouts{i}{j},'_b')
                midKnockouts{i}{j} = midKnockouts{i}{j}(1:end-2);
            end
        end
    end
    midKnockoutsTable = cell2table(midKnockouts, 'VariableNames', linspace(1, i, i) + ". ");
    mid.midKnockoutsTable = midKnockoutsTable;  %preparing output for mid envelopes
    mid.peak.x = mem(:,1);
    mid.peak.y = mem(:,2);
end
