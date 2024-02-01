function [graph_data, summary] = metUtilisation(model, met, flux_v, printFig, param)
%metUtilisation - a graph analysis of reactions producing and consuming given
%metabolite
%
%   This function can be used to visualise the fluxes of the reactions
%   that either produce or consume certain metabolite. User can choose
%   whether to only study a generic topography or add flux estimation to
%   the graph to visualise the major producers and consumers of a
%   metabolite. Flux can be given either as a single vector, as a pair of
%   vector for a comparison between two different predictions, or as a
%   sampling matrix, in which case a meana and standard deviation will be
%   used to estimate idividual contributions of each reaction to the total
%   metabolite balance
%
% USAGE:
%
%    [graph, summary] = metUtilisation(model,mets, flux_v, printFig, param)
%
% INPUT:
%    model:     A generic COBRA model
%
%                     * .S - Stoichiometric matrix
%                     * .mets - Metabolite ID vector
%                     * .rxns - Reaction ID vector
%                     * .lb - Lower bound vector
%                     * .ub - Upper bound vector
%
%    met:     A string with metabolite ID with or without compartment
%               information (e.g. 'atp[c]' or 'atp') as found in model.mets;
%               if no compartment information provided, function will
%               include all compartments for the analysis
%
% OPTIONAL INPUTS:
%    flux_v:    A single flux distribution vector (as obtained from optimisation
%               algorithm, e.g. FBA) or a matrix (if obtained from flux
%               sampling).
%               Or an array [control_v perturbation_v] containing two flux
%               vectors provided to perform a comparison between two conditions.
%               The first vector is then used as a control, and second as
%               a perturbation to be plotted.
%               Or a matrix containing the results of the flux sampling
%               algorithm.
%               (default = {})
%   printFig:   Logical, whether figure should be printed out (default = 1)
%   param:      a structure containg additional parameters for the function
%               and plotting:
%
%                     *.treshold_v     - flux value below which reaction is
%                                        considered active (default = 1e-6)
%                     *.NodeLabels     - what value should be plotted as a 
%                                        node edge: 'rxns' for reaction 
%                                        abbreviation or 'rxnNames' for a 
%                                        full reaction name (default = 'rxns') 
%                     *.EdgeLabel.rxns - cell array containg reaction IDs
%                                        (in the format of model.rxns)
%                     *.EdgeLabel.text - cell array containg labels to be
%                                        ploted on the graph edges (same
%                                        length as EdgeLabel.rxns)
%
% OUTPUTS:
%
%	graph:      matlab graph with metabolite as a central node and reactions
%               producing (left) and consuming (right) metabolite as nodes,
%               if v is provided, the tickness of edges (weight) represents 
%               a relative contribution of each reaction to the metabolite
%               utilisation
%
%   graph_data: additional data used for plotting (can be used to modify
%               final graph aesthetics)
%                     *.edgeLabels - labels used to describe edges
%                     *.LWidths - scaled widths of edges based on the weights
%                     *.graph - matlab graph with metabolite as a central 
%                               node and reactions producing (left) and 
%                               consuming (right) metabolite as nodes,
%                               if v is provided, the tickness of edges 
%                               (weight) represents a relative contribution 
%                               of each reaction to the metabolite utilisation
%                     *.eColour - colours used for the edges
%                     *.nLabels - labels used to describe nodes
%
%   summary:    table consisting of all reactions (rxns) identified as nodes,
%               together with their full reaction name (rxnNames), ID in the model (rxnsIDs),
%               stoichimeric coefficient (scoff) representing if metabolite
%               is consumed (-1) or produced (1) by the reaction,
%               reaction formulas, flux values, either as a single flux
%               vector, a pair of vectors used for comparison (flux_v1, flux_v2)
%               or summary statistics from flux sampling data (mean, median, mode, and
%               standard deviation), and in case of the comparison between
%               two flux vectors, labels showing the relative increase,
%               decrease or no change between the two vectors
%
% Author(s): Agnieszka Wegrzyn

modelOrg = model;

if (nargin < 2)
    error('Model structure and metabolite ID have not been provided')
end

if (nargin < 3)
    disp(' ')
    fprintf('%s\n', 'No flux vector provided. Unweighted graph will be generated.')
    disp(' ')
    flux_v = {};
    printFig = 1;
end

if (nargin < 4)
    disp(' ')
    fprintf('%s\n', 'Figure will be printed.')
    disp(' ')
    printFig = 1;
end

if (nargin < 5)
    disp(' ')
    fprintf('%s\n', 'Default values for flux treshold (1e-6) and labels will be used')
    disp(' ')
    param.treshold_v = 1e6;
end

if ~isfield(param, 'NodeLabels')
    param.NodeLabels = 'rxns';
end

feasTol = getCobraSolverParams('LP','feasTol');

if ismember(met, modelOrg.mets)
    ID = find(strcmp(modelOrg.mets, met));
    rxns = modelOrg.rxns(find(modelOrg.S(ID,:)~=0));
    rxnNames = modelOrg.rxnNames(find(modelOrg.S(ID,:)~=0));
    scoff = full(modelOrg.S(ID,find(modelOrg.S(ID,:)~=0))');
else
    IDs = find(~cellfun(@isempty, regexp(modelOrg.mets,['^' met '[\w'])));

    if isempty(IDs)
        error('Metabolite not found! Check if the metabolite exists in model.mets')
    else
        %finds all reactions producing or consuming metabolite but exclude
        %transport reactions for that metabolite (e.g. met[c] <=> met[m])
        rxns = modelOrg.rxns(find(sum(modelOrg.S(IDs,:),1)~=0)');
        rxnNames = modelOrg.rxnNames(find(sum(modelOrg.S(IDs,:),1)~=0)');
        scoff = full(sum(modelOrg.S(IDs,find(sum(modelOrg.S(IDs,:),1)~=0)),1)');
    end
end

rxnsIDs = findRxnIDs(modelOrg, rxns);
rxnsFormulas = printRxnFormula(modelOrg, rxns, 0);

if isempty(flux_v)
    
    summary = table(rxns, rxnNames, rxnsIDs, scoff, rxnsFormulas);
    summary.Properties.VariableNames = {'rxns', 'rxnNames', 'rxnsIDs', 'scoff', 'rxnsFormula'};

elseif isvector(flux_v)
    
    summary = table(rxns, rxnNames, rxnsIDs, scoff, rxnsFormulas, flux_v(rxnsIDs));
    summary.Properties.VariableNames = {'rxns', 'rxnNames', 'rxnsIDs', 'scoff', 'rxnsFormula', 'flux_v'};

elseif length(flux_v(1,:)) == 2

    label = cell(length(flux_v(:,1)),1);

    %generates edges labels based on the difference between flux_v2 and
    %flux_v1

    for i=1:length(flux_v(:,1))
        if sign(flux_v(i,1)) == sign(flux_v(i,2)) % if fluxes have the same sign
            if abs(flux_v(i,1)) > abs(flux_v(i,2)) % if v1 > v2
                if round(abs(flux_v(i,2)) / abs(flux_v(i,1)),3) == 1
                    label{i,1} = ...
                        [num2str(abs(round(flux_v(i,2),3))) ' (0%)'];
                elseif abs(flux_v(i,1)) < feasTol && abs(flux_v(i,2)) < feasTol
                    label{i,1} = 'both inactive';
                elseif abs(flux_v(i,1)) < feasTol
                    label{i,1} = [num2str(abs(round(flux_v(i,2),3))) ' (inactive)'];
                elseif abs(flux_v(i,2)) < feasTol
                    label{i,1} = [num2str(abs(round(flux_v(i,2)))) ' (active ' num2str(abs(round(flux_v(i,1),3))) ')'];
                else
                    decrease = (abs(flux_v(i,1)) ...
                        - abs(flux_v(i,2))) / abs(flux_v(i,1));
                    label{i,1} = ...
                        [num2str(abs(round(flux_v(i,2),3))) ...
                        ' (-' num2str(round(decrease*100)) '%)'];
                end
            elseif abs(flux_v(i,1)) < abs(flux_v(i,2))
                if round(abs(flux_v(i,2)) / abs(flux_v(i,1)),3) == 1
                    label{i,1} = ...
                        [num2str(abs(round(flux_v(i,2),3))) ...
                        ' (0%)'];
                elseif abs(flux_v(i,1)) < feasTol && abs(flux_v(i,2)) < feasTol
                    label{i,1} = 'both inactive';
                elseif abs(flux_v(i,1)) < feasTol
                    label{i,1} = [num2str(abs(round(flux_v(i,2),3))) ' (inactive)'];
                elseif abs(flux_v(i,2)) < feasTol
                    label{i,1} = [num2str(abs(round(flux_v(i,2)))) ' (active ' num2str(abs(round(flux_v(i,1),3))) ')'];
                else
                    increase = (abs(flux_v(i,2)) ...
                        - abs(flux_v(i,1))) / abs(flux_v(i,1));
                    label{i,1} = ...
                        [num2str(abs(round(flux_v(i,2),3))) ...
                        ' (+' num2str(round(increase*100)) '%)'];
                end
            elseif abs(flux_v(1,1)) < feasTol && abs(flux_v(1,2)) < feasTol
                    label{i,1} = 'both inactive';
            else
                label{i,1} = ...
                    [num2str(abs(round(flux_v(i,2),3))) ' (0%)'];
            end
        else
            label{i,1} = ...
                [num2str(round(flux_v(i,2),3)) ...
                ' (sign change! from ' num2str(round(flux_v(i,1),3)) ')'];
        end
    end

    summary = table(rxns, rxnNames, rxnsIDs,  scoff, rxnsFormulas, flux_v(rxnsIDs,1), flux_v(rxnsIDs,2), label(rxnsIDs));
    summary.Properties.VariableNames = {'rxns', 'rxnNames', 'rxnsIDs', 'scoff', 'rxnsFormula', 'flux_v1', 'flux_v2', 'label'};
else
    summary = table(rxns, rxnNames, rxnsIDs,  scoff, rxnsFormulas, ...
        mean(flux_v(rxnsIDs,:),2), std(flux_v(rxnsIDs,:),0,2), ...
        median(flux_v(rxnsIDs,:),2), mode(flux_v(rxnsIDs,:),2));
    summary.Properties.VariableNames = {'rxns', 'rxnNames', 'rxnsIDs', 'scoff', ...
        'rxnsFormula', 'mean(flux_v)', 'sd(flux_v)', 'median(flux_v)', ...
        'mode(flux_v)'};
end

% select only active reactions for graph (if flux_v is provided) otherwise
% plot all reactions

if isempty(flux_v)

    nodes = cell(length(rxnsIDs),1);
    edges = cell(length(rxnsIDs),1);
    eColour = zeros(length(rxnsIDs),3);
    for i=1:length(rxnsIDs)
        if summary.scoff(i) < 0 && modelOrg.lb(i) == 0 %consumption (blue)
            nodes{i,1} = met;
            edges{i,1} = rxns{i};
        elseif summary.scoff(i) > 0 && modelOrg.lb(i) == 0 %production (red)
            nodes{i,1} = rxns{i};
            edges{i,1} = met;
        elseif summary.scoff(i) < 0 && modelOrg.lb(i) ~= 0  %reversible consumption (black)
            nodes{i,1} = met;
            edges{i,1} = rxns{i};
        elseif summary.scoff(i) > 0 && modelOrg.lb(i) ~= 0 %reversible production (black)
            nodes{i,1} = rxns{i};
            edges{i,1} = met;
        end
    end

    graph = digraph(nodes,edges);
    nLabels = graph.Nodes.Variables;

    for i=1:length(graph.Edges.EndNodes)

        if contains(graph.Edges.EndNodes{i,1},met) %consumption
            revFlag = modelOrg.lb(findRxnIDs(modelOrg, graph.Edges.EndNodes{i,2})) ~= 0;
            if revFlag % reversible reaction (forward consumption, reverse production)
                eColour(i,:) = [0 0 0];
            else %irreversible (always consumption)
                eColour(i,:) = [0 0.4470 0.7410];
            end
        elseif contains(graph.Edges.EndNodes{i,2},met) %production
            revFlag = modelOrg.lb(findRxnIDs(modelOrg, graph.Edges.EndNodes{i,1})) ~= 0;
            if revFlag % reversible reaction (forward production, reverse consumption)
                eColour(i,:) = [0 0 0];
            else %irreversible (always production)
                eColour(i,:) = [0.6350 0.0780 0.1840];
            end
        end
    end
    if printFig == 1 && strcmp(param.NodeLabels,'rxns')
        figure();
        set(groot, 'defaultTextInterpreter', 'none')
        plot(graph,'NodeLabel',nLabels,'EdgeColor', eColour, 'Interpreter','none');
        %layout(H,'layered','Direction','right')
        line(NaN,NaN,'Color','black','LineStyle','-')
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        legend([met ' utilisation network:'], 'reversible', 'production', 'consumption')
    end

    if printFig == 1 && strcmp(param.NodeLabels,'rxnNames')
        
        figure();
        set(groot, 'defaultTextInterpreter', 'none')
        set(groot,'defaultfigureposition',[250 250 1200 400])
        H = plot(graph,'NodeLabel',nLabels,'NodeFontSize',11, ...
            'EdgeColor',eColour, 'Interpreter','none');
        layout(H,'layered','Direction','right')
        AX = gca;
        AX.InnerPosition = [0.25,0,0.5,1];
        rxnNames1 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 1)));
        rxnNames3 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 3)));
        text(H.XData(H.XData == 2), H.YData(H.XData == 2)+0.5, H.NodeLabel(H.XData == 2), ...
            'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, ...
            'Interpreter','none')
        text(H.XData(H.XData == 1)-0.05, H.YData(H.XData == 1), rxnNames1, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'right', 'FontSize', 12, ...
            'Interpreter','none')
        text(H.XData(H.XData == 3)+0.05, H.YData(H.XData == 3), rxnNames3, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 12, ...
            'Interpreter','none')
        H.NodeLabel = {};

        line(NaN,NaN,'Color','black','LineStyle','-')
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        legend([met ' utilisation network:'], 'reversible', 'production', 'consumption')
        axis off
    end

    graph_data.graph = graph;
    graph_data.eColour = eColour;
    graph_data.nLabels = nLabels;

elseif isvector(flux_v)

    %find only active reactions from the list
    idx = find(summary.flux_v ~= 0);
    %exclude reactions based on a given treshold
    if isfield(param, 'treshold_v')
        idx = find(abs(summary.flux_v) > param.treshold_v);
    end

    activeRxns = rxns(idx);
    nodes = cell(length(idx),1);
    edges = cell(length(idx),1);
    weights = abs(summary.flux_v(idx));
    eColour = zeros(length(idx),3);

    for i=1:length(activeRxns)
        if summary.scoff(idx(i))*summary.flux_v(idx(i)) < 0 %consumption '#0072BD' [0 0.4470 0.7410]
            nodes{i,1} = met;
            edges{i,1} = activeRxns{i};
        elseif summary.scoff(idx(i))*summary.flux_v(idx(i)) > 0 %production '#A2142F'
            nodes{i,1} = activeRxns{i};
            edges{i,1} = met;
        end
    end


    graph = digraph(nodes,edges,weights);
    nLabels = graph.Nodes.Variables;
    LWidths = 7*graph.Edges.Weight/max(graph.Edges.Weight); %scale numbers

    if ~isfield(param, 'EdgeLabel')
        edgeLabels = round(graph.Edges.Weight,2);
    else
        for i=1:length(graph.Edges.EndNodes)
            if contains(graph.Edges.EndNodes(i,1),met)
                edgeLabels(i,1) = param.EdgeLabel.text(ismember(param.EdgeLabel.rxns, graph.Edges.EndNodes(i,2)));
            else
                edgeLabels(i,1) = param.EdgeLabel.text(ismember(param.EdgeLabel.rxns, graph.Edges.EndNodes(i,1)));
            end
        end
    end

    for i=1:length(graph.Edges.EndNodes)
        if contains(graph.Edges.EndNodes(i,1),met)
            eColour(i,:) = [0 0.4470 0.7410];
        else
            eColour(i,:) = [0.6350 0.0780 0.1840];
        end
    end

    if printFig == 1 && strcmp(param.NodeLabels,'rxns')
        figure();
        set(groot, 'defaultTextInterpreter', 'none')
        set(groot,'defaultfigureposition',[250 250 900 400])

        H = plot(graph,'NodeLabel',nLabels,'NodeFontSize',10,'EdgeColor',eColour, ...
            'EdgeLabel', edgeLabels,'LineWidth',LWidths, ...
            'ArrowSize', 10, 'ArrowPosition', 0.65, 'Interpreter','none');
        layout(H,'layered','Direction','right')
        AX = gca;
        AX.InnerPosition = [0.25,0,0.5,1];
        text(H.XData(H.XData == 2), H.YData(H.XData == 2)+1, H.NodeLabel(H.XData == 2), ...
            'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, ...
            'Interpreter','none')
        text(H.XData(H.XData == 1)-0.05, H.YData(H.XData == 1), H.NodeLabel(H.XData == 1), ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'right', 'FontSize', 10, ...
            'Interpreter','none')
        text(H.XData(H.XData == 3)+0.05, H.YData(H.XData == 3), H.NodeLabel(H.XData == 3), ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 10, ...
            'Interpreter','none')
        H.NodeLabel = {};
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        axis off
        legend([met ' utilisation network:'], 'production', 'consumption')
    end

    if printFig == 1 && strcmp(param.NodeLabels,'rxnNames')
        
        set(groot, 'defaultTextInterpreter', 'none')
        set(groot,'defaultfigureposition',[250 250 900 400])

        figure();
        
        H = plot(graph,'NodeLabel',nLabels,'NodeFontSize',10,'EdgeColor',eColour, ...
            'EdgeLabel', edgeLabels,'LineWidth',LWidths, ...
            'ArrowSize', 10, 'ArrowPosition', 0.65, 'Interpreter','none');
        layout(H,'layered','Direction','right')
        AX = gca;
        AX.InnerPosition = [0.25,0,0.5,1];
        rxnNames1 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 1)));
        rxnNames3 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 3)));
        text(H.XData(H.XData == 2), H.YData(H.XData == 2)+0.5, H.NodeLabel(H.XData == 2), ...
            'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, ...
            'Interpreter','none')
        text(H.XData(H.XData == 1)-0.05, H.YData(H.XData == 1), rxnNames1, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'right', 'FontSize', 12, ...
            'Interpreter','none')
        text(H.XData(H.XData == 3)+0.05, H.YData(H.XData == 3), rxnNames3, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 12, ...
            'Interpreter','none')
        H.NodeLabel = {};
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        legend([met ' utilisation network:'], 'production', 'consumption')
        axis off
    end

    graph_data.edgeLabels = edgeLabels;
    graph_data.LWidths = LWidths;
    graph_data.graph = graph;
    graph_data.eColour = eColour;
    graph_data.nLabels = nLabels;

    %make a comparison between flux_v1(control) and flux_v2(perturbation)
elseif length(flux_v(1,:)) == 2
    %find only active reactions from the list (flux higher than 1e-6)
    idx = find(abs(summary.flux_v2) > 1e-6 | abs(summary.flux_v1) > 1e-6);

    %exclude reactions based on a given treshold
    if isfield(param, 'treshold_v')
        idx = unique([find(abs(summary.flux_v2) > param.treshold_v); find(abs(summary.flux_v1) > param.treshold_v)]);
    end

    activeRxns = rxns(idx);
    nodes = cell(length(idx),1);
    edges = cell(length(idx),1);
    weights = abs(summary.flux_v2(idx));
    weights(weights==0) = 1e-6;
    eColour = zeros(length(idx),3);

    %provide automatic labels only if there are no user specified labels
    %provided in the param varaible
    if ~isfield(param, 'EdgeLabel')
        param.EdgeLabel.text = summary.label;
        param.EdgeLabel.rxns = summary.rxns;
    end

    for i=1:length(activeRxns)
        if summary.scoff(idx(i))*summary.flux_v2(idx(i)) < 0 %consumption '#0072BD' [0 0.4470 0.7410]
            nodes{i,1} = met;
            edges{i,1} = activeRxns{i};
        elseif summary.scoff(idx(i))*summary.flux_v2(idx(i)) > 0 %production '#A2142F'
            nodes{i,1} = activeRxns{i};
            edges{i,1} = met;
        elseif summary.scoff(idx(i))*summary.flux_v2(idx(i)) == 0 && summary.scoff(idx(i))*summary.flux_v1(idx(i)) < 0 %inactive, consumption in control 
            nodes{i,1} = met;
            edges{i,1} = activeRxns{i};
        elseif summary.scoff(idx(i))*summary.flux_v2(idx(i)) == 0 && summary.scoff(idx(i))*summary.flux_v1(idx(i)) > 0 %inactive, production in control 
            nodes{i,1} = activeRxns{i};
            edges{i,1} = met;
        end
    end


    graph = digraph(nodes,edges,weights);
    nLabels = graph.Nodes.Variables;
    LWidths = 7*graph.Edges.Weight/max(graph.Edges.Weight); %scale numbers

    if ~isfield(param, 'EdgeLabel')
        edgeLabels = round(graph.Edges.Weight,2);
    else
        for i=1:length(graph.Edges.EndNodes)
            if contains(graph.Edges.EndNodes(i,1),met)
                edgeLabels(i,1) = param.EdgeLabel.text(ismember(param.EdgeLabel.rxns, graph.Edges.EndNodes(i,2)));
            else
                edgeLabels(i,1) = param.EdgeLabel.text(ismember(param.EdgeLabel.rxns, graph.Edges.EndNodes(i,1)));
            end
        end
    end

    for i=1:length(graph.Edges.EndNodes)
        if contains(graph.Edges.EndNodes(i,1),met)
            eColour(i,:) = [0 0.4470 0.7410];
        else
            eColour(i,:) = [0.6350 0.0780 0.1840];
        end
    end

    if printFig == 1 && strcmp(param.NodeLabels,'rxns')

        set(groot,'defaultfigureposition',[250 250 900 400])
        set(groot, 'defaultTextInterpreter', 'none')

        figure();

        H = plot(graph,'NodeLabel',nLabels,'NodeFontSize',10,'EdgeColor',eColour, ...
            'EdgeLabel', edgeLabels,'LineWidth',LWidths, ...
            'ArrowSize', 10, 'ArrowPosition', 0.65, 'Interpreter','none');
        layout(H,'layered','Direction','right')
        AX = gca;
        AX.InnerPosition = [0.25,0,0.5,1];
        
        text(H.XData(H.XData == 2), H.YData(H.XData == 2)+1, H.NodeLabel(H.XData == 2), ...
            'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, ...
            'Interpreter','none')
        text(H.XData(H.XData == 1)-0.05, H.YData(H.XData == 1), H.NodeLabel(H.XData == 1), ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'right', 'FontSize', 10, ...
            'Interpreter','none')
        text(H.XData(H.XData == 3)+0.05, H.YData(H.XData == 3), H.NodeLabel(H.XData == 3), ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 10, ...
            'Interpreter','none')
        H.NodeLabel = {};
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        legend([met ' utilisation network:'], 'production', 'consumption')
         axis off
    end

    if printFig == 1 && strcmp(param.NodeLabels,'rxnNames')
        set(groot,'defaultfigureposition',[250 250 900 400])
        set(groot, 'defaultTextInterpreter', 'none')

        figure();

        H = plot(graph,'NodeLabel',nLabels,'NodeFontSize',10,'EdgeColor',eColour, ...
            'EdgeLabel', edgeLabels,'LineWidth',LWidths, ...
            'ArrowSize', 10, 'ArrowPosition', 0.65, 'Interpreter','none');
        layout(H,'layered','Direction','right')
        AX = gca;
        AX.InnerPosition = [0.25,0,0.5,1];

        rxnNames1 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 1)));
        rxnNames3 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 3)));
        text(H.XData(H.XData == 2), H.YData(H.XData == 2)+1, H.NodeLabel(H.XData == 2), ...
            'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, ...
            'Interpreter','none')
        text(H.XData(H.XData == 1)-0.05, H.YData(H.XData == 1), rxnNames1, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'right', 'FontSize', 10, ...
            'Interpreter','none')
        text(H.XData(H.XData == 3)+0.05, H.YData(H.XData == 3), rxnNames3, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 10, ...
            'Interpreter','none')
        H.NodeLabel = {};
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        legend([met ' utilisation network:'], 'production', 'consumption')
         axis off
    end

    graph_data.edgeLabels = edgeLabels;
    graph_data.LWidths = LWidths;
    graph_data.graph = graph;
    graph_data.eColour = eColour;
    graph_data.nLabels = nLabels;
    %plot average fluxes with their SD based on sampling results
    %find only active reactions from the list (average flux higher than 1e-6)
elseif length(flux_v(1,:)) > 2
    idx = find(round(summary.("mean(flux_v)"),6) ~= 0);

    %exclude reactions based on a given treshold
    if isfield(param, 'treshold_v')
        idx_secretions = find(summary.("mean(flux_v)") > param.treshold_v);
        idx_uptakes = find(summary.("mean(flux_v)") < param.treshold_v);
        idx = [idx_secretions; idx_uptakes];
    end

    activeRxns = rxns(idx);
    nodes = cell(length(idx),1);
    edges = cell(length(idx),1);
    weights = abs(summary.("mean(flux_v)"));
    eColour = zeros(length(idx),3);

    %provide automatic labels only if there are no user specified labels
    %provided in the param varaible
    if ~isfield(param, 'EdgeLabel')
        param.EdgeLabel.text = {};
        param.EdgeLabel.rxns = summary.metRxns;

        for i=1:length(summary.metRxns)
            param.EdgeLabel.text{i} = [num2str(round(summary.("mean(flux_v)")(i),3)) ' +/- ' num2str(round(summary.("sd(flux_v)")(i),3))];
        end
    end


    for i=1:length(activeRxns)
        if summary.scoff(idx(i))*summary.("mean(flux_v)")(idx(i)) < 0 %consumption '#0072BD' [0 0.4470 0.7410]
            nodes{i,1} = met;
            edges{i,1} = activeRxns{i};
        elseif summary.scoff(idx(i))*summary.("mean(flux_v)")(idx(i)) > 0 %production '#A2142F'
            nodes{i,1} = activeRxns{i};
            edges{i,1} = met;
        end
    end


    graph = digraph(nodes,edges,weights);
    nLabels = graph.Nodes.Variables;
    LWidths = 7*graph.Edges.Weight/max(graph.Edges.Weight); %scale numbers

    if ~isfield(param, 'EdgeLabel')
        edgeLabels = round(graph.Edges.Weight,2);
    else
        for i=1:length(graph.Edges.EndNodes)
            if contains(graph.Edges.EndNodes(i,1),met)
                edgeLabels(i,1) = param.EdgeLabel.text(ismember(param.EdgeLabel.rxns, graph.Edges.EndNodes(i,2)));
            else
                edgeLabels(i,1) = param.EdgeLabel.text(ismember(param.EdgeLabel.rxns, graph.Edges.EndNodes(i,1)));
            end
        end
    end

    for i=1:length(graph.Edges.EndNodes)
        if contains(graph.Edges.EndNodes(i,1),met)
            eColour(i,:) = [0 0.4470 0.7410];
        else
            eColour(i,:) = [0.6350 0.0780 0.1840];
        end
    end

    if printFig == 1 && strcmp(param.NodeLabels,'rxns')
        set(groot,'defaultfigureposition',[250 250 900 400])
        set(groot, 'defaultTextInterpreter', 'none')

        figure();
        H = plot(graph,'NodeLabel',nLabels,'NodeFontSize',10,'EdgeColor',eColour, ...
            'EdgeLabel', edgeLabels,'LineWidth',LWidths, ...
            'ArrowSize', 10, 'ArrowPosition', 0.65, 'Interpreter','none');
        layout(H,'layered','Direction','right')
        AX = gca;
        AX.InnerPosition = [0.25,0,0.5,1];
        text(H.XData(H.XData == 2), H.YData(H.XData == 2)+1, H.NodeLabel(H.XData == 2), ...
            'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, ...
            'Interpreter','none')
        text(H.XData(H.XData == 1)-0.05, H.YData(H.XData == 1), H.NodeLabel(H.XData == 1), ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'right', 'FontSize', 10, ...
            'Interpreter','none')
        text(H.XData(H.XData == 3)+0.05, H.YData(H.XData == 3), H.NodeLabel(H.XData == 3), ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 10, ...
            'Interpreter','none')
        H.NodeLabel = {};
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        legend([met ' utilisation network:'], 'production', 'consumption')
        axis off
    end

    if printFig == 1 && strcmp(param.NodeLabels,'rxnNames')
        set(groot,'defaultfigureposition',[250 250 900 400])
        set(groot, 'defaultTextInterpreter', 'none')

        figure();
        H = plot(graph,'NodeLabel',nLabels,'NodeFontSize',10,'EdgeColor',eColour, ...
            'EdgeLabel', edgeLabels,'LineWidth',LWidths, ...
            'ArrowSize', 10, 'ArrowPosition', 0.65, 'Interpreter','none');
        layout(H,'layered','Direction','right')
        AX = gca;
        AX.InnerPosition = [0.25,0,0.5,1];
        rxnNames1 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 1)));
        rxnNames3 = summary.rxnNames(ismember(summary.rxns, H.NodeLabel(H.XData == 3)));
        text(H.XData(H.XData == 2), H.YData(H.XData == 2)+0.5, H.NodeLabel(H.XData == 2), ...
            'VerticalAlignment','bottom', 'HorizontalAlignment', 'center', 'FontSize', 15, ...
            'Interpreter','none')
        text(H.XData(H.XData == 1)-0.05, H.YData(H.XData == 1), rxnNames1, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'right', 'FontSize', 12, ...
            'Interpreter','none')
        text(H.XData(H.XData == 3)+0.05, H.YData(H.XData == 3), rxnNames3, ...
            'VerticalAlignment','middle', 'HorizontalAlignment', 'left', 'FontSize', 12, ...
            'Interpreter','none')
        H.NodeLabel = {};
        line(NaN,NaN,'Color','#A2142F','LineStyle','-')
        line(NaN,NaN,'Color','#0072BD','LineStyle','-')
        legend([met ' utilisation network:'], 'production', 'consumption')
        axis off
    end

    graph_data.edgeLabels = edgeLabels;
    graph_data.LWidths = LWidths;
    graph_data.graph = graph;
    graph_data.eColour = eColour;
    graph_data.nLabels = nLabels;
end
end

