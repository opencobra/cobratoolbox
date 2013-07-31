function directionalityCheck(model,directions,printToFile,printToTable)
%identification of metabolites involved in reactions with changed
%directions
%
%Check to see which metabolites are involved in reactions that change the
%reconstruction directionality then print out the reactions that these
%metabolites are involved in.
%Does not include reactions that cannot be assigned reaction directionality
%due to missing thermodynamic data for certain metabolites involved
%in that reaction.
%
%INPUT
% model
%
% directions          output of directionalityStats.m
% directions.fwdReconBool=fwdReconBool;
% directions.fwdReconBool=revReconBool;
% directions.fwdReconBool=reversibleReconBool;
% directions.fwdReconThermoBool=fwdReconThermoBool;
% directions.revReconThermoBool=revReconThermoBool;
% directions.reversibleReconThermoBool=reversibleReconThermoBool;
% directions.fwdThermoOnlyBool=fwdThermoOnlyBool;
% directions.revThermoOnlyBool=revThermoOnlyBool;
% directions.reversibleThermoOnlyBool=reversibleThermoOnlyBool;
%%%add the changed directions 
% directions.ChangeForwardForwardBool_dGfGC=dGfGCforwardForwardBool;
% %changed directions
% directions.ChangeReversibleFwd=reversibleFwd;
% directions.ChangeReversibleRev=reversibleRev;
% directions.ChangeForwardReverse=forwardReverse;
%%%all forward reversible classes
% directions.ChangeForwardReversible=forwardReversible;
% directions.ChangeForwardReversible_dGfKeq=forwardReversibleKeq;
% directions.ChangeForwardReversibleBool_dGfGC=dGfGCforwardReversibleBool;
% directions.ChangeForwardReversibleBool_dGfGC_byConcLHS=dGfGCforwardReversibleBool_byConcLHS;
% directions.ChangeForwardReversibleBool_dGfGC_byConcRHS=dGfGCforwardReversibleBool_byConcRHS;
% directions.ChangeForwardReversibleBool_dGfGC_bydGt0=dGfGCforwardReversibleBool_bydGt0;
% directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS=dGfGCforwardReversibleBool_bydGt0LHS;
% directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid=dGfGCforwardReversibleBool_bydGt0Mid;
% directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS=dGfGCforwardReversibleBool_bydGt0RHS;
% directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS=dGfGCforwardReversibleBool_byConc_No_dGt0ErrorLHS;
% directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS=dGfGCforwardReversibleBool_byConc_No_dGt0ErrorRHS;
% directions.cumNormProbCutoff
%
% printToFile         1=print to a structured file not the command line,
%                       this is most useful for debugging reaction
%                       directionality
%
% printToTable        1=print out a tab delimited tables of reaction directionality, and reactions
%                       that change their directionality assignment along with another
%                       table of metabolites involved in either relaxation of constraints,
%                       or tightening of constraints.
%
%Ronan M.T. Fleming
[nMet,nRxn]=size(model.S);

%must be symmetric about 50:50 to be logically consistent
cumNormProbFwdUpper=0.5+directions.cumNormProbCutoff;
cumNormProbFwdLower=0.5-directions.cumNormProbCutoff;
    
% different classes of reaction changes in one Boolean matrix
g=1;
GB(g,:)=directions.ChangeReversibleFwd;
changeString{g}='qualitatively reversible -> quantiatively forward';
fileNameString{g}='qualitatively_reversible_to_quantiatively_forward';
g=g+1;
GB(g,:)=directions.ChangeReversibleRev;
changeString{g}='qualitatively reversible -> quantiatively reverse';
fileNameString{g}='qualitatively_reversible_to_quantiatively_reverse';
g=g+1;
GB(g,:)=directions.ChangeForwardReverse;
changeString{g}='qualitatively forward -> quantiatively reverse';
fileNameString{g}='qualitatively_forward_to_quantiatively_reverse';
g=g+1;

% forward reversible by Keq;
GB(g,:)=directions.ChangeForwardReversible_dGfKeq;
changeString{g}='qualitatively forward -> quantiatively reversible  (dGft0 from Keq).';
fileNameString{g}='forward_to_reversible__dGft0_from_Keq';
g=g+1;
% forward reversible by GC - 7 different classes
GB(g,:)=directions.ChangeForwardReversibleBool_dGfGC_byConcLHS;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (Negative dGt0 from GC, with uncertainty)';
fileNameString{g}='forward_to_reversible__negative_dGt0_from_GC_with_uncertainty';
g=g+1;
GB(g,:)=directions.ChangeForwardReversibleBool_dGfGC_byConcRHS;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (Positive dGt0 from GC, with uncertainty)';
fileNameString{g}='forward_to_reversible__positive_dGt0_from_GC_with_uncertainty';
g=g+1;
GB(g,:)=directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS;
changeString{g}=['qualitatively  forward -> quantiatively reversible (dGt0 from GC estimates span the zero line). Forward with probability greater than ' num2str(cumNormProbFwdUpper) '. (Upper cutoff for probability of a reaction to be forward)'];
fileNameString{g}='forward_to_reversible__dGft0_from_GC_spans_zero_probably_forward';
g=g+1;
GB(g,:)=directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid;
changeString{g}=['qualitatively  forward -> quantiatively reversible (dGt0 from GC estimates span the zero line; Between ' num2str(cumNormProbFwdUpper) ' and ' num2str(cumNormProbFwdLower) 'probability of being forward'];
fileNameString{g}='forward_to_reversible__dGft0_from_GC_spans_zero_possibly_reversible';
g=g+1;
GB(g,:)=directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS;
changeString{g}=['qualitatively  forward -> quantiatively reversible (dGt0 from GC estimates span the zero line). Reverse with probability greater than ' num2str(1-cumNormProbFwdLower) '. (1 - Lower cutoff for probability of a reaction to be forward)'];
fileNameString{g}='forward_to_reversible__dGft0_from_GC_spans_zero_probably_reverse';
g=g+1;
GB(g,:)=directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (Negative exact dGt0 from GC)';
fileNameString{g}='forward_to_reversible__negative_exact_dGt0_from_GC';
g=g+1;
GB(g,:)=directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (Positive exact dGt0 from GC)';
fileNameString{g}='forward_to_reversible__positive_exact_dGt0_from_GC';


%all possible compartments
p=1;
compartments{p,1}='c';
compartments{p,2}='cytoplasm';
p=p+1;
compartments{p,1}='p';
compartments{p,2}='periplasm';
p=p+1;
compartments{p,1}='e';
compartments{p,2}='extracellular';
p=p+1;
compartments{p,1}='m';
compartments{p,2}='mitochondria';
p=p+1;
compartments{p,1}='n';
compartments{p,2}='nucleus';
p=p+1;
compartments{p,1}='r';
compartments{p,2}='endoplasmic reticulum';
p=p+1;
compartments{p,1}='l';
compartments{p,2}='lysosome';
p=p+1;
compartments{p,1}='x';
compartments{p,2}='peroxisome';

%set this value to one in order to get separate files for the different
%types of changes
separateFiles=1;
if printToFile

    if separateFiles==0
        fid=fopen('changedDirections_StructuredView.txt','w');
    end

    %gas constant times temperature
    rt=model.gasConstant*model.temp;
   
    for g=1:size(GB,1)
        if separateFiles==1
            fid=fopen([fileNameString{g} '_StructuredView.txt'],'w');
        else
            if g~=1
                fprintf(fid,'\n');
            end
        end
        
        %annotate file with important parameters
        fprintf(fid,'%s\n',datestr(now));
        fprintf(fid,'%g\t%s\n',model.temp,':temperature 273.15 K to 313.15 K');
        for p=1:length(compartments)
            if isfield(model.PHA,compartments{p,1})
                fprintf(fid,'%g\t%s%s%s%s%s\n',model.PHA.(compartments{p,1}),':[',compartments{p,1},'] ', compartments{p,1}, ' glass electrode pH.');
            end
        end
        for p=1:length(compartments)
            if isfield(model.IS,compartments{p,1})
                fprintf(fid,'%g\t%s%s%s%s%s\n',model.IS.(compartments{p,1}),':[',compartments{p,1},'] ', compartments{p,1}, ' ionic strength.');
            end
        end
        for p=1:length(compartments)
            if isfield(model.CHI,compartments{p,1})
                fprintf(fid,'%g\t%s%s%s%s%s\n',model.CHI.(compartments{p,1}),':[',compartments{p,1},'] ', compartments{p,1}, ' electrical potential (mV).');
            end
        end
        fprintf(fid,'%g\t%s\n',cumNormProbFwdUpper,': Upper cutoff for probability of a reaction to be forward.');
        fprintf(fid,'%g\t%s\n',cumNormProbFwdLower,': Lower cutoff for probability of a reaction to be forward');
        fprintf(fid,'%g\t%s\n',model.nStdDevGroupCont,': # std. dev. of group contribution uncertainty');
        fprintf(fid,'\n');
    
        %find the metabolites causing forward reactions to go in reverse
        if max(GB(g,:))==1
            Stmp=model.S(:,GB(g,:));
            tmpMet=zeros(nMet,1);
            for m=1:nMet
                tmpMet(m,1)=nnz(Stmp(m,:));
            end
            %print out the culprits in order of worst offender
            [sorted,sInd]=sort(tmpMet,'descend');
            p=1;
            fprintf(fid,'%s\n',['Metabolites which force ' int2str(nnz(GB(g,:))) ' ' changeString{g}]);
            %while tmpMet(sInd(p))>0 && p <= length(sInd)
            while p <= length(sInd) && tmpMet(sInd(p))>0
                if ~strcmp(model.met(sInd(p)).dGft0Source,'Keq')
                    dataSource='gc';
                else
                    dataSource='Keq';
                end
                fprintf(fid,'%u%s\t%u\t%s\t%20s\t%s\n',sInd(p),':',tmpMet(sInd(p)),dataSource,model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
                p=p+1;
            end
            fprintf(fid,'\n');
            fprintf(fid,'\n');
            
            %print out for each problematic reaction
            for n=1:nRxn
                if GB(g,n)==1
                    fprintf(fid,'%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,model.rxn(n).officialName,model.rxn(n).abbreviation,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
                    %                 fprintf(fid,'%i\t%s\t%6.2f\t%6.2f\n\t%s\n',n,model.rxn(n).officialName,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
                    sInd=find(model.S(:,n)<0);
                    for p=1:length(sInd)
                        %                 fprintf(fid,'\t\t%i\t\t%6.2f\t\t%6.2f\t%6.2f\t\t%i\t%s%s\n',full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),sInd(p),model.met(sInd(p)).officialName,[' ' model.met(sInd(p)).abbreviation(end-2:end)]);
                        fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
                    end
                    fprintf(fid,'%s\n','products:');
                    pInd=find(model.S(:,n)>0);
                    for p=1:length(pInd)
                        fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),full(model.S(pInd(p),n)),model.met(pInd(p)).dGft0,rt*log(model.met(pInd(p)).concMin),rt*log(model.met(pInd(p)).concMax),model.met(pInd(p)).abbreviation,model.met(pInd(p)).officialName);
                    end
                    fprintf(fid,'\n');
                end
            end
        end
        %close the separate files
        if separateFiles==1
            fclose(fid);
        end
    end
    if separateFiles==0
        fclose(fid);
    end
end

%set this value to 1 in order to get separate files for the different
%types of changes
separateFiles=1;
if printToTable
    [nMet,nRxn]=size(model.S);
    
    %print out each metabolite in turn
    fid=fopen('MetabolitesTab.txt','w');
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
        'Abbreviation','Name','dGft0Source','AlbertyAbbreviation','dGft0_Alberty',...
        'dHft0_Alberty','Average charge','Average H bound','dGf0_GroupCont','dGft0_GroupCont',...
        'dGft0_GroupContUncertainty','chargeMarvin','formulaMarvin');
    for m=1:nMet
        if strcmp(model.mets{m},'acorn[c]')
            pause(eps)
        end
        %round to one decimal place in tables
        fprintf(fid,'%s\t%s\t%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%s',...
            model.mets{m},...
            model.met(m).officialName,...
            model.met(m).dGft0Source,...
            model.met(m).albertyAbbreviation,...
            model.met(m).dGft0Keq,...
            model.met(m).dHft0Keq,...
            model.met(m).aveZi,...
            model.met(m).aveHbound,...
            model.met(m).dGf0GroupCont,...
            model.met(m).dGft0GroupCont,...
            model.met(m).dGft0GroupContUncertainty,...
            model.met(m).chargeMarvin,...
            model.met(m).formulaMarvin);
        fprintf(fid,'\n');
    end
    fclose(fid);
    
    %print out each reaction in turn and its directionality
    fid=fopen('ReactionsTab.txt','w');
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
        'Abbreviation','Name','Equation','Qualitative Direction','Quantitative direction (1st pass)',...
        'dGt0Min','dGt0Max','dGtmMin','dGtmMax','dGtMin','dGtMax');
    for n=1:nRxn
        if strcmp(model.rxns{n},'PNS1')
            pause(eps)
        end
        %round to one decimal place in tables
        if isfield(model.rxn(n),'dGtmMin')
            fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\n',...
                model.rxns{n},...
                model.rxn(n).officialName,...
                model.rxn(n).equation,...
                model.rxn(n).directionality,...
                model.rxn(n).directionalityThermo,...
                model.rxn(n).dGt0Min,...
                model.rxn(n).dGt0Max,...
                model.rxn(n).dGtmMin,...
                model.rxn(n).dGtmMax,...
                model.rxn(n).dGtMin,...
                model.rxn(n).dGtMax);
        else
                fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\n',...
                model.rxns{n},...
                model.rxn(n).officialName,...
                model.rxn(n).equation,...
                model.rxn(n).directionality,...
                model.rxn(n).directionalityThermo,...
                model.rxn(n).dGt0Min,...
                model.rxn(n).dGt0Max,...
                NaN,...
                NaN,...
                model.rxn(n).dGtMin,...
                model.rxn(n).dGtMax);
            
        end
    end
    fclose(fid);
    
    if separateFiles==0
        fid=fopen('reactionDirectionalityChangesTab.txt','w');
    end
    
    for g=1:size(GB,1)
        if separateFiles==1
            fid=fopen([fileNameString{g} '.txt'],'w');
        else
            if g~=1
                fprintf(fid,'\n');
            end
        end
        
        %annotate file with important parameters
        fprintf(fid,'%s\n',datestr(now));
        fprintf(fid,'%g\t%s\n',model.temp,':temperature 273.15 K to 313.15 K');
        for p=1:length(compartments)
            if isfield(model.PHA,compartments{p,1})
                fprintf(fid,'%g\t%s%s%s%s%s\n',model.PHA.(compartments{p,1}),':[',compartments{p,1},'] ', compartments{p,1}, ' glass electrode pH.');
            end
        end
        for p=1:length(compartments)
            if isfield(model.IS,compartments{p,1})
                fprintf(fid,'%g\t%s%s%s%s%s\n',model.IS.(compartments{p,1}),':[',compartments{p,1},'] ', compartments{p,1}, ' ionic strength.');
            end
        end
        for p=1:length(compartments)
            if isfield(model.CHI,compartments{p,1})
                fprintf(fid,'%g\t%s%s%s%s%s\n',model.CHI.(compartments{p,1}),':[',compartments{p,1},'] ', compartments{p,1}, 'electrical potential (mV).');
            end
        end
        fprintf(fid,'%g\t%s\n',cumNormProbFwdUpper,': Upper cutoff for probability of a reaction to be forward.');
        fprintf(fid,'%g\t%s\n',cumNormProbFwdLower,': Lower cutoff for probability of a reaction to be forward');
        fprintf(fid,'%g\t%s\n',model.nStdDevGroupCont,': # std. dev. of group contribution uncertainty');
        fprintf(fid,'\n');
        
        %reactions
        for n=1:nRxn
            if GB(g,n)==1
                fprintf(fid,'%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\n',model.rxn(n).officialName,model.rxn(n).equation,model.rxn(n).dGt0Min,model.rxn(n).dGt0Max,model.rxn(n).dGtMin,model.rxn(n).dGtMax);
            end
        end
        fprintf(fid,'\n');
        
        %metabolites
        fprintf(fid,'%s\n','Cytoplasmic metabolites only:');
        allMetSum=full(sum(abs(model.S(:,GB(g,:))),2));
        for m=1:nMet
            %only cytoplasmic metabolites to avoid duplicates
            if allMetSum(m)>0 && strcmp(model.met(m).abbreviation(end-2:end),'[c]')
                fprintf(fid,'%d\t%s\t%s\t%.1f\t%.1f\t%.1f\t%s\n',allMetSum(m),model.met(m).abbreviation(1:end-3),model.met(m).officialName,model.met(m).dGft0Keq,model.met(m).dGft0GroupCont,model.met(m).dGft0GroupContUncertainty,model.met(m).dGft0Source);
            end
        end
        
        if separateFiles==1
            fclose(fid);
        end
    end
    if separateFiles==0
        fclose(fid);
    end
end


% %finds the qualitatively forward reactions that are now reversible
% %where the reaction exclusively involves metabolites with
% %dGf0 back calculated from keq
% dGft0SourceKeqBool=false(nMet,1);
% for m=1:nMet
%     if strcmp(model.met(m).dGft0Source,'Keq')
%         dGft0SourceKeqBool(m,1)=1;
%     end
% end
% forwardReversibleKeq=false(nRxn,1);
% for n=1:nRxn
%     if changedDirections.forwardReversible(n)
%         ind=find(model.S(:,n));
%         %finds the reactions with changed direction, exclusively involving
%         %metabolites with dGf0 back calculated from keq
%         if sum(dGft0SourceKeqBool(ind))==length(ind)
%             forwardReversibleKeq(n)=1;
%         end
%     end
% end
%
% fprintf(fid,'\n');
% for n=1:nRxn
%     if forwardReversibleKeq(n)
%         fprintf(fid,'%s\t%s\t%g\t%g\t%g\t%g\n',model.rxn(n).officialName,model.rxn(n).equation,model.rxn(n).dGt0Min,model.rxn(n).dGt0Max,model.rxn(n).dGtMin,model.rxn(n).dGtMax);
%     end
% end
% fprintf(fid,'\n');
% for n=1:nRxn
%     if changedDirections.reversibleFwd(n)
%         fprintf(fid,'%s\t%s\t%g\t%g\t%g\t%g\n',model.rxn(n).officialName,model.rxn(n).equation,model.rxn(n).dGt0Min,model.rxn(n).dGt0Max,model.rxn(n).dGtMin,model.rxn(n).dGtMax);
%     end
% end
% fprintf(fid,'\n');
% for n=1:nRxn
%     if changedDirections.reversibleRev(n)
%         fprintf(fid,'%s\t%s\t%g\t%g\t%g\t%g\n',model.rxn(n).officialName,model.rxn(n).equation,model.rxn(n).dGt0Min,model.rxn(n).dGt0Max,model.rxn(n).dGtMin,model.rxn(n).dGtMax);
%     end
% end
% fprintf(fid,'\n');
% for n=1:nRxn
%     if changedDirections.forwardReverse(n)
%         fprintf(fid,'%s\t%s\t%g\t%g\t%g\t%g\n',model.rxn(n).officialName,model.rxn(n).equation,model.rxn(n).dGt0Min,model.rxn(n).dGt0Max,model.rxn(n).dGtMin,model.rxn(n).dGtMax);
%     end
% end
%
% %print out the metabolites involved in these reactions with changed
% %directions
% fprintf(fid,'\n');
% allTighterRxnBool=changedDirections.reversibleFwd | changedDirections.reversibleRev | changedDirections.forwardReverse;
% allTighterMetSum=sum(abs(model.S(:,allTighterRxnBool)),2);
% for m=1:nMet
%     %only cytoplasmic metabolites to avoid duplicates
%     if allTighterMetSum(m)>0 & strcmp(model.met(m).abbreviation(end-2:end),'[c]')
%         fprintf(fid,'%d\t%s\t%s\t%g\t%g\t%g\t%s\n',allTighterMetSum(m),model.met(m).abbreviation(1:end-3),model.met(m).officialName,model.met(m).dGft0Keq,model.met(m).dGft0GroupCont,model.met(m).dGft0GroupContUncertainty,model.met(m).dGft0Source);
%     end
% end
%
% fprintf(fid,'\n');
% allLooserMetSum=sum(abs(model.S(:,forwardReversibleKeq)),2);
% for m=1:nMet
%     %only cytoplasmic metabolites to avoid duplicates
%     if allLooserMetSum(m)>0 & strcmp(model.met(m).abbreviation(end-2:end),'[c]')
%         fprintf(fid,'%d\t%s\t%s\t%g\t%g\t%g\t%s\n',allLooserMetSum(m),model.met(m).abbreviation(1:end-3),model.met(m).officialName,model.met(m).dGft0Keq,model.met(m).dGft0GroupCont,model.met(m).dGft0GroupContUncertainty,model.met(m).dGft0Source);
%     end
% end
%
% fclose(fid);




%
%
%
%
%
% %find the metabolites causing forward reactions to be reversible
% if max(forwardReversible)==1
%     SforwardReversible=model.S(:,forwardReversible);
%     forwardReversibleMet=zeros(nMet,1);
%     for m=1:nMet
%         forwardReversibleMet(m,1)=nnz(SforwardReversible(m,:));
%     end
%     %print out the culprits in order of worst offender
%     [sorted,sInd]=sort(forwardReversibleMet,'descend');
%     p=1;
%     fprintf(fid,'%s\n',['Metabolites which allow ' int2str(nnz(forwardReversible)) ' forward reactions to be reversible:']);
%     while forwardReversibleMet(sInd(p))>0
%         if ~strcmp(model.met(sInd(p)).dGft0Source,'Keq')
%             dataSource='gc';
%         else
%             dataSource='Keq';
%         end
%         fprintf(fid,'%u%s\t%u\t%s\t%20s\t%s\n',sInd(p),':',forwardReversibleMet(sInd(p)),dataSource,model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%         p=p+1;
%     end
%     fprintf(fid,'\n');
%     fprintf(fid,'\n');
%
%     %print out for each problematic reaction
%     for n=1:nRxn
%         if forwardReversible(n)==1
%             fprintf(fid,'%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,model.rxn(n).officialName,model.rxn(n).abbreviation,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
%             %                 fprintf(fid,'%i\t%s\t%6.2f\t%6.2f\n\t%s\n',n,model.rxn(n).officialName,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
%             sInd=find(model.S(:,n)<0);
%             for p=1:length(sInd)
%                 %                 fprintf(fid,'\t\t%i\t\t%6.2f\t\t%6.2f\t%6.2f\t\t%i\t%s%s\n',full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),sInd(p),model.met(sInd(p)).officialName,[' ' model.met(sInd(p)).abbreviation(end-2:end)]);
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%             end
%             fprintf(fid,'%s\n','products:');
%             pInd=find(model.S(:,n)>0);
%             for p=1:length(pInd)
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),model.S(pInd(p),n),model.met(pInd(p)).dGft0,rt*log(model.met(pInd(p)).concMin),rt*log(model.met(pInd(p)).concMax),model.met(pInd(p)).abbreviation,model.met(pInd(p)).officialName);
%             end
%             fprintf(fid,'\n');
%         end
%     end
% end
%
%
% %find the metabolites causing reversible reactions to go forward only
% if max(reversibleFwd)==1
%     SreversibleFwd=model.S(:,reversibleFwd);
%     reversibleFwdMet=zeros(nMet,1);
%     for m=1:nMet
%         reversibleFwdMet(m,1)=nnz(SreversibleFwd(m,:));
%     end
%     %print out the culprits in order of worst offender
%     [sorted,sInd]=sort(reversibleFwdMet,'descend');
%     p=1;
%     fprintf(fid,'%s\n',['Metabolites which force ' int2str(nnz(reversibleFwd)) ' reversible reactions to go forwards']);
%     while reversibleFwdMet(sInd(p))>0
%         if ~strcmp(model.met(sInd(p)).dGft0Source,'Keq')
%             dataSource='gc';
%         else
%             dataSource='Keq';
%         end
%         fprintf(fid,'%u%s\t%u\t%s\t%20s\t%s\n',sInd(p),':',reversibleFwdMet(sInd(p)),dataSource,model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%         p=p+1;
%     end
%     fprintf(fid,'\n');
%     fprintf(fid,'\n');
%
%     %print out for each problematic reaction
%     for n=1:nRxn
%         if reversibleFwd(n)==1
%             fprintf(fid,'%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,model.rxn(n).officialName,model.rxn(n).abbreviation,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
%             sInd=find(model.S(:,n)<0);
%             for p=1:length(sInd)
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%             end
%             fprintf(fid,'%s\n','products:');
%             pInd=find(model.S(:,n)>0);
%             for p=1:length(pInd)
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),model.S(pInd(p),n),model.met(pInd(p)).dGft0,rt*log(model.met(pInd(p)).concMin),rt*log(model.met(pInd(p)).concMax),model.met(pInd(p)).abbreviation,model.met(pInd(p)).officialName);
%             end
%             fprintf(fid,'\n');
%         end
%     end
%     fprintf(fid,'\n');
%     fprintf(fid,'\n');
% end
%
% %find the metabolites causing reversible reactions to go in reverse only
% if max(reversibleRev)==1
%     SreversibleRev=model.S(:,reversibleRev);
%     reversibleRevMet=zeros(nMet,1);
%     for m=1:nMet
%         reversibleRevMet(m,1)=nnz(SreversibleRev(m,:));
%     end
%     %print out the culprits in order of worst offender
%     [sorted,sInd]=sort(reversibleRevMet,'descend');
%     p=1;
%     fprintf(fid,'%s\n',['Metabolites which force ' int2str(nnz(reversibleRev)) ' reversible reactions to go in reverse']);
%     while reversibleRevMet(sInd(p))>0
%         if ~strcmp(model.met(sInd(p)).dGft0Source,'Keq')
%             dataSource='gc';
%         else
%             dataSource='Keq';
%         end
%         fprintf(fid,'%u%s\t%u\t%s\t%20s\t%s\n',sInd(p),':',reversibleRevMet(sInd(p)),dataSource,model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%         p=p+1;
%     end
%     fprintf(fid,'\n');
%     fprintf(fid,'\n');
%
%     %print out for each problematic reaction
%     for n=1:nRxn
%         if reversibleRev(n)==1
%             fprintf(fid,'%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,model.rxn(n).officialName,model.rxn(n).abbreviation,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
%             sInd=find(model.S(:,n)<0);
%             for p=1:length(sInd)
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%             end
%             fprintf(fid,'%s\n','products:');
%             pInd=find(model.S(:,n)>0);
%             for p=1:length(pInd)
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),model.S(pInd(p),n),model.met(pInd(p)).dGft0,rt*log(model.met(pInd(p)).concMin),rt*log(model.met(pInd(p)).concMax),model.met(pInd(p)).abbreviation,model.met(pInd(p)).officialName);
%             end
%             fprintf(fid,'\n');
%         end
%     end
%     fprintf(fid,'\n');
%     fprintf(fid,'\n');
% end
%
% %find the metabolites causing forward reactions to go in reverse
% if max(forwardReverse)==1
%     SforwardReverse=model.S(:,forwardReverse);
%     forwardReverseMet=zeros(nMet,1);
%     for m=1:nMet
%         forwardReverseMet(m,1)=nnz(SforwardReverse(m,:));
%     end
%     %print out the culprits in order of worst offender
%     [sorted,sInd]=sort(forwardReverseMet,'descend');
%     p=1;
%     fprintf(fid,'%s\n',['Metabolites which force ' int2str(nnz(forwardReverse)) ' forward reactions to go in reverse']);
%     while forwardReverseMet(sInd(p))>0
%         if ~strcmp(model.met(sInd(p)).dGft0Source,'Keq')
%             dataSource='gc';
%         else
%             dataSource='Keq';
%         end
%         fprintf(fid,'%u%s\t%u\t%s\t%20s\t%s\n',sInd(p),':',forwardReverseMet(sInd(p)),dataSource,model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%         p=p+1;
%     end
%     fprintf(fid,'\n');
%     fprintf(fid,'\n');
%
%     %print out for each problematic reaction
%     for n=1:nRxn
%         if forwardReverse(n)==1
%             fprintf(fid,'%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,model.rxn(n).officialName,model.rxn(n).abbreviation,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
%             %                 fprintf(fid,'%i\t%s\t%6.2f\t%6.2f\n\t%s\n',n,model.rxn(n).officialName,model.rxn(n).dGtMin,model.rxn(n).dGtMax,'substrates:');
%             sInd=find(model.S(:,n)<0);
%             for p=1:length(sInd)
%                 %                 fprintf(fid,'\t\t%i\t\t%6.2f\t\t%6.2f\t%6.2f\t\t%i\t%s%s\n',full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),sInd(p),model.met(sInd(p)).officialName,[' ' model.met(sInd(p)).abbreviation(end-2:end)]);
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),full(model.S(sInd(p),n)),model.met(sInd(p)).dGft0,rt*log(model.met(sInd(p)).concMin),rt*log(model.met(sInd(p)).concMax),model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%             end
%             fprintf(fid,'%s\n','products:');
%             pInd=find(model.S(:,n)>0);
%             for p=1:length(pInd)
%                 fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),model.S(pInd(p),n),model.met(pInd(p)).dGft0,rt*log(model.met(pInd(p)).concMin),rt*log(model.met(pInd(p)).concMax),model.met(pInd(p)).abbreviation,model.met(pInd(p)).officialName);
%             end
%             fprintf(fid,'\n');
%         end
%     end
% end
%
% fclose(fid);
%
%
