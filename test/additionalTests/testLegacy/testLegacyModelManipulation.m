


[modelClosed, rxnIDexists] = addReactionOri(modelClosed,'DM_atp_c_',  'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
edit addReaction
[modelClosed2, rxnIDexists] = addReaction(model, 'DM_atp_c_', 'reactionFormula', 'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
isequal(modelClosed,modelClosed2)
isequaln(modelClosed,modelClosed2)
edit /home/rfleming/work/sbgCloud/code/fork-cobratoolbox/external/base/utilities/cellstructeq
cd /home/rfleming/work/sbgCloud/code/fork-cobratoolbox/external/base/utilities/cellstructeq
[result, why] = structeq(modelClosed, modelClosed2)