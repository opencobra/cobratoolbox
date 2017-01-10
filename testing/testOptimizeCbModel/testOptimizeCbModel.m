function statusOK = testOptimizeCbModel()
% Test optimizeCbModel function
statusOK = 1;

%load data
load('iLC915.mat')

osenseStr = 'max';
allowLoops = true;

% FBA
minNorm = 0;
FBAsolution = optimizeCbModel(model,'max',minNorm,allowLoops);
if FBAsolution.stat ~=1
    warning('Failed to get a solution');
    statusOK = 0;    
else
    feasibilyError = norm(model.S * FBAsolution.x - model.b,2);
    if feasibilyError > 1e-6 
        warning('Feasibility error is high');
        statusOK = 0;
    end
end
% Minimise the Taxicab Norm
minNorm = 'one';
L1solution = optimizeCbModel(model,'max',minNorm,allowLoops);
if L1solution.stat ~=1
    warning('Failed to get a solution');
    statusOK = 0;    
else
    feasibilyError = norm(model.S * L1solution.x - model.b,2);
    if feasibilyError > 1e-6 
        warning('Feasibility error is high');
        statusOK = 0;
    end
    if abs(FBAsolution.f - L1solution.x'*model.c) > .01
        warning('Objective appears to have changed while minimizing the Taxicab norm');
        statusOK = 0;
    end
end

% Minimise the zero norm
minNorm = 'zero';
L0solution = optimizeCbModel(model,'max',minNorm,allowLoops);
if L0solution.stat ~=1
    warning('Failed to get a solution');
    statusOK = 0;    
else
    feasibilyError = norm(model.S * L0solution.x - model.b,2);
    if feasibilyError > 1e-6 
        warning('Feasibility error is high');
        statusOK = 0;
    end
    if abs(FBAsolution.f - L0solution.x'*model.c) > .01
        warning('Objective appears to have changed while minimizing the zero norm');
        statusOK = 0;
    end
end

% Minimise the Euclidean Norm of internal fluxes
minNorm = rand(size(model.S,2),1);
L2solution = optimizeCbModel(model,'max',minNorm,allowLoops);
if L2solution.stat ~=1
    warning('Failed to get a solution');
    statusOK = 0;    
else
    feasibilyError = norm(model.S * L2solution.x - model.b,2);
    if feasibilyError > 1e-6 
        warning('Feasibility error is high');
        statusOK = 0;
    end
    if abs(FBAsolution.f - L2solution.x'*model.c) > .01
        warning('Objective appears to have changed while minimizing the Euclidean norm');
        statusOK = 0;
    end
end

end