function testOptimizeCbModelNLP( input_args )
%TESTOPTIMIZECBMODELNLP tests the optimizeCbModelNLP function, and some of
%its parameters.

toymodel = createToyModel(0,0,0) % create a toy model 
toymodel.ub(1) = -1; %force uptake, otherwise the default Objective will try to minimize all fluxes...

%optimize
sol = optimizeCbModelNLP(toymodel,'nOpt',10);
%Always have some tolerance when asserting things.
tolerance = 1e-6;

%The optimal sol has the minimal uptake and a maximal flux distribution.
optsol = [-1;0.5;0.5;0.5;0.5];

assert(abs(sum(sol.x-optsol)) < tolerance)

%Test a different objective function
load('ecoli_core_model','model')
model.ub(28) = 0;
%We want to maximize the glucose flux...
objArg = {ismember(model.rxns,model.rxns(28))};
model.c(:) = 0;
sol2 = optimizeCbModelNLP(model,'objFunction','SimpleQPObjective','objArgs',objArg,'nOpt',5);
assert(abs(sol2.f-100) < tolerance);

end

