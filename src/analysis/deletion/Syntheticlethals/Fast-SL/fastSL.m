function [synthetic_lethals, synthetic_double_lethals, synthetic_triple_lethals] = fastSL(model, cutoff, order, eliList, atpm)                                  
% Identify synthetic lethal reactions (single, double and triple) via Fast-SL
%
% Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
%
% USAGE:
%
%    [synthetic_lethals, synthetic_double_lethals, synthetic_triple_lethals] = fastSL(model, cutoff, order, eliList, atpm)
%
% INPUT:
%    model:      COBRA model structure (the following fields are required):
%
%                  * .S - Stoichiometric matrix
%                  * .b - Right hand side = dx/dt
%                  * .c - Objective coefficients
%                  * .lb - Lower bounds
%                  * .ub - Upper bounds
%                  * .rxns - Reaction names
%                  * .description - model description string, used to name the output .mat file
%
% OPTIONAL INPUTS:
%    cutoff:     cutoff percentage value for lethality (default is 0.01)
%    order:      Order of SLs required (default order is 2, max value 3)
%    eliList:    List of reactions to be ignored for lethality analysis
%                (e.g. exchange reactions, ATPM)
%    atpm:       ATPM reaction id in model.rxns if other than 'ATPM'
%
% OUTPUTS:
%    synthetic_lethals:           Indices/names of single lethal reactions identified
%    synthetic_double_lethals:    Indices/names of double lethal reactions identified
%    synthetic_triple_lethals:    Indices/names of triple lethal reactions identified
%
% .. Authors: - Aditya Pratapa, Shankar Balachandran and Karthik Raman

% initCobraToolbox
if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end

if exist('order', 'var')
    if isempty(order)
        order = 2;
    else
        if (order>3)
        err = MException('ResultChk:OutOfRange', ...
        'Resulting value is outside expected range. Maximum value is 3.');
         throw(err)
        end
    end
else
    order = 2;
end

% Please change this according to your model
if exist('atpm', 'var')
    if isempty(atpm)
        atpm = 'ATPM'; % Reaction Id of ATP maintenance reaction- by default it takes 'ATPM'
    end
else
    atpm = 'ATPM';
end

if exist('eliList', 'var')
    if isempty(eliList)
        eliList = model.rxns(ismember(model.rxns,atpm)); % To eliminate ATPM.
    end
else
    eliList = model.rxns(ismember(model.rxns,atpm));
end

fname = strcat(model.description, '_Rxn_lethals.mat');

%%
global model;

switch order
    case 1
        [synthetic_lethals] = singleSL(model, cutoff, eliList, atpm);
        synthetic_double_lethals = [];
        synthetic_triple_lethals = [];
       
        fprintf('\n Saving Single Lethal Reactions List...\n');
        fprintf('Done. \n');
    case 2
        [synthetic_lethals, synthetic_double_lethals] = doubleSL(model, cutoff, eliList, atpm);
        synthetic_triple_lethals = [];
     
        fprintf('\n Saving Single and Double Lethal Reactions List...\n');
        fprintf('Done. \n');
    case 3
        [synthetic_lethals, synthetic_double_lethals, synthetic_triple_lethals] = tripleSL(model, cutoff, eliList, atpm);
      
        fprintf('\n Saving Single, Double and Triple Lethal Reactions List...\n');
        fprintf('Done. \n');
end