function [nKeq, nGC, nNone] = standardGibbsFormationEnergyStats(modelT, figures)
% Generate the stats +/- pie chart on the provinence of the metabolite standard Gibbs energies.
%
% USAGE:
%
%    [nKeq, nGC, nNone] = standardGibbsFormationEnergyStats(modelT, figures)
%
% INPUTS:
%    modelT:    thermodynamically constrained model structure with fields:
%
%                 * .S - `m x n` stoichiometric matrix
%                 * .mets - `m x 1` cell array of metabolite identifiers
%    figures:    if non-zero, generate the summary pie chart
%
% OUTPUTS:
%    nKeq:      number of metabolites with standard Gibbs energy from Keq data
%    nGC:       number of metabolites with standard Gibbs energy from group contribution
%    nNone:     number of metabolites with no standard Gibbs energy estimate
%
% .. Author: - Ronan M.T. Fleming

[nMet,nRxn]=size(modelT.S);

nKeq=eps;
nGC=eps;
nNone=eps;

noneBool=false(nMet,1);
p=1;
noneAbbr=[];
for m=1:nMet
    if strcmp(modelT.met(m).dGft0Source,'Keq')
        nKeq=nKeq+1;
    else
        if isnan(modelT.met(m).dGft0Source)
            nNone=nNone+1;
            noneBool(m,1)=1;
            abbr=modelT.mets{m};
            abbr=abbr(1:end-3);
            noneAbbr{p,1}=abbr;
            p=p+1;
        else
            nGC=nGC+1;
        end
    end
end

if figures
    figure1=figure;
    h=pie([nKeq,nGC,nNone],{{'K_{eq}',int2str(nKeq)},{'Group Contribution',int2str(nGC)},{'None',int2str(nNone)}});
    textObjs = findobj(h,'Type','text');
    set(textObjs,'FontSize',16);
    title('Provinence of reactant \Delta_{f}G^{\o} data','FontSize',16);
    saveas(figure1,'dfG0provinencePieChart','fig');

end

fprintf('%s\n',['Number of unique reactants without dGf0: ' int2str(length(unique(noneAbbr))) ]);
