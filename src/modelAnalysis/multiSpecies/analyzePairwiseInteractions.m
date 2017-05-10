function [iAFirstOrg, iASecondOrg, iATotal] = analyzePairwiseInteractions(pairedGrowthOrg1, pairedGrowthOrg2, singleGrowthOrg1, singleGrowthOrg2, sigD)
% This function evaluates the outcome of pairwise growth of two organisms
% compared with the two organisms separately. There are six possible
% outcomes of theinteraction, and nine possible outcomes from the
% perspective of each organism. 
%
% USAGE:
%
%    [iAFirstOrg, iASecondOrg, iATotal] = analyzePairwiseInteractions(pairedGrowthOrg1, pairedGrowthOrg2, singleGrowthOrg1, singleGrowthOrg2, sigD)
%
%
%
% INPUTS:
%    pairedGrowthOrg1:   first organism's growth rate in co-growth
%    pairedGrowthOrg2:   second organism's growth rate in co-growth
%    singleGrowthOrg1:   first organism's growth rate when grown separately
%    singleGrowthOrg2:   second organism's growth rate when grown separately
%
% OPTIONAL INPUT:
%    sigD:               the difference between co-growth and single growth that is considered significant (10% =0.1 by default)
% 
% OUTPUTS:
%    iAFirstOrg:  the consequence of the interaction of the first organism
%    iASecondOrg: the consequence of the interaction of the second organism
%    iATotal:     the overall type of interaction between the two organisms
%                 (six possible interactions in total)
%
% .. Author: - Almut Heinken 16.03.2017
%
% Below is a description of all possible consequences for the two joined
% organisms. Please note that the outcomes depend on the two genome-scale
% reconstructions joined and are highly dependent on the applied
% constraints.
% 
% * Competition: both organisms grow slower in co-growth than separately
%   (same outcome for both).
%
% * Parasitism: one organism grows faster in co-growth than separately, while
%   the other grows slower in co-growth than separately. Outcome for
%   faster-growing organism: ParasitismTaker, for slower-growing organism:
%   ParasitismGiver
%
% * Amensalism: one organism's growth is unaffected by co-growth,  while
%   the other grows slower in co-growth than separately. Outcome for
%   unaffected organism: AmensalismUnaff, for slower-growing organism:
%   AmensalismNegAff
%
% * Neutralism: both organisms' growths are unaffected by co-growth (same
%   outcome for both)
%
% * Commensalism: one organism's growth is unaffected by co-growth,  while
%   the other grows fatser in co-growth than separately. Outcome for
%   unaffected organism: CommensalismGiver, for slower-growing organism:
%   CommensalismTaker
%
% * Mutualism: both organisms growth faster in co-growth than separately
%   (same outcome for both)
% 
% Please cite *Magnusdottir, Heinken et al., Nat Biotechnol. 2017
% 35(1):81-89*
% if you use this script for your own analysis.
%
if nargin < 4
    error('Four growth rates are required as input!')
end
if nargin < 5
    % use default significant difference
    sigD = 0.1;
end

if abs(1 - (pairedGrowthOrg1 / singleGrowthOrg1)) < sigD
    % first microbe unaffected - all possible cases resulting froms
    % second microbe's growth
    if abs(1 - (pairedGrowthOrg2 / singleGrowthOrg2)) < sigD
        % second microbe unaffected
        iAFirstOrg = 'Neutralism';
        iASecondOrg = 'Neutralism';
        iATotal = 'Neutralism';
    elseif abs((pairedGrowthOrg2 / singleGrowthOrg2)) > 1 + sigD
        % second microbe grows better
        iAFirstOrg = 'CommensalismGiver';
        iASecondOrg = 'CommensalismTaker';
        iATotal = 'Commensalism';
    elseif abs((singleGrowthOrg2 / pairedGrowthOrg2)) > 1 + sigD
        % second microbe grows slower
        iAFirstOrg = 'AmensalismUnaff';
        iASecondOrg = 'AmensalismNegAff';
        iATotal = 'Amensalism';
    else
        % if no case fits - needs inspection!
        iAFirstOrg = 'No_Result';
        iASecondOrg = 'No_Result';
        iATotal = 'No_Result';
    end
elseif abs((pairedGrowthOrg1 / singleGrowthOrg1)) > 1 + sigD
    % first microbe grows better - all possible cases resulting froms
    % second microbe's growth
    if abs(1 - (pairedGrowthOrg2 / singleGrowthOrg2)) < sigD
        % second microbe unaffected
        iAFirstOrg = 'CommensalismTaker';
        iASecondOrg = 'CommensalismGiver';
        iATotal = 'Commensalism';
    elseif abs((pairedGrowthOrg2 / singleGrowthOrg2)) > 1 + sigD
        % second microbe grows better
        iAFirstOrg = 'Mutualism';
        iASecondOrg = 'Mutualism';
        iATotal = 'Mutualism';
    elseif abs((singleGrowthOrg2 / pairedGrowthOrg2)) > 1 + sigD
        % second microbe grows slower
        iAFirstOrg = 'ParasitismTaker';
        iASecondOrg = 'ParasitismGiver';
        iATotal = 'Parasitism';
    else
        % if no case fits - needs inspection!
        iAFirstOrg = 'No_Result';
        iASecondOrg = 'No_Result';
        iATotal = 'No_Result';
    end
elseif abs((singleGrowthOrg1 / pairedGrowthOrg1)) > 1 + sigD
    % first microbe grows slower - all possible cases resulting froms
    % second microbe's growth
    if abs(1 - (pairedGrowthOrg2 / singleGrowthOrg2)) < sigD
        % second microbe unaffected
        iAFirstOrg = 'AmensalismNegAff';
        iASecondOrg = 'AmensalismUnaff';
        iATotal = 'Amensalism';
    elseif abs((pairedGrowthOrg2 / singleGrowthOrg2)) > 1 + sigD
        % second microbe grows better
        iAFirstOrg = 'ParasitismGiver';
        iASecondOrg = 'ParasitismTaker';
        iATotal = 'Parasitism';
    elseif abs((singleGrowthOrg2 / pairedGrowthOrg2)) > 1 + sigD
        % second microbe grows slower
        iAFirstOrg = 'Competition';
        iASecondOrg = 'Competition';
        iATotal = 'Competition';
    else
        % if no case fits - needs inspection!
        iAFirstOrg = 'No_Result';
        iASecondOrg = 'No_Result';
        iATotal = 'No_Result';
    end
else
    % if no case fits - needs inspection!
    iAFirstOrg = 'No_Result';
    iASecondOrg = 'No_Result';
    iATotal = 'No_Result';
end
end
