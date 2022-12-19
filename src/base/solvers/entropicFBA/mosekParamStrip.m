function solverParams = mosekParamStrip(solverParams)
% Remove outer function specific parameters to avoid crashing solver interfaces
% Default EP parameters are removed within solveCobraEP, so are not removed here
if isfield(solverParams,'internalNetFluxBounds')
    solverParams = rmfield(solverParams,'internalNetFluxBounds');
end
if isfield(solverParams,'maxUnidirectionalFlux')
    solverParams = rmfield(solverParams,'maxUnidirectionalFlux');
end
if isfield(solverParams,'minUnidirectionalFlux')
    solverParams = rmfield(solverParams,'minUnidirectionalFlux');
end
if isfield(solverParams,'maxConc')
    solverParams = rmfield(solverParams,'maxConc');
end
if isfield(solverParams,'externalNetFluxBounds')
    solverParams = rmfield(solverParams,'externalNetFluxBounds');
end
if isfield(solverParams,'printLevel')
    solverParams.printLevel = solverParams.printLevel - 1;
end
if isfield(solverParams,'massSpectralResolution')
     solverParams = rmfield(solverParams,'massSpectralResolution');
end
if isfield(solverParams,'labelledMoietiesOnly')
     solverParams = rmfield(solverParams,'labelledMoietiesOnly');
end
if isfield(solverParams,'measuredIsotopologuesOnly')
     solverParams = rmfield(solverParams,'measuredIsotopologuesOnly');
end
if isfield(solverParams,'approach')
     solverParams = rmfield(solverParams,'approach');
end
if isfield(solverParams,'closeIons')
     solverParams = rmfield(solverParams,'closeIons');
end            
if isfield(solverParams,'diaryFilename')
     solverParams = rmfield(solverParams,'diaryFilename');
end      
if isfield(solverParams,'finalFluxConsistency')
     solverParams = rmfield(solverParams,'finalFluxConsistency');
end
if isfield(solverParams,'tissueSpecificSolver')
     solverParams = rmfield(solverParams,'tissueSpecificSolver');
end
end

