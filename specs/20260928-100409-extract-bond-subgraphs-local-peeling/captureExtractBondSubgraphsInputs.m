function tf = captureExtractBondSubgraphsInputs(BIG, ATG)
% Save the inputs of the extractBondSubgraphs call from a conditional breakpoint
%
% USAGE:
%
%    tf = captureExtractBondSubgraphsInputs(BIG, ATG)
%
% INPUTS:
%    BIG:    bond instance graph, as it is at the `extractBondSubgraphs` call
%    ATG:    atom transition graph, as it is at the `extractBondSubgraphs` call
%
% OUTPUT:
%    tf:     always `false`, so the conditional breakpoint never stops execution
%
% NOTE:
%    Used only by `captureLocalPeelingFixtures.m` in this feature directory, as the
%    condition of `dbstop ... if captureExtractBondSubgraphsInputs(BIG, ATG)`. The inputs
%    are saved to the MAT file named by the environment variable `CBT_EBS_CAPTURE_FILE`,
%    so they can be captured without editing any file under `src/`.
%
% .. Author: - COBRA Toolbox, feature 20260928-100409-extract-bond-subgraphs-local-peeling

captureFile = getenv('CBT_EBS_CAPTURE_FILE');
if isempty(captureFile)
    error('captureExtractBondSubgraphsInputs:noCaptureFile', ...
        'Environment variable CBT_EBS_CAPTURE_FILE must name the MAT file to write.');
end
save(captureFile, 'BIG', 'ATG', '-v7.3');
tf = false;
end
