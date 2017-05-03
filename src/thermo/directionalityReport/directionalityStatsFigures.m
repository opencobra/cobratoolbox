function directionalityStatsFigures(directions,resultsBaseFileName)
%creates pie charts of directionality stats
%
%INPUT
% directions    a structue of boolean vectors with different directionality
%               assignments where some vectors contain subsets of others
%
% qualitatively assigned directions
%   directions.forwardRecon
%   directions.reverseRecon
%   directions.reversibleRecon
%
% qualitatively assigned directions using thermo in preference to
% qualitative assignments but using qualitative assignments where
% thermodynamic data is lacking
%   directions.forwardThermo
%   directions.reverseThermo
%   directions.reversibleThermo
%   directions.uncertainThermo
%
% qualtiative -> quantiative changed reaction directions
%   directions.forward2Forward
%   directions.forward2Reverse
%   directions.forward2Reversible
%   directions.forward2Uncertain
%   directions.reversible2Forward
%   directions.reversible2Reverse
%   directions.reversible2Reversible
%   directions.reversible2Uncertain
%   directions.reverse2Forward
%   directions.reverse2Reverse
%   directions.reverse2Reversible
%   directions.reverse2Uncertain
%
% subsets of forward qualtiative -> reversible quantiative change
%   directions.forward2Reversible_bydGt0
%   directions.forward2Reversible_bydGt0LHS
%   directions.forward2Reversible_bydGt0Mid
%   directions.forward2Reversible_bydGt0RHS
% 
%   directions.forward2Reversible_byConc_zero_fixed_DrG0
%   directions.forward2Reversible_byConc_negative_fixed_DrG0
%   directions.forward2Reversible_byConc_positive_fixed_DrG0
%   directions.forward2Reversible_byConc_negative_uncertain_DrG0
%   directions.forward2Reversible_byConc_positive_uncertain_DrG0

% Ronan M.T. Fleming


figure('units','normalized','outerposition',[0 0 1 1]);
data=[nnz(directions.forwardRecon) nnz(directions.reverseRecon) nnz(directions.reversibleRecon) nnz(directions.equilibriumRecon)];
data(data==0)=eps;
%h=pie(data,{{'Forward',int2str(data(1))},{'Reverse',int2str(data(2))},{'Reversible',int2str(data(3))}});
h=pie(data,{'Forward','Reverse','Reversible','Equilibrium'});
textObjs = findobj(h,'Type','text');
set(textObjs,'FontSize',16);
title('Qualitatively assigned directionality','FontSize',16);

figure('units','normalized','outerposition',[0 0 1 1]);
data=[nnz(directions.forwardThermo) nnz(directions.reverseThermo) nnz(directions.reversibleThermo) nnz(directions.equilibriumThermo) nnz(directions.uncertainThermo)];
data(data==0)=eps;
%h=pie(data,{{'Forward',int2str(data(1))},{'Reverse',int2str(data(2))},{'Reversible',int2str(data(3))}});
h=pie(data,{'Forward','Reverse','Reversible','Equilibrium','Uncertain'});
textObjs = findobj(h,'Type','text');
set(textObjs,'FontSize',16);
title({'Quantitatively assigned directionality'},'FontSize',16);

%subset of changes
figure('units','normalized','outerposition',[0 0 1 1]);
data=[nnz(directions.reversible2Forward) nnz(directions.reversible2Reverse) nnz(directions.forward2Reverse) nnz(directions.forward2Reversible)];
data(data==0)=eps;
h=pie(data,{'Reversible -> Forward',...
    'Reversible -> Reverse',...
    'Forward -> Reverse',...
    'Forward -> Reversible'});
textObjs = findobj(h,'Type','text');
set(textObjs,'FontSize',16);
title({'Qualtiative -> quantiative changed reaction directions';['(' int2str((sum(data)/length(directions.forwardThermo)*100)) ' % of all reactions)']},'FontSize',16);

%all changes
figure('units','normalized','outerposition',[0 0 1 1]);
data=[nnz(directions.reversible2Forward)...
nnz(directions.reversible2Reverse)...
nnz(directions.reversible2Reversible)...
nnz(directions.reversible2Uncertain)...
nnz(directions.forward2Reverse)...
nnz(directions.forward2Reversible)...
nnz(directions.forward2Forward)...
nnz(directions.forward2Uncertain)...
nnz(directions.reverse2Reverse)...
nnz(directions.reverse2Forward)...
nnz(directions.reverse2Reversible)...
nnz(directions.reverse2Uncertain)];
data(data==0)=eps;
h=pie(data,{'reversible -> forward'...
'reversible -> Reverse'...
'reversible -> Reversible'...
'reversible -> Uncertain'...
'forward -> Reverse'...
'forward -> Reversible'...
'forward -> Forward'...
'forward -> Uncertain'...
'reverse -> Reverse'...
'reverse -> Forward'...
'reverse -> Reversible'...
'reverse -> Uncertain'});
textObjs = findobj(h,'Type','text');
set(textObjs,'FontSize',16);
title({'Qualtiative -> quantiative reaction directions'},'FontSize',16);


data=[nnz(directions.forward2Reversible_bydGt0)...
    nnz(directions.forward2Reversible_bydGt0LHS)...
    nnz(directions.forward2Reversible_bydGt0Mid)...
    nnz(directions.forward2Reversible_bydGt0RHS)];
if any(data)
    figure1=figure('units','normalized','outerposition',[0 0 1 1]);
data(data==0)=eps;
ph=pie(gca,data,{...
    '\Delta_{r}G^{\primem}_0 = 0',...
    '0 << \Delta_{r}G^{\primem}_0 > 0',...
    '0 << \Delta_{r}G^{\primem}_0 >> 0',...
    '0 < \Delta_{r}G^{\primem}_0 >> 0'});
textObjs = findobj(ph,'Type','text');
set(textObjs,'FontSize',16);
title({'Forward -> Reversible (by \Delta_{f}G^{\primem}_0)';...
    ['(' int2str((sum(data)/length(directions.forwardThermo)*100)) ' % of all reactions)']},'FontSize',16);
saveas(figure1,[resultsBaseFileName,'_fwdReversible_byDrG0_pieChart'],'fig');
end

figure1=figure('units','normalized','outerposition',[0 0 1 1]);
data=[nnz(directions.forward2Reversible_byConc_zero_fixed_DrG0)...
    nnz(directions.forward2Reversible_byConc_negative_fixed_DrG0)...
    nnz(directions.forward2Reversible_byConc_negative_uncertain_DrG0)...
    nnz(directions.forward2Reversible_byConc_positive_uncertain_DrG0)...
    nnz(directions.forward2Reversible_byConc_positive_fixed_DrG0)];
data(data==0)=eps;
ph=pie(gca,data,{...
    '\Delta_{r}G^{\primem}_0 = 0 (exact)',...
    '\Delta_{r}G^{\primem}_0 < 0 (exact)',...
    '0 << \Delta_{r}G^{\primem}_0 > 0 (variable)',...
    '0 << \Delta_{r}G^{\primem}_0 >> 0 (variable)',...
    '0 < \Delta_{r}G^{\primem}_0 >> 0 (exact)'});
textObjs = findobj(ph,'Type','text');
set(textObjs,'FontSize',16);
title({'Forward -> Reversible (by reactant concentration)';...
    ['(' int2str((sum(data)/length(directions.forwardThermo)*100)) ' % of all reactions)']},'FontSize',16);
saveas(figure1,[resultsBaseFileName,'_fwdReversible_byconc_pieChart'],'fig');


