%test writing out a model in SBML with COBRA Toolbox, then reading it in
%with COBRApy, then writing it out in JSON with COBRApy.

modelPath = '~/work/sbgCloud/programExperimental/projects/tracerBased/results/moietyFluxomics/centralMetabolism/centralMetabolism.xml';

[success,pymodel] = writeModelinJSON(modelPath);