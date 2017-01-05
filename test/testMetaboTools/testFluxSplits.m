% Toy model with single internal loop
model.mets = {'A' 'B' 'C'}';
model.rxns = {'R1' 'R2' 'R3' 'U' 'S'}';
model.S = [-1  0 -1 -1  0;
    1 -1  0  0  0;
    0  1  1  0 -1];
model.b = [0 0 0]';
model.lb = [-1000 -1000 -1000 -10  0]';
model.ub = [ 1000  1000  1000   0 10]';
model.c = [0 0 0 0 1]';

% Inputs
obj = 'S';
met2test = {'C'};
samples = {'model'};
ResultsAllCellLines.model.modelPruned = model;

% Run tests
tol = 1e-6;
v_ref = [10/3    10/3    20/3  -10   10]'; % reference flux distribution
s1 = changeCobraSolver('gurobi6','lp');
s2 = changeCobraSolver('gurobi6','qp');

if s1 ~= 1
    error('Error setting LP solver.\n');
elseif s2 ~= 1
    error('Error setting QP solver.\n');
else
    % Test production
    dir = 1;
    p.rxn = {'R3'}; % max contributing reaction
    p.flux = [20/3   10   200/3]; % contributing fluxes
    [BMall, ResultsAllCellLines, metRsall, maximum_contributing_rxn, maximum_contributing_flux, ATPyield] = predictFluxSplits(model, obj, met2test, samples, ResultsAllCellLines, dir);
    
    assert(norm(BMall - v_ref) < tol)
    assert(strcmp(maximum_contributing_rxn,p.rxn))
    assert(norm(maximum_contributing_flux - p.flux) < tol)
    
    % Test consumption
    dir = 0;
    c.rxn = {'S'}; % max contributing reaction
    c.flux = [10   10   100]; % contributing fluxes
    [BMall, ResultsAllCellLines, metRsall, maximum_contributing_rxn, maximum_contributing_flux, ATPyield] = predictFluxSplits(model, obj, met2test, samples, ResultsAllCellLines, dir);
    
    assert(norm(BMall - v_ref) < tol)
    assert(strcmp(maximum_contributing_rxn,c.rxn))
    assert(norm(maximum_contributing_flux - c.flux) < tol)
end
