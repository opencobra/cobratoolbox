function directionalityChangeReport(model, directions, cumNormProbCutoff, printLevel, resultsBaseFileName)
% Checks for changes to reconstruction reaction direction to
% thermodynamically constrained model direction .
%
% .. TODO: identify metabolites involved in reactions with changed directions
%
% Checks to see which metabolites are involved in reactions that change the
% reconstruction directionality then print out the reactions that these
% metabolites are involved in.
% Does not include reactions that cannot be assigned reaction directionality
% due to missing thermodynamic data for certain metabolites involved
% in that reaction.
%
% USAGE:
%
%    directionalityChangeReport(model, directions, cumNormProbCutoff, printLevel, resultsBaseFileName)
%
% INPUTS:
%    model:                  COBRA structure
%    directions:             a structue of boolean vectors with different directionality
%                            assignments where some vectors contain subsets of others
%
%                            qualtiative -> quantiative changed reaction directions
%
%                              * .forward2Forward
%                              * .forward2Reverse
%                              * .forward2Reversible
%                              * .forward2Uncertain
%                              * .reversible2Forward
%                              * .reversible2Reverse
%                              * .reversible2Reversible
%                              * .reversible2Uncertain
%                              * .reverse2Forward
%                              * .reverse2Reverse
%                              * .reverse2Reversible
%                              * .reverse2Uncertain
%                              * .tightened
%                            subsets of qualtiatively forward  -> quantiatively reversible
%
%                              * .forward2Reversible_bydGt0
%                              * .forward2Reversible_bydGt0LHS
%                              * .forward2Reversible_bydGt0Mid
%                              * .forward2Reversible_bydGt0RHS
%                              * .forward2Reversible_byConc_zero_fixed_DrG0
%                              * .forward2Reversible_byConc_negative_fixed_DrG0
%                              * .forward2Reversible_byConc_positive_fixed_DrG0
%                              * .forward2Reversible_byConc_negative_uncertain_DrG0
%                              * .forward2Reversible_byConc_positive_uncertain_DrG0
%
%    cumNormProbCutoff:      {0.2} cutoff for probablity that reaction is
%                            reversible within this cutoff of 0.5
%    printLevel:             verbose level
%    resultsBaseFileName:
%
% .. Author: - Ronan M.T. Fleming


if ~exist('printLevel','var')
    printLevel=1;
else
    if printLevel<0
        if ~exist('resultsBaseFileName','var')
            resultsBaseFileName='';
        end
    end
end

if exist('resultsBaseFileName','var')
    printLevel=-1;
end

[nMet,nRxn]=size(model.S);

%must be symmetric about 50:50 to be logically consistent
cumNormProbFwdUpper=0.5+cumNormProbCutoff;
cumNormProbFwdLower=0.5-cumNormProbCutoff;

g=1;
% different classes of reaction changes in one Boolean matrix
GB(g,:)=directions.forward2Forward;
changeString{g}='qualitatively forward -> quantiatively forward';
fileNameString{g}='qualitatively_forward_to_quantiatively_forward';
g=g+1;
GB(g,:)=directions.forward2Reverse;
changeString{g}='qualitatively forward -> quantiatively reverse';
fileNameString{g}='qualitatively_forward_to_quantiatively_reverse';
g=g+1;
GB(g,:)=directions.forward2Reversible;
changeString{g}='qualitatively forward -> quantiatively reversible  (DrGt0 from component contribution).';
fileNameString{g}='forward_to_reversible_DrGt0';
g=g+1;
GB(g,:)=directions.forward2Uncertain;
changeString{g}='qualitatively forward -> quantiatively uncertain  (DrGt0 from component contribution).';
fileNameString{g}='forward_to_uncertain_DrGt0';
g=g+1;
GB(g,:)=directions.reversible2Reversible;
changeString{g}='qualitatively reversible -> quantiatively reversible';
fileNameString{g}='qualitatively_reversible_to_quantiatively_reversible';
g=g+1;
GB(g,:)=directions.reversible2Forward;
changeString{g}='qualitatively reversible -> quantiatively forward';
fileNameString{g}='qualitatively_reversible_to_quantiatively_forward';
g=g+1;
GB(g,:)=directions.reversible2Reverse;
changeString{g}='qualitatively reversible -> quantiatively reverse';
fileNameString{g}='qualitatively_reversible_to_quantiatively_reverse';
g=g+1;
GB(g,:)=directions.reversible2Uncertain;
changeString{g}='qualitatively reversible -> quantiatively uncertain';
fileNameString{g}='qualitatively_reversible_to_quantiatively_uncertain';
g=g+1;

GB(g,:)=directions.forward2Reversible_bydGt0;
changeString{g}=['qualitatively  forward -> quantiatively reversible (DrG0t span the zero line; Between ' num2str(cumNormProbFwdLower) ' and ' num2str(cumNormProbFwdUpper) 'probability of being forward'];
fileNameString{g}='forward_to_reversible_DrG0t_spans_zero_possibly_reversible';
g=g+1;
GB(g,:)=directions.forward2Reversible_bydGt0LHS;
changeString{g}=['qualitatively  forward -> quantiatively reversible (DrG0t span the zero line). Forward with probability less than ' num2str(cumNormProbFwdLower) '. (Lower cutoff for probability of a reaction to be forward)'];
fileNameString{g}='forward_to_reversible_DrG0t_spans_zero_probably_forward';
g=g+1;
GB(g,:)=directions.forward2Reversible_bydGt0Mid;
changeString{g}=['qualitatively  forward -> quantiatively reversible (DrG0t span the zero line; Between ' num2str(cumNormProbFwdUpper) ' and ' num2str(cumNormProbFwdLower) 'probability of being forward.'];
fileNameString{g}='forward_to_reversible_DrG0t_spans_zero_possibly_reversible';
g=g+1;
GB(g,:)=directions.forward2Reversible_bydGt0RHS;
changeString{g}=['qualitatively  forward -> quantiatively reversible (DrG0t span the zero line). Forward with probability greater than ' num2str(cumNormProbFwdUpper) '.'];
fileNameString{g}='forward_to_reversible_DrG0t_spans_zero_probably_reverse';
g=g+1;

GB(g,:)=directions.forward2Reversible_byConc_zero_fixed_DrG0;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (zero exact DrG0t)';
fileNameString{g}='forward_to_reversible_negative_exact_DrG0t';
g=g+1;
GB(g,:)=directions.forward2Reversible_byConc_negative_fixed_DrG0;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (negative exact DrG0t)';
fileNameString{g}='forward_to_reversible_negative_exact_DrG0t';
g=g+1;
GB(g,:)=directions.forward2Reversible_byConc_positive_fixed_DrG0;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (positive exact DrG0t)';
fileNameString{g}='forward_to_reversible_positive_exact_DrG0t';
g=g+1;
GB(g,:)=directions.forward2Reversible_byConc_negative_uncertain_DrG0;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (negative uncertain DrG0t)';
fileNameString{g}='forward_to_reversible_negative_uncertain_DrG0t';
g=g+1;
GB(g,:)=directions.forward2Reversible_byConc_positive_uncertain_DrG0;
changeString{g}='qualitatively  forward -> quantiatively reversible by concentration (positive uncertain DrGt0)';
fileNameString{g}='forward_to_reversible_positive_uncertain_DrG0t';
g=g+1;

%set this value to one in order to get separate files for the different
%types of changes
separateFiles=1;
if printLevel<0
    if separateFiles==0
        fid=fopen([resultsBaseFileName '_changedDirections_StructuredView.txt'],'w');
    end
    %gas constant times temperature
    rt=model.gasConstant*model.T;

    for g=1:size(GB,1)
        if separateFiles==1
            fid=fopen([resultsBaseFileName, fileNameString{g} '_StructuredView.txt'],'w');
        else
            if g~=1
                fprintf(fid,'\n');
            end
        end

        %find the metabolites causing forward reactions to go in reverse
        if any(GB(g,:))
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
                fprintf(fid,'%u%s\t%u\t%s%s\n',sInd(p),':',tmpMet(sInd(p)),model.mets{sInd(p)},model.metNames{sInd(p)});
                p=p+1;
            end
            fprintf(fid,'\n');
            fprintf(fid,'\n');

            %print out for each problematic reaction
            for n=1:nRxn
                if GB(g,n)==1
                    fprintf(fid,'%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,model.rxnNames{n},model.rxns{n},model.DrGtMin(n),model.DrGtMax(n),'substrates:');
                    sInd=find(model.S(:,n)<0);
                    for p=1:length(sInd)
                        fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),full(model.S(sInd(p),n)),model.DfGt0(sInd(p)),rt*log(model.concMin(sInd(p))),rt*log(model.concMax(sInd(p))),model.mets{sInd(p)},model.metNames{sInd(p)});
                    end
                    fprintf(fid,'%s\n','products:');
                    pInd=find(model.S(:,n)>0);
                    for p=1:length(pInd)
                        fprintf(fid,'%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),full(model.S(pInd(p),n)),model.DfGt0(pInd(p)),rt*log(model.concMin(pInd(p))),rt*log(model.concMax(pInd(p))),model.mets{pInd(p)},model.metNames{pInd(p)});
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
if printLevel<1

    if separateFiles==0
        fid=fopen([resultsBaseFileName '_reactionDirectionalityChangesTab.txt'],'w');
    end

    for g=1:size(GB,1)
        if separateFiles==1
            fid=fopen([resultsBaseFileName fileNameString{g} '.txt'],'w');
        else
            if g~=1
                fprintf(fid,'\n');
            end
        end

        %reactions
        for n=1:nRxn
            if GB(g,n)==1
                equation=printRxnFormula(model,model.rxns{n},0);
                fprintf(fid,'%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\n',model.rxns{n},equation{1},model.DrGt0Min(n),model.DrGt0Max(n),model.DrGtMin(n),model.DrGtMax(n));
            end
        end
        fprintf(fid,'\n');

        %metabolites
        fprintf(fid,'%s\n','Cytoplasmic metabolites only:');
        allMetSum=full(sum(abs(model.S(:,GB(g,:))),2));
        for m=1:nMet
            %only cytoplasmic metabolites to avoid duplicates
            if allMetSum(m)>0 && strcmp(model.mets{m}(end-2:end),'[c]')
                fprintf(fid,'%d\t%s\t%s\t%.1f\t%.1f\t\n',allMetSum(m),model.mets{m}(1:end-3),model.mets{m},model.DfGt0(m),model.DfG0_Uncertainty(m));
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
% forward2ReversibleKeq=false(nRxn,1);
% for n=1:nRxn
%     if changedDirections.forward2Reversible(n)
%         ind=find(model.S(:,n));
%         %finds the reactions with changed direction, exclusively involving
%         %metabolites with dGf0 back calculated from keq
%         if sum(dGft0SourceKeqBool(ind))==length(ind)
%             forward2ReversibleKeq(n)=1;
%         end
%     end
% end
%
% fprintf(fid,'\n');
% for n=1:nRxn
%     if forward2ReversibleKeq(n)
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
% allLooserMetSum=sum(abs(model.S(:,forward2ReversibleKeq)),2);
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
% if max(forward2Reversible)==1
%     Sforward2Reversible=model.S(:,forward2Reversible);
%     forward2ReversibleMet=zeros(nMet,1);
%     for m=1:nMet
%         forward2ReversibleMet(m,1)=nnz(Sforward2Reversible(m,:));
%     end
%     %print out the culprits in order of worst offender
%     [sorted,sInd]=sort(forward2ReversibleMet,'descend');
%     p=1;
%     fprintf(fid,'%s\n',['Metabolites which allow ' int2str(nnz(forward2Reversible)) ' forward reactions to be reversible:']);
%     while forward2ReversibleMet(sInd(p))>0
%         if ~strcmp(model.met(sInd(p)).dGft0Source,'Keq')
%             dataSource='gc';
%         else
%             dataSource='Keq';
%         end
%         fprintf(fid,'%u%s\t%u\t%s\t%20s\t%s\n',sInd(p),':',forward2ReversibleMet(sInd(p)),dataSource,model.met(sInd(p)).abbreviation,model.met(sInd(p)).officialName);
%         p=p+1;
%     end
%     fprintf(fid,'\n');
%     fprintf(fid,'\n');
%
%     %print out for each problematic reaction
%     for n=1:nRxn
%         if forward2Reversible(n)==1
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
