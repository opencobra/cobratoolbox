function tf = captureStageNineInputs(BIG, ATG)
% Save the stage-09 inputs of identifyConservedReactingMoieties from a conditional breakpoint
%
% USAGE:
%
%    tf = captureStageNineInputs(BIG, ATG)
%
% INPUTS:
%    BIG:    bond instance graph, as it is at the `extractBondSubgraphs` call
%    ATG:    atom transition graph, as it is at the `extractBondSubgraphs` call
%
% OUTPUT:
%    tf:     always `false`, so the conditional breakpoint never stops execution
%
% NOTE:
%    Used only by `captureBondSubgraphReferences.m` in this feature directory, as the
%    condition of `dbstop ... if captureStageNineInputs(BIG, ATG)`. The inputs are saved to
%    the MAT file named by the environment variable `CBT_RMO_CAPTURE_FILE`, so the
%    reference can be captured without editing any file under `src/`.

captureFile = getenv('CBT_RMO_CAPTURE_FILE');
if isempty(captureFile)
    error('captureStageNineInputs:noCaptureFile', ...
        'Environment variable CBT_RMO_CAPTURE_FILE must name the MAT file to write.');
end
save(captureFile, 'BIG', 'ATG');
tf = false;
end
