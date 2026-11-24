# Wrong-result defects ranked by scientific impact (2026-11-23)

The registry (test/known-defects.md, 821 defects) holds 303 wrong-result defects. They were scored
by source area (core FBA, solvers, model editing and checking first), by how many functions reach
them through the call graph, and by their uses in src and tutorials
(the scratch scoring is not kept). The scores were then reviewed by hand against each entry's
trigger, observed and expected result, because reach alone puts infrastructure (changeCobraSolver,
printRxnFormula) on top whatever the effect. The order below asks: does a typical user get a wrong
number, a wrong classification or a wrong model, silently, in a common workflow?

## Tier A: wrong numbers or models in common workflows, silently

1. **optimizeCbModel**: with a parameter structure as second input, the sense of the model and
   param.osenseStr (when the model has one) are replaced by 'max'; a minimisation is maximised.
   Callers in src: entropicFluxBalanceAnalysis, processFluxConstraints.
2. **verifyModel** (three defects): the simple flux-consistency check fails every consistent model;
   without metCharges every reaction is reported mass-imbalanced; the fields reported as
   problematic are the valid ones. Model quality control gives the opposite verdict.
3. **checkDuplicateRxn**: the 'rxnAbbr' method returns the first occurrence of every reaction as a
   duplicate (all reactions when none repeats); removal by name deletes them. The 'FR' method can
   report a reaction that is not a duplicate of the kept one.
4. **GPR logic** (combineChildren, NormaliseGPRs): (a AND b) OR (a OR b) becomes an empty node;
   absorbed clauses are kept. GPRparser and mapExpressionToReactions use these classes, so
   expression-to-reaction scores of transcriptomic integration can change.
5. **createComputedSpeciesData** (via assignThermoToModel): every metabolite gets the
   group-contribution data of the first entry (charge, formula, energy).
6. **addReactionGEM**: without a genes input the model's genes are replaced by an empty list
   while the rules still refer to them.
7. **updateGenes**: with two pairs of duplicated genes, different genes are merged.

## Tier B: wrong answers of query, curation and comparison functions

8. **isSameCobraModel**: logical fields are never compared, and text is compared with every
   non-word character removed. Tests that rely on it can pass for models that differ.
9. **extractSubSysModel**: a subsystem name given as text keeps almost every reaction (94 of 95
   in ecoli_core_model instead of 20).
10. **findRxnFromCompartment**: a compartment with one metabolite returns the first reaction of
    the model.
11. **isReactionInSubSystem**: reactions requested out of model order get each other's answers.
12. **setConstraintsIrrevModel**: reactions with names of one or two characters get the wrong sign.
13. **findCarbonRxns**: Cl, Ca, Co, Cu, ... are counted as carbon.
14. **removeCompartments**: reactions that become duplicates are kept.
15. **compareTwoSamplesStat**: chi-square p values are lower-tail probabilities (0 for identical
    samples).
16. **elementalMatrixToFormulae**: dMax = 0 drops every count of 1 (methane becomes H4).

## Tier C: strain design and solver variants (wrong results, narrower use)

17. **OptKnock** without constrOpt: the inner growth maximisation is lost (production 33.78 at
    zero growth).
18. **GDLS**: every design reports the values of the last knockout set.
19. **simpleOptKnock**: the wild-type minimum production equals the maximum.
20. **cycleFreeFlux** (approach 'lp', minimisation): the objective bound excludes the solution,
    so the fallback runs (with a warning).
21. **convertCobraLP2mps**: only the first column of a 'G' row is negated in the MPS file.
22. **solveCobraLPCPLEXcard** (IBM ILOG branch): minimisation runs in the wrong direction.
23. **changeCobraSolver**: a solver that fails validation with printLevel above 0 stays selected.

## The rest

The remaining wrong-result defects are in specialised areas: whole-body and microbiome pipelines,
thermodynamic reports, lrs interfaces, variable-kinetics solvers (x_error and Time), sampling
plots, moiety analysis, CellDesigner and other visualisation. They change results only within
those tools; most block nothing else.
