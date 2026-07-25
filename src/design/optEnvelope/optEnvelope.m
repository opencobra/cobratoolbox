function [main, mid] = optEnvelope(model, desiredProduct, varargin)
% optEnvelope finds a minimal set of knockouts for a production envelope
%
% Uses a MILP to find the minimum set of active reactions and then finds the
% smallest set of reactions in the pool of inactive reactions that offers the
% same production envelope. The algorithm provides multiple ways to reinsert
% reactions: sequential, MILP and GA (under construction).
%
% USAGE:
%
%    [main, mid] = optEnvelope(model, desiredProduct, varargin)
%
% INPUTS:
%    model:             COBRA model structure with fields:
%
%                         * .S - Stoichiometric matrix
%                         * .rxns - Reaction identifiers
%                         * .mets - Metabolite identifiers
%                         * .lb - Lower bounds
%                         * .ub - Upper bounds
%                         * .b - Right hand side values for metabolite constraints
%                         * .c - Objective coefficients
%                         * .grRules - Readable gene-protein-reaction rules
%                         * .metNames - Metabolite names
%                         * .metFormulas - Elemental formulas
%    desiredProduct:    Reaction name of desired product [char]
%
% OPTIONAL INPUTS:
%    varargin:          Parameters given as parameter name / value pairs:
%
%                         * protectedRxns - Additional reactions to ignore
%                           (must be in irreversible form) [cell array] (default: {})
%                         * numTries - Iterations for finding the best set of
%                           deletions [double] (default: [])
%                         * numKO - Number of reactions to remove for the final
%                           result (triggers MILP reinsertion) [double] (default: [])
%                         * prodMol - Molar mass of product for a yield plot
%                           (g/mol) [double] (default: [])
%                         * midPoints - Number of points to check along the
%                           edge for the best envelope [double] (default: 0)
%                         * timeLimit - Time limit for the solver in seconds
%                           (also limits numTries) [double] (default: inf)
%                         * printLevel - Print level for the solver [double]
%                           (default: 0)
%                         * drawEnvelope - Whether the algorithm should draw
%                           envelopes [logical] (default: true)
%                         * delGenes - Delete genes (unfinished) [logical]
%                           (default: false)
%                         * delEnzymes - Delete enzymes (unfinished) [logical]
%                           (default: false)
%                         * GAon - Use genetic algorithm (unfinished) [logical]
%                           (default: false)
%
% OUTPUTS:
%    main:              Struct with information about the reactions to remove
%                       for the optimal envelope and its most probable point
%                       (fields .knockouts and .peak)
%    mid:               Struct with information about the reactions to remove
%                       for the midpoint envelopes and their most probable
%                       points (fields .midKnockoutsTable and .peak)
%
% EXAMPLE:
%
%    [mainKnockouts, midKnockouts] = optEnvelope(model, 'EX_ac_e', 'timeLimit', 600, 'midPoints', 15)
%
% NOTE:
%    A figure (desired product versus biomass) including plots for the
%    wild-type and the opt envelope is presented after running optEnvelope.
%    Mid envelopes currently work only for sequential (default) reinsertions.
%
% .. Authors:
%       - Ehsan Motamedian, 02/09/2022, created
%       - Kristaps Berzins, 06/12/2022, modified
%       - Ehsan Motamedian, 25/01/2023, switch to middle points added
%       - Kristaps Berzins, 30/09/2024, improved algorithms, fixed bugs, added functionality


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
    [knockouts] = milpOEReinserts(model, data, K,  minP, numKO, toDel, timeLimit, printLevel);
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
