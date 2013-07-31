function directionalityStatFigures(directions,figures)
%creates pie charts of directionality stats
%
%INPUT
% directions    a structue of boolean vectors with different directionality 
%               assignments where some vectors contain subsets of others
%
% qualitatively assigned directions 
%   directions.fwdReconBool
%   directions.revReconBool
%   directions.reversibleReconBool
%
% qualitatively assigned directions using thermo in preference to
% qualitative assignments but using qualitative assignments where
% thermodynamic data is lacking
%   directions.fwdReconThermoBool
%   directions.revReconThermoBool
%   directions.reversibleReconThermoBool
%
% reactions that are qualitatively assigned by thermodynamics
% directions.fwdThermoOnlyBool
% directions.revThermoOnlyBool
% directions.reversibleThermoOnlyBool
%
% qualtiative -> quantiative changed reaction directions 
% directions.ChangeReversibleFwd
% directions.ChangeReversibleRev
% directions.ChangeForwardReverse
% directions.ChangeForwardReversible
%
% subsets of forward qualtiative -> reversible quantiative change
%   directions.ChangeForwardReversibleBool_dGfGC
%   directions.ChangeForwardReversibleBool_dGfGC_byConcLHS
%   directions.ChangeForwardReversibleBool_dGfGC_byConcRHS
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid
%   directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS
%   directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS
%   directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS
%
%   directions.cumNormProbCutoff
%   directions.ChangeForwardForwardBool_dGfGC
%
% Ronan M.T. Fleming

if figures
    %     qualitatively assigned directions
    %   directions.fwdReconBool
    %   directions.revReconBool
    %   directions.reversibleReconBool
    figure;
    data=[nnz(directions.fwdReconBool) nnz(directions.revReconBool) nnz(directions.reversibleReconBool)];
    data(data==0)=eps;
    h=pie(data,{{'Forward',int2str(data(1))},{'Reverse',int2str(data(2))},{'Reversible',int2str(data(3))}});
    textObjs = findobj(h,'Type','text');
    set(textObjs,'FontSize',16);
    title('Qualitatively assigned directionality','FontSize',16);
    
    % qualitatively assigned directions using thermo in preference to
    % qualitative assignments but using qualitative assignments where
    % thermodynamic data is lacking
    %   directions.fwdReconThermoBool
    %   directions.revReconThermoBool
    %   directions.reversibleReconThermoBool
    figure;
    data=[nnz(directions.fwdReconThermoBool) nnz(directions.revReconThermoBool) nnz(directions.reversibleReconThermoBool)];
    data(data==0)=eps;
    h=pie(data,{{'Forward',int2str(data(1))},{'Reverse',int2str(data(2))},{'Reversible',int2str(data(3))}});
    textObjs = findobj(h,'Type','text');
    set(textObjs,'FontSize',16);
    title({'Quantitatively assigned in preference to';'qualitatively assigned directionality'},'FontSize',16);
    
    % reactions that are qualitatively assigned by thermodynamics
    % directions.fwdThermoOnlyBool
    % directions.revThermoOnlyBool
    % directions.reversibleThermoOnlyBool
    figure;
    data=[nnz(directions.fwdThermoOnlyBool) nnz(directions.revThermoOnlyBool) nnz(directions.reversibleThermoOnlyBool)];
    data(data==0)=eps;
    h=pie(data,{{'Forward',int2str(data(1))},{'Reverse',int2str(data(2))},{'Reversible',int2str(data(3))}});
    textObjs = findobj(h,'Type','text');
    set(textObjs,'FontSize',16);
    title({'Exclusively quantitatively assigned directionality';['(' int2str((sum(data)/length(directions.fwdThermoOnlyBool)*100)) ' % of all reactions)']},'FontSize',16);
    
    % qualtiative -> quantiative changed reaction directions
    % directions.ChangeReversibleFwd
    % directions.ChangeReversibleRev
    % directions.ChangeForwardReverse
    % directions.ChangeForwardReversible
    figure;
    data=[nnz(directions.ChangeReversibleFwd) nnz(directions.ChangeReversibleRev) nnz(directions.ChangeForwardReverse) nnz(directions.ChangeForwardReversible)];
    data(data==0)=eps;
    h=pie(data,{{'Reversible -> Forward',int2str(data(1))},...
        {'Reversible -> Reverse',int2str(data(2))},...
        {'Forward -> Reverse',int2str(data(3))},...
        {'Forward -> Reversible',int2str(data(4))}});
    textObjs = findobj(h,'Type','text');
    set(textObjs,'FontSize',16);
    title({'Qualtiative -> quantiative changed reaction directions';['(' int2str((sum(data)/length(directions.fwdThermoOnlyBool)*100)) ' % of all reactions)']},'FontSize',16);
    
    
    % subsets of forward qualtiative -> reversible quantiative change
    %   directions.ChangeForwardReversibleBool_dGfGC
    %   directions.ChangeForwardReversibleBool_dGfGC_byConcLHS
    %   directions.ChangeForwardReversibleBool_dGfGC_byConcRHS
    %   directions.ChangeForwardReversibleBool_dGfGC_bydGt0
    %   directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS
    %   directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid
    %   directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS
    %   directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS
    %   directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS
    figure1=figure;
    data=[nnz(directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS)...
    nnz(directions.ChangeForwardReversibleBool_dGfGC_byConcLHS)...
    nnz(directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS)...
    nnz(directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid)...
    nnz(directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS)...
    nnz(directions.ChangeForwardReversibleBool_dGfGC_byConcRHS)...
    nnz(directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS)];
    data(data==0)=eps;
    ph=pie(gca,data,{{'\Delta_{r}G^{\primem} < 0',int2str(data(1))},...
    {'\Delta_{r}G^{\primem}_{est} < 0',int2str(data(2))},...
    {'0 << \Delta_{r}G^{\primem}_{est} > 0',int2str(data(3))},...
    {'0 << \Delta_{r}G^{\primem}_{est} >> 0',int2str(data(4))},...
    {'0 < \Delta_{r}G^{\primem}_{est} >> 0',int2str(data(5))},...
    {'\Delta_{r}G^{\primem}_{est} > 0',int2str(data(6))},...
    {'\Delta_{r}G^{\primem} > 0',int2str(data(7))}});
    textObjs = findobj(ph,'Type','text');
    set(textObjs,'FontSize',16);
    title({'Forward -> Reversible (\Delta_{f}G^{\primem} from K_{eq} and Group contribution)';...
        ['(' int2str((sum(data)/length(directions.fwdThermoOnlyBool)*100)) ' % of all reactions)']},'FontSize',16);
    saveas(figure1,'iAF1260_GCKeq_fwdReversible_pieChart','fig');
    
    %   directions.cumNormProbCutoff
    %   directions.ChangeForwardForwardBool_dGfGC
 
    
end
