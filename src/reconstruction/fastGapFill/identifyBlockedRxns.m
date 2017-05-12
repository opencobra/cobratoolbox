function [consistModel, BlockedRxns] = identifyBlockedRxns(model,epsilon)
% function [consistModel, BlockedRxns] = identifyBlockedRxns(model,epsilon)
% 
% This function computes all blocked reactions using the approach described
% in "The FASTCORE algorithm for context-specific metabolic network reconstructions", Vlassis et
% al., 2013, PLoS Comp Biol.
%
% % Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
% 
% Getting the Latest Code From the Subversion Repository:
% Linux:
% svn co https://opencobra.svn.sourceforge.net/svnroot/opencobra/cobra-devel
%
% INPUT
% model         Model structure
% epsilon       Parameter(default: 1e-4; see Vlassis et al for more details)
% 
% OUTPUT
% consistModel  Flux consistent model that does not contain any blocked
%               reactions anymore
% BlockedRxns   Structure containing all blocked reactions and their reaction formula that were in
%               model
%
% Dec 2013
% Ines Thiele, http://thielelab.eu

if ~exist('epsilon','var')
    epsilon = 1e-4;
end

A = fastcc(model, epsilon);
% A contains consistent reaction indices
consistRxnsModel = model.rxns(A);
consistModel = extractSubNetwork(model,consistRxnsModel);
inconsistRxns = setdiff(model.rxns,consistRxnsModel);
BlockedRxns.allRxns = inconsistRxns;
BlockedRxns.allFormula = printRxnFormula(model,inconsistRxns,false);