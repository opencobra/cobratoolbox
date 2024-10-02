function optProblem = buildLPproblemFromModel(model, verify)
warning('Function buildLPproblemFromModel depreciated, using buildOptProblemFromModel instead.')
optProblem = buildOptProblemFromModel(model, verify);