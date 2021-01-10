function [reactionsToGapfill,reactionsToDelete]=runDebuggingTools(curatedFolder, numWorkers, infoFilePath, propertiesFolder, reconVersion)
% This function runs a suite of debugging functions on refined
% reconstructions produced by the semi-automatic refinement pipeline. Tests
% are performed whether or not the models can produce biomass aerobically
% and anaerobically, and whether or not unrealistically high ATP is
% produced on the Western diet.


% identify blocked biomass precursors on defined medium for the organism
[growsOnDefinedMedium,constrainedModel,~] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction);

if growsOnDefinedMedium == 0
[blockedPrecursors,enablingMetsEach,enablingMetsAll]=findBlockedPrecursorsInRxn(constrainedModel,biomassReaction,'max');
end

end