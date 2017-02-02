% The COBRAToolbox: testfindBlockedReaction.m
%
% Purpose:
%     - testfindBlockedReaction tests the findBlockedReaction
%     function and its different methods
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017


% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

cd([CBTDIR '/test/verifiedTests/testfindBlockedReaction'])

load ecoli_core_model.mat;

ecoli_blckd_rxn = {'EX_fru(e)','EX_fum(e)','EX_gln_L(e)','EX_mal_L(e)',...
    'FRUpts2','FUMt2_2','GLNabc','MALt2_2'};

%Using FVA
blockedReactionsFVA = findBlockedReaction(modelEcore);
assert(isequal(ecoli_blckd_rxn,blockedReactionsFVA))
%Using 2-norm min
blockedReactions = findBlockedReaction(modelEcore,'L2');
assert(isequal(ecoli_blckd_rxn,blockedReactions))

% change the directory
cd(CBTDIR)