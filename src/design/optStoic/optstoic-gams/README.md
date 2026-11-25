# optStoic database (copy)

Files copied without modification from https://github.com/maranasgroup/optstoic-gams
(commit d617e3a80aa6e465c88b7503053a1eeefc9eb3a5), distributed under the Apache License 2.0 (see `LICENSE`).

- `data/`: GAMS include files with the metabolites, reactions, stoichiometry, metabolite
  details (elemental composition, charge and Gibbs free energy of formation in kcal/mol)
  and reaction types used by optStoic, minFlux and minRxn.
- `info/reaction_db.xlsx`: reaction names, abbreviations, descriptions, EC numbers and
  Gibbs free energy of reaction.
- `optStoic_output.csv`, `minFlux_output.txt`: outputs of the GAMS implementation, used to
  validate the MATLAB implementation.

Reference: A. Chowdhury and C.D. Maranas, "Designing overall stoichiometric conversions and
intervening metabolic reactions", Scientific Reports 5, 16009 (2015).
