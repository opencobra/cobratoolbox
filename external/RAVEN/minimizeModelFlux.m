function [ MinimizedFlux modelIrrev]= minimizeModelFlux(model)
% This function finds the minimum flux through the network and returns the
% minimized flux and an irreversible model
    % Convert the model to amodel with only irreversible reactions
    modelIrrev = convertToIrreversible(model);

    % Add a pseudo-metabolite to measure flux through network
    modelIrrev.S(end+1,:) = ones(size(modelIrrev.S(1,:)));
    modelIrrev.b(end+1) = 0;
    modelIrrev.mets{end+1} = 'fluxMeasure';

    % Add a pseudo reaction that measures the flux through the network
    modelIrrev = addReaction(modelIrrev,'netFlux',{'fluxMeasure'},[-1],false,0,inf,0,'','');

    % Set the flux measuring demand as the objective
    modelIrrev.c = zeros(length(modelIrrev.rxns),1);
    modelIrrev = changeObjective(modelIrrev, 'netFlux');

    % Minimize the flux measuring demand (netFlux)
    MinimizedFlux = optimizeCbModel(modelIrrev,'min');
end