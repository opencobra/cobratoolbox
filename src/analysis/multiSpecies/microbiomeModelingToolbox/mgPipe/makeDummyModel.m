function dummy = makeDummyModel(numMets, numRxns)
% Makes an empty model with numMets rows for metabolites and numRxns columns
% for reactions. Includes all fields that are necessary to join models.
%
% USAGE:
%
%   dummy = makeDummyModel(numMets, numRxns)
%
% INPUTS:
%   numMets:       Number of metabolites
%   numRxns:       Number of reactions
%
% OUTPUT:
%   dummy:         Empty COBRA model structure
%
% .. Authors: SM June 2016

dummy.mets = cell(numMets, 1);
dummy.rxns = cell(numRxns, 1);
dummy.c = zeros(numRxns, 1);
dummy.S = zeros(numMets, numRxns);
dummy.lb = zeros(numRxns, 1);
dummy.ub = zeros(numRxns, 1);
dummy.b = zeros(numMets, 1);
dummy.metNames = cell(numMets, 1);
dummy.metFormulas = cell(numMets, 1);
dummy.rxnNames = cell(numRxns, 1);
dummy.subSystems = cell(numRxns, 1);
dummy.genes = {};
dummy.rxnGeneMat = sparse(numRxns, size(dummy.genes, 1));
dummy.rules = cell(numRxns, 1);
dummy.grRules = cell(numRxns, 1);
dummy.comments = cell(numRxns, 1);
dummy.citations = cell(numRxns, 1);
dummy.confidenceScores = cell(numRxns, 1);
dummy.ecNumbers = cell(numRxns, 1);
dummy.rxnKeggID = cell(numRxns, 1);
dummy.metCHEBIID = cell(numMets, 1);
dummy.metCharge = zeros(numMets, 1);
dummy.metFormulas = cell(numMets, 1);
dummy.metHMDB = cell(numMets, 1);
dummy.metInchiString = cell(numMets, 1);
dummy.metKeggID = cell(numMets, 1);
dummy.metSmile = cell(numMets, 1);
dummy.metPubChemID = cell(numMets, 1);
dummy.description.organism = {}; dummy.description.author = {}; dummy.description.name = {};
dummy.description.geneindex = {}; dummy.description.genedate = {}; dummy.description.genesource = {}; dummy.description.notes = {};
dummy.disabled = {};
