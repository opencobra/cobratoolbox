function directions=directionalityStats(model,cumNormProbCutoff,thorStandard,printToFile)
% Build Boolean vectors with reaction directionality statistics
%
%INPUT
% model.rxn(n).directionalityThermo
% cumNormProbCutoff     {0.2} cutoff for probablity that reaction is
%                       reversible within this cutoff of 0.5
% model.NaNdGf0MetBool      metabolites without Gibbs Energy
% model.NaNdG0RxnBool       reactions with NaN Gibbs Energy
% cumNormProbCutoff     {0.1} positive real number between 0 and 0.5 that
%                       specifies to tolerance when there is uncertainty in group
%                       contribution estimates.
% thorStandard          {0,(1)} use new standard reactant concentration
%                       at geometric mean between upper and lower concentration
%                       bounds
% printToFile           {(0),1}  print out reactions with changed
%                       directions to files
%
%OUTPUT
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
%   directions.fwdThermoOnlyBool
%   directions.revThermoOnlyBool
%   directions.reversibleThermoOnlyBool
%
% qualtiative -> quantiative changed reaction directions 
%   directions.ChangeReversibleFwd
%   directions.ChangeReversibleRev
%   directions.ChangeForwardReverse
%   directions.ChangeForwardReversible
%
% subsets of forward qualtiative -> reversible quantiative change
%   directions.ChangeForwardReversible_dGfKeq
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

if ~exist('cumNormProbCutoff','var')
    directions.cumNormProbCutoff=0.2;
else
    directions.cumNormProbCutoff=cumNormProbCutoff;
end
%must be symmetric about 50:50 to be logically consistent
cumNormProbFwdUpper=0.5+directions.cumNormProbCutoff;
cumNormProbFwdLower=0.5-directions.cumNormProbCutoff;

if ~exist('thorStandard','var')
    thorStandard=1;
end

[nMet,nRxn]=size(model.S);

%%%%%%REACTION DIRECTIONS%%%%%%%%%%%
%Reconstruction directions
%only consider internal reactions
fwdReconBool=model.lb>=0 & model.ub>0 & model.SIntRxnBool;
revReconBool=model.lb<0 & model.ub<=0 & model.SIntRxnBool;
reversibleReconBool=model.lb<0 & model.ub>0 & model.SIntRxnBool;
if 0 %from Jan 30th 2011 ignore fixed reactios
if any(model.lb==0 & model.ub==0)
    error('This analysis assumes no reactions are fixed');
end
end
%sanity check
if nnz(model.SIntRxnBool)~=(nnz(fwdReconBool)+nnz(revReconBool)+nnz(reversibleReconBool))+nnz(model.lb==0 & model.ub==0)
    error('Some reactions not set directions??');
end

%Thermo and recon where thermo not available
%only consider internal reactions
fwdReconThermoBool=model.lb_reconThermo>=0 & model.ub_reconThermo>0 & model.SIntRxnBool;
revReconThermoBool=model.lb_reconThermo<0 & model.ub_reconThermo<=0 & model.SIntRxnBool;
reversibleReconThermoBool=model.lb_reconThermo<0 & model.ub_reconThermo>0 & model.SIntRxnBool;
if 0 %from Jan 30th 2011 ignore fixed reactions
if any(model.lb_reconThermo==0 & model.ub_reconThermo==0)
    error('This analysis assumes no reactions are fixed');
end
end

%thermo only
[nMet,nRxn]=size(model.S);
fwdThermoOnlyBool=false(nRxn,1);
revThermoOnlyBool=false(nRxn,1);
reversibleThermoOnlyBool=false(nRxn,1);
for n=1:nRxn
    %only consider internal reactions
    if model.SIntRxnBool(n)
        if strcmp(model.rxn(n).directionalityThermo,'forward')
            fwdThermoOnlyBool(n)=1;
        end
        if strcmp(model.rxn(n).directionalityThermo,'reverse')
            revThermoOnlyBool(n)=1;
        end
        if strcmp(model.rxn(n).directionalityThermo,'reversible')
            reversibleThermoOnlyBool(n)=1;
        end
    end
end


%%%%%%CHANGES IN REACTION DIRECTIONS%%%%%%%%%%%
%thermodynamic constraints overly tightened
tightened=false(nRxn,1);
%reversible now forward
reversibleFwd=false(nRxn,1);
%reversible now reverse
reversibleRev=false(nRxn,1);
%forward now reverse
forwardReverse=false(nRxn,1);
%forward now reversible
forwardReversible=false(nRxn,1);
%forward now forward
forwardForward=false(nRxn,1);
for n=1:nRxn
    %ignore exchange reactions
    if model.SIntRxnBool(n)
        %dont include reactions that cannot be assigned reaction directionality
        %due to missing data for certain metabolites involved in that reaction
        if ~isnan(model.rxn(n).directionalityThermo)
            if ~strcmp(model.rxn(n).directionality,model.rxn(n).directionalityThermo)
                if strcmp(model.rxn(n).directionality,'reversible')
                    tightened(n)=1;
                    if strcmp(model.rxn(n).directionalityThermo,'forward')
                        reversibleFwd(n)=1;
                    end
                    if strcmp(model.rxn(n).directionalityThermo,'reverse')
                        reversibleRev(n)=1;
                    end
                end
                if strcmp(model.rxn(n).directionality,'forward')
                    if strcmp(model.rxn(n).directionalityThermo,'reverse')
                        forwardReverse(n)=1;
                    end
                    if strcmp(model.rxn(n).directionalityThermo,'reversible')
                        forwardReversible(n)=1;
                    end
                end
            end
            if strcmp(model.rxn(n).directionality,'forward') && strcmp(model.rxn(n).directionalityThermo,'forward')
                forwardForward(n)=1;
            end
        end
    end
end

if printToFile
    fid=fopen('directionalityStats.txt','w');
    fprintf(fid,'%s\n','Qualitative internal reaction directionality:');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(fwdReconBool)+nnz(revReconBool)+nnz(reversibleReconBool)),' internal reconstruction reactions assigned direction.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(fwdReconBool)), ' forward reconstruction assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(revReconBool)), ' reverse reconstruction assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(reversibleReconBool)), ' reversible reconstruction assignment.');
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\n','Quantitative in preference to qualitative, plus  remainder of qualitative, internal reaction directionality:');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(fwdReconThermoBool)+nnz(revReconThermoBool)+nnz(reversibleReconThermoBool)), ' internal reactions thermodynamic over reconstruction assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(fwdReconThermoBool)), ' forward thermodynamic over reconstruction assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(revReconThermoBool)), ' reverse thermodynamic over reconstruction assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(reversibleReconThermoBool)), ' reversible thermodynamic over reconstruction assignment.');
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\n','Quantitative in preference to qualitative internal reaction directionality:');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(fwdThermoOnlyBool)+nnz(revThermoOnlyBool)+nnz(reversibleThermoOnlyBool)),  ' internal thermodynamic assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(fwdThermoOnlyBool)), ' forward thermodynamic only assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(revThermoOnlyBool)), ' reverse thermodynamic only assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(reversibleThermoOnlyBool)), ' reversible thermodynamic only assignment.');
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\n','Changes in internal reaction directionality, Qualitiative vs Quantitative:');
    fprintf(fid,'%10i\t%s\n',nnz(reversibleFwd),' Reversible -> Forward');
    fprintf(fid,'%10i\t%s\n',nnz(reversibleRev),' Reversible -> Reverse');
    fprintf(fid,'%10i\t%s\n',nnz(forwardReverse),' Forward -> Reverse');
    fprintf(fid,'%10i\t%s\n',nnz(forwardReversible),' Forward -> Reversible');
    fprintf(fid,'\n');
else
    fprintf('%s\n','Qualitative internal reaction directionality:');
    fprintf('%10s\t%s\n',int2str(nnz(fwdReconBool)+nnz(revReconBool)+nnz(reversibleReconBool)),' internal reconstruction reactions assigned direction.');
    fprintf('%10s\t%s\n',int2str(nnz(fwdReconBool)), ' forward reconstruction assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(revReconBool)), ' reverse reconstruction assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(reversibleReconBool)), ' reversible reconstruction assignment.');
    fprintf('\n');
    
    fprintf('%s\n','Quantitative in preference to qualitative, plus  remainder of qualitative, internal reaction directionality:');
    fprintf('%10s\t%s\n',int2str(nnz(fwdReconThermoBool)+nnz(revReconThermoBool)+nnz(reversibleReconThermoBool)), ' internal reactions thermodynamic over reconstruction assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(fwdReconThermoBool)), ' forward thermodynamic over reconstruction assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(revReconThermoBool)), ' reverse thermodynamic over reconstruction assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(reversibleReconThermoBool)), ' reversible thermodynamic over reconstruction assignment.');
    fprintf('\n');
    
    fprintf('%s\n','Quantitative in preference to qualitative internal reaction directionality:');
    fprintf('%10s\t%s\n',int2str(nnz(fwdThermoOnlyBool)+nnz(revThermoOnlyBool)+nnz(reversibleThermoOnlyBool)),  ' internal thermodynamic assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(fwdThermoOnlyBool)), ' forward thermodynamic only assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(revThermoOnlyBool)), ' reverse thermodynamic only assignment.');
    fprintf('%10s\t%s\n',int2str(nnz(reversibleThermoOnlyBool)), ' reversible thermodynamic only assignment.');
    fprintf('\n');
    
    fprintf('%s\n','Changes in internal reaction directionality, Qualitiative vs Quantitative:');
    fprintf('%10i\t%s\n',nnz(reversibleFwd),' Reversible -> Forward');
    fprintf('%10i\t%s\n',nnz(reversibleRev),' Reversible -> Reverse');
    fprintf('%10i\t%s\n',nnz(forwardReverse),' Forward -> Reverse');
    fprintf('%10i\t%s\n',nnz(forwardReversible),' Forward -> Reversible');
    fprintf('\n');
end

if printToFile
    fprintf(fid,'%s\n','Breakdown of relaxation of internal reaction directionality, Qualitiative vs Quantitative:');
else
    fprintf('%s\n','Breakdown of relaxation of internal reaction directionality, Qualitiative vs Quantitative:');
end
%finds the qualitatively forward reactions that are now reversible
%where the reaction exclusively involves metabolites with
%dGf0 back calculated from keq
dGft0SourceKeqBool=false(nMet,1);
dGft0SourceGCBool=false(nMet,1);
for m=1:nMet
    if strcmp(model.met(m).dGft0Source,'Keq')
        dGft0SourceKeqBool(m,1)=1;
    end
    %metabolites with prediction from group contribution data
    if strcmp(model.met(m).dGft0Source,'GC') 
        dGft0SourceGCBool(m,1)=1;
    end
end
%fwd reversible
forwardReversibleKeq=false(nRxn,1);
forwardReversibleKeqGC=false(nRxn,1);
forwardReversibleGC=false(nRxn,1);
%fwd fwd
forwardForwardKeq=false(nRxn,1);
forwardForwardKeqGC=false(nRxn,1);
forwardForwardGC=false(nRxn,1);
for n=1:nRxn
    if forwardReversible(n)
        ind=find(model.S(:,n));
        %finds the reactions with changed direction, exclusively involving
        %metabolites with dGf0 back calculated from keq
        if sum(dGft0SourceKeqBool(ind))==length(ind)
            forwardReversibleKeq(n)=1;
        end
        %finds the reactions with changed direction, involving bothe
        %metabolites with dGf0 back calculated from keq and estimated using
        %the group contribution method
        if any(dGft0SourceKeqBool(ind)) && any(dGft0SourceGCBool(ind))
            forwardReversibleKeqGC(n)=1;
        end
        %%qualitatively forward but GC quantitatively reversible & GC estimates for all reactants
        if sum(dGft0SourceGCBool(ind))==length(ind)
            forwardReversibleGC(n)=1;
        end
    end
    
    %todo - find the distribution of uncertainty associated with reactions that are
    %correctly predicted by group contribution, versus not both forward
    if forwardForward(n)
        %change here - doublecheck 18th feb
        ind=find(model.S(:,n));
        %finds the reactions with changed direction, exclusively involving
        %metabolites with dGf0 back calculated from keq
        if sum(dGft0SourceKeqBool(ind))==length(ind)
            forwardForwardKeq(n)=1;
        end
        %finds the qualitatively forward and quantitatively forward reactions, involving both
        %metabolites with dGf0 back calculated from keq and estimated using
        %the group contribution method
        if any(dGft0SourceKeqBool(ind)) && any(dGft0SourceGCBool(ind))
            forwardForwardKeqGC(n)=1;
        end
        %%qualitatively forward but GC quantitatively reversible & GC estimates for all reactants
        if sum(dGft0SourceGCBool(ind))==length(ind)
            forwardForwardGC(n)=1;
        end
    end
end
%Breakdown of Group Contribution relaxation of reaction directionality,
%Qualitiative vs Quantitative:

if printToFile
    fprintf(fid,'%10i\t%s\n',nnz(forwardReversible),' Forward -> Reversible (Total)');
    fprintf(fid,'%10i\t%s\n',nnz(forwardReversibleGC),' Forward -> Reversible (Based on dGft0 from Group Contribution)');
    fprintf(fid,'%10i\t%s\n',nnz(forwardReversibleKeqGC),' Forward -> Reversible (Based on dGft0 from Group Contribution and Keq)');
    fprintf(fid,'%10i\t%s\n',nnz(forwardReversibleKeq),' Forward -> Reversible (Based on dGft0 from Keq)');
    fprintf(fid,'\n');
else
    fprintf('%10i\t%s\n',nnz(forwardReversible),' Forward -> Reversible (Total)');
    fprintf('%10i\t%s\n',nnz(forwardReversibleGC),' Forward -> Reversible (Based on dGft0 from Group Contribution)');
    fprintf('%10i\t%s\n',nnz(forwardReversibleKeqGC),' Forward -> Reversible (Based on dGft0 from Group Contribution and Keq)');
    fprintf('%10i\t%s\n',nnz(forwardReversibleKeq),' Forward -> Reversible (Based on dGft0 from Keq)');
    fprintf('\n');
end

%for comparison
if printToFile
    fprintf(fid,'%10i\t%s\n',nnz(forwardForward),' Forward -> Forward (Total)');
    fprintf(fid,'%10i\t%s\n',nnz(forwardForwardGC),' Forward -> Forward (Based on dGft0 from Group Contribution)');
    fprintf(fid,'%10i\t%s\n',nnz(forwardForwardKeqGC),' Forward -> Forward (Based on dGft0 from Group Contribution and Keq)');
    fprintf(fid,'%10i\t%s\n',nnz(forwardForwardKeq),' Forward -> Forward (Based on dGft0 from Keq)');
    fprintf(fid,'\n');
else
    fprintf('%10i\t%s\n',nnz(forwardForward),' Forward -> Forward (Total)');
    fprintf('%10i\t%s\n',nnz(forwardForwardGC),' Forward -> Forward (Based on dGft0 from Group Contribution)');
    fprintf('%10i\t%s\n',nnz(forwardForwardKeqGC),' Forward -> Forward (Based on dGft0 from Group Contribution and Keq)');
    fprintf('%10i\t%s\n',nnz(forwardForwardKeq),' Forward -> Forward (Based on dGft0 from Keq)');
    fprintf('\n');
end

%Boolean index of reactions with at least one metabolite with dGft0 from
%group contribution data
dGfGCforwardReversibleBool=forwardReversibleGC | forwardReversibleKeqGC;
dGfGCforwardForwardBool=forwardForwardGC | forwardForwardKeqGC;

dGfGCforwardReversibleBool_byConcLHS=false(nRxn,1);
dGfGCforwardReversibleBool_byConcRHS=false(nRxn,1);
dGfGCforwardReversibleBool_bydGt0=false(nRxn,1);
dGfGCforwardReversibleBool_bydGt0LHS=false(nRxn,1);
dGfGCforwardReversibleBool_bydGt0Mid=false(nRxn,1);
dGfGCforwardReversibleBool_bydGt0RHS=false(nRxn,1);
dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS=false(nRxn,1);
dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS=false(nRxn,1);
for n=1:nRxn
    if dGfGCforwardReversibleBool(n)
        %find the qualitatively forward reactions that are quantitatively
        %reversible by concentration alone, and have always a negative
        %dGr0t, with no error in dGr0t
        t=0;
        if thorStandard==0
            if n==1
                if printToFile
                    fprintf(fid,'%s\n','Using 1 molar standard Gibbs energy of formation');
                else
                    fprintf('%s\n','Using 1 molar standard Gibbs energy of formation');
                end
            end
            if model.rxn(n).dGt0Max==model.rxn(n).dGt0Min
                if  model.rxn(n).dGt0Max<=0
                    dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS(n)=1;
                    t=1;
                end
                if model.rxn(n).dGt0Min>0
                    dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS(n)=1;
                    t=1;
                end
            else
                %find the qualitatively forward reactions that are quantitatively
                %reversible by the range of dGr0t
                if model.rxn(n).dGt0Min<0 && model.rxn(n).dGt0Max>0
                    dGfGCforwardReversibleBool_bydGt0(n)=1;
                    t=1;
                    %breakdown the reactions by probability of being forward
                    %dGrt0
                    Y0=(model.rxn(n).dGt0Min+model.rxn(n).dGt0Max)/2;
                    L0=Y0-model.rxn(n).dGt0Min;
                    U0=model.rxn(n).dGt0Max-Y0;
                    %dGrt
                    Y=(model.rxn(n).dGtMin+model.rxn(n).dGtMax)/2;
                    L=Y-model.rxn(n).dGtMin;
                    U=model.rxn(n).dGtMax-Y;
                    %cumulative of dGt0<0 assuming normal distribution, with
                    %mean dGt0, and stdev dGt0 from uncertainty
                    P = normcdf(0,Y0,L0);
                    if P<=cumNormProbFwdUpper && P>=cumNormProbFwdLower
                        dGfGCforwardReversibleBool_bydGt0Mid(n)=1;
                    end
                    if P>cumNormProbFwdUpper
                        dGfGCforwardReversibleBool_bydGt0LHS(n)=1;
                    end
                    if P<cumNormProbFwdLower
                        dGfGCforwardReversibleBool_bydGt0RHS(n)=1;
                    end
                end
                %find the qualitatively forward reactions that are quantitatively
                %reversible by concentration alone, and have always a
                %negative dGr0t
                if  model.rxn(n).dGt0Max<0
                    dGfGCforwardReversibleBool_byConcLHS(n)=1;
                    t=1;
                end
                %find the qualitatively forward reactions that are quantitatively
                %reversible by concentration alone, and have always a positive
                %dGr0t
                if model.rxn(n).dGt0Min>0
                    dGfGCforwardReversibleBool_byConcRHS(n)=1;
                    t=1;
                end
            end
        else
            %using milimolar standard
            if n==1
                if printToFile
                    fprintf(fid,'%s\n','Using thor standard Gibbs energy of formation');
                else
                    fprintf('%s\n','Using thor standard Gibbs energy of formation');
                end
            end
            if model.rxn(n).dGtmMMax==model.rxn(n).dGtmMMin
                if  model.rxn(n).dGtmMMax<=0
                    dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS(n)=1;
                    t=1;
                end
                if model.rxn(n).dGtmMMin>0
                    dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS(n)=1;
                    t=1;
                end
            else
                %find the qualitatively forward reactions that are quantitatively
                %reversible by the range of dGrtmM
                if model.rxn(n).dGtmMMin<0 && model.rxn(n).dGtmMMax>0
                    dGfGCforwardReversibleBool_bydGt0(n)=1;
                    t=1;
                    
                    %breakdown the reactions by probability of being forward
                    %dGrt0
                    Y0=(model.rxn(n).dGtmMMin+model.rxn(n).dGtmMMax)/2;
                    L0=Y0-model.rxn(n).dGtmMMin;
                    U0=model.rxn(n).dGtmMMax-Y0;
                    %dGrt
                    Y=(model.rxn(n).dGtMin+model.rxn(n).dGtMax)/2;
                    L=Y-model.rxn(n).dGtMin;
                    U=model.rxn(n).dGtMax-Y;
                  
                    %cumulative of dGt0<0 assuming normal distribution, with
                    %mean dGt0, and stdev dGt0 from uncertainty
                    P = normcdf(0,Y0,L0);

                    if P<=cumNormProbFwdUpper && P>=cumNormProbFwdLower
                        dGfGCforwardReversibleBool_bydGt0Mid(n)=1;
                    end
                    if P>cumNormProbFwdUpper
                        dGfGCforwardReversibleBool_bydGt0LHS(n)=1;
                    end
                    if P<cumNormProbFwdLower
                        dGfGCforwardReversibleBool_bydGt0RHS(n)=1;
                    end
                end
                %find the qualitatively forward reactions that are quantitatively
                %reversible by concentration alone, and have always a
                %negative dGr0t
                if  model.rxn(n).dGtmMMax<=0
                    dGfGCforwardReversibleBool_byConcLHS(n)=1;
                    t=1;
                end
                %find the qualitatively forward reactions that are quantitatively
                %reversible by concentration alone, and have always a positive
                %dGr0t
                if model.rxn(n).dGtmMMin>0
                    dGfGCforwardReversibleBool_byConcRHS(n)=1;
                    t=1;
                end
            end
        end
        if t==0
            model.rxn(n)
            error('directionalityStats.m : Extra category of reaction directionality not accounted for')
        end
    end
end
if printToFile
    fprintf(fid,'%s\n','Breakdown of Group Contribution, and mixed GC-Keq, derived relaxation of reaction directionality, Qualitiative vs Quantitative:');
    %total number of qualitatively forward reactions that are
    %quantitatively reversible
    fprintf(fid,'%10i\t%s\n',nnz(dGfGCforwardReversibleBool),' qualitatively forward reactions that are GC quantitatively reversible (total).');
    %qualitatively forward reactions that are quantitatively
    %reversible by concentration alone (no dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS),' qualitatively forward reactions that are GC quantitatively forward by dGr0t, but reversible by concentration alone (No error in GC dGr0t).');
    %qualitatively forward reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConcLHS),' qualitatively forward reactions that are GC quantitatively forward by dGr0t, but reversible by concentration alone (With error in GC dGr0t).');
    %qualitatively forward reactions that are quantitatively reversible by
    %the range of dGt0
    fprintf(fid,'%10i\t%s%s\n',nnz(dGfGCforwardReversibleBool_bydGt0LHS),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0. ',['P(\Delta_{r}G^{\primeo}<0) > ' num2str(cumNormProbFwdUpper)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s%s\n',nnz(dGfGCforwardReversibleBool_bydGt0Mid),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0. ',[num2str(cumNormProbFwdLower) '< P(\Delta_{r}G^{\primeo}<0) < ' num2str(cumNormProbFwdUpper)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s%s\n',nnz(dGfGCforwardReversibleBool_bydGt0RHS),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0. ',['P(\Delta_{r}G^{\primeo}<0) < ' num2str(cumNormProbFwdLower)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConcRHS),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration (With error in GC dGr0t).');
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (no dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.(No error in GC dGr0t).');
    fclose(fid);
else
    fprintf('%s\n','Breakdown of Group Contribution relaxation of reaction directionality, Qualitiative vs Quantitative:');
    %total number of qualitatively forward reactions that are
    %quantitatively reversible
    fprintf('%10i\t%s\n',nnz(dGfGCforwardReversibleBool),' qualitatively forward reactions that are GC quantitatively reversible (total).');
    %qualitatively forward reactions that are quantitatively
    %reversible by concentration alone (no dGt0 error)
    fprintf('%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS),' qualitatively forward reactions that are GC quantitatively forward by dGr0t, but reversible by concentration alone (No error in GC dGr0t).');
    %qualitatively forward reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf('%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConcLHS),' qualitatively forward reactions that are GC quantitatively forward by dGr0t, but reversible by concentration alone (With error in GC dGr0t).');
    %qualitatively forward reactions that are quantitatively reversible by
    %the range of dGt0
    fprintf('%10i\t%s%s\n',nnz(dGfGCforwardReversibleBool_bydGt0LHS),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0. ',['P(\Delta_{r}G^{\primeo}<0) > ' num2str(cumNormProbFwdUpper)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf('%10i\t%s%s\n',nnz(dGfGCforwardReversibleBool_bydGt0Mid),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0. ',[num2str(cumNormProbFwdLower) '< P(\Delta_{r}G^{\primeo}<0) < ' num2str(cumNormProbFwdUpper)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf('%10i\t%s%s\n',nnz(dGfGCforwardReversibleBool_bydGt0RHS),' qualitatively forward reactions that are GC quantitatively reversible by range of dGt0. ',['P(\Delta_{r}G^{\primeo}<0) < ' num2str(cumNormProbFwdLower)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf('%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConcRHS),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration (With error in GC dGr0t).');
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (no dGt0 error)
    fprintf('%10i\t%s\n',nnz(dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS),' qualitatively forward reactions that are GC quantitatively reverse by dGr0t, but reversible by concentration.(No error in GC dGr0t).');
end
%make structue out of directions
directions.fwdReconBool=fwdReconBool;
directions.revReconBool=revReconBool;
directions.reversibleReconBool=reversibleReconBool;
directions.fwdReconThermoBool=fwdReconThermoBool;
directions.revReconThermoBool=revReconThermoBool;
directions.reversibleReconThermoBool=reversibleReconThermoBool;
directions.fwdThermoOnlyBool=fwdThermoOnlyBool;
directions.revThermoOnlyBool=revThermoOnlyBool;
directions.reversibleThermoOnlyBool=reversibleThermoOnlyBool;
%add the changed directions 
directions.ChangeForwardForwardBool_dGfGC=dGfGCforwardForwardBool;
%changed directions
directions.ChangeReversibleFwd=reversibleFwd;
directions.ChangeReversibleRev=reversibleRev;
directions.ChangeForwardReverse=forwardReverse;
%all forward reversible classes
directions.ChangeForwardReversible=forwardReversible;
directions.ChangeForwardReversible_dGfKeq=forwardReversibleKeq;
directions.ChangeForwardReversibleBool_dGfGC=dGfGCforwardReversibleBool;
directions.ChangeForwardReversibleBool_dGfGC_byConcLHS=dGfGCforwardReversibleBool_byConcLHS;
directions.ChangeForwardReversibleBool_dGfGC_byConcRHS=dGfGCforwardReversibleBool_byConcRHS;
directions.ChangeForwardReversibleBool_dGfGC_bydGt0=dGfGCforwardReversibleBool_bydGt0;
directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS=dGfGCforwardReversibleBool_bydGt0LHS;
directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid=dGfGCforwardReversibleBool_bydGt0Mid;
directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS=dGfGCforwardReversibleBool_bydGt0RHS;
directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS=dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS;
directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS=dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS;
































