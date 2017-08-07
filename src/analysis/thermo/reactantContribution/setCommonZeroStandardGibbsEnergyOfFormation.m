function model = setCommonZeroStandardGibbsEnergyOfFormation(model, adjustedMetList)
% Sets all Alberty's cofactor metabolites to have a common thermodynamic baseline.
%
% Sets all the exceptional metabolites to have a common baseline.
% i.e. Standard transformed Gibbs energies of reactants with the baseline adjusted
% for certain paired cofactors e.g. `fad` & `fadh2`, such that the
% difference between the two is the same as in Albertys data but
% the absolute values are consistent with the group contribution data
%
% USAGE:
%
%    model = setCommonZeroStandardGibbsEnergyOfFormation(model, adjustedMetList)
%
% INPUT:
%    model:              Thermodynamic model:
%
%                          * .met(m).dGft0 - standard transformed Gibbs energy of formation(kJ/mol)
%                          * .met(m).dGft0Keq - standard transformed Gibbs energy of formation(kJ/mol)
%                          * .met(m).dGft0Source - origin of data, `Keq` or `groupContFileName.txt`
%                          * .met(m).dGft0GroupCont - group. cont. estimate of standard transformed Gibbs energy of formation(kJ/mol)
%
% OPTIONAL INPUT:
%    adjustedMetList:
% OUTPUT:
%    model:              structure with field:
%
%                          * .met(m).dGft0 - Standard transformed Gibbs energies of reactants
%                            with the baseline adjusted for certain paired
%                            cofactors e.g. `fad` & `fadh2`, such that the
%                            difference between the two is the same as in
%                            Albertys data but the absolute values are
%                            consistent with the group contribution data
%
% .. Author: - Ronan M.T. Fleming
%
% .. Here is the list of cofactors in iAF1260 that have thermodynamic
%    properties backcalculated from Equilibrium values by Alberty
%    The compartments here are important since the same reactant in different
%    compartments may have different properties.

if ~exist('adjustedMetList','var')
%This list of cofactors contains metabolites with own baselines reported
%by Alberty in his 2006 book, plus some metabolites that appear on the
%other side of a reaction from Alberty's set. It is important to keep an
%eye on the latter as they must all be on a common baseline when the
%adjustment is done.
adjustedMetList={'coa','aacoa','accoa','ppcoa','mmcoa_R','mmcoa-R',...
    'succoa','gthrd','gthox','q8h2','q8','fmn','fmnh2','nad',...
    'nadh','nmn','fad','fadh2','nadp','nadph','malcoa'};
end

numChar=1;
[allMetCompartments,uniqueCompartments]=getCompartment(model.mets,numChar);

for p=1:length(uniqueCompartments)

    n=1;
    leftAll{n}=['fad' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['fadh2' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['q8' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['q8h2' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['nad' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['nadh' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['nad' '[' uniqueCompartments{p} ']']; % it is essential that the nad nmn pair are in this position
    rightAll{n}=['nmn' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['nadp' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['nadph' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['gthox' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['gthrd' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['fmn' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['fmnh2' '[' uniqueCompartments{p} ']'];
    n=n+1;
    %here is the list of cofactors in E. coli which are covered by Albertys data
    %see:
    %Standard transformed Gibbs energies of coenzyme A derivatives as
    %functions of pH and ionic strength
    %R.A. Alberty / Biophysical Chemistry 104 (2003) 327�334
    coAset={['coa[' uniqueCompartments{p} ']'],...
            ['aacoa[' uniqueCompartments{p} ']'],...
            ['accoa[' uniqueCompartments{p} ']'],...
            ['mmcoa-R[' uniqueCompartments{p} ']'],...
            ['mmcoa-S[' uniqueCompartments{p} ']'],...
            ['ppcoa[' uniqueCompartments{p} ']'],...
            ['succoa[' uniqueCompartments{p} ']'],...
            ['malcoa[' uniqueCompartments{p} ']']};
    leftAll{n}=[];n=n+1;
    leftAll{n}=['ppcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['succoa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['ppcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['mmcoa-S' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['ppcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['coa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=[];n=n+1;
    leftAll{n}=['succoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['coa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['succoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['mmcoa-R' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['malcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['coa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['malcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['accoa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=[];n=n+1;
    leftAll{n}=['dpcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['coa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['dpcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['2tpr3dpcoa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['dpcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['pan4p' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=[];n=n+1;
    leftAll{n}=['sbzcoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['coa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['aacoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['coa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    % Note this reaction that contains three cofactors:
    % KAT1, 3-ketoacyl-CoA thiolase [c] : aacoa + coa --> (2) accoa
    leftAll{n}=['accoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['coa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    leftAll{n}=['accoa' '[' uniqueCompartments{p} ']'];
    rightAll{n}=['aacoa' '[' uniqueCompartments{p} ']'];
    n=n+1;
    %check 'mmcoa-R'
    % methylmalonyl-CoA epimerase
    % equation:	[c] : mmcoa-R <==> mmcoa-S

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [nMet,nRxn]=size(model.S);

    exceptionMetBool=false(nMet,1);
    for m=1:nMet
        abbr=model.mets{m};
        abbr=abbr(1:end-3);
        if any(strcmp(abbr,adjustedMetList))
            exceptionMetBool(m)=1;
        end
    end
    fprintf('\n%s\n%s\n','Setting certain Alberty reactants to have a common thermodynamic',...
        'baseline so that this data can be incorporated with group contribution data.')
    fprintf('%s\n','Before baseline edit of Cofactors:')
    fprintf('%s\n','Metabolite properties:')
    %print out exceptional metabolite data before edit to baseline
    fprintf('%10s\t%20s\t%s\t\t%s\t\t%s\n','abbr','albertyAbbr','dGft0Keq','dGft0gc','dGft0');
    for m=1:nMet
        if exceptionMetBool(m)
            fprintf('%10s\t%20s\t%8.4g\t\t%8.4g\t\t%8.4g\n',model.mets{m},model.met(m).albertyAbbreviation,model.met(m).dGft0Keq,model.met(m).dGft0GroupCont,model.met(m).dGft0);
        end
    end
    fprintf('\n\n')

    fprintf('\n\n');
    fprintf('%s\n','Differences between pairs of cofactors (cytoplasm only):')
    fprintf('%22s%10s%10s%10s%10s%10s%16s%16s\n','left-right','#RxnLeft','#RxnRight','#Both','#LNotR','#RNotL','dGtr0Keq','dGrt0');
    for x=1:length(leftAll)
        abbrL=leftAll{x};
        abbrL=[abbrL(1:end-3) '[c]'];
        abbrR=rightAll{x};
        abbrR=[abbrR(1:end-3) '[c]'];

        nCoFcLRxn=length(find(model.S(strcmp(model.mets,abbrL),:)~=0));
        nCoFcRRxn=length(find(model.S(strcmp(model.mets,abbrR),:)~=0));
        nCoFc2Rxn=length(intersect(find(model.S(strcmp(model.mets,abbrL),:)~=0),find(model.S(strcmp(model.mets,abbrR),:)~=0)));
        nCoLeftOnly=length(setdiff(find(model.S(strcmp(model.mets,abbrL),:)~=0),find(model.S(strcmp(model.mets,abbrR),:)~=0)));
        nCoRightOnly=length(setdiff(find(model.S(strcmp(model.mets,abbrR),:)~=0),find(model.S(strcmp(model.mets,abbrL),:)~=0)));

        %nothing to print out if no match
        if any(strcmp(model.mets,abbrL))  && any(strcmp(model.mets,abbrR))
            fprintf('%22s%10i%10i%10i%10i%10i\t%8.4g\t%8.4g\n',[abbrL '-' abbrR],nCoFcLRxn,nCoFcRRxn,nCoFc2Rxn,nCoLeftOnly,nCoRightOnly,...
                model.met(strcmp(model.mets,abbrL)).dGft0Keq-model.met(strcmp(model.mets,abbrR)).dGft0Keq,...
                model.met(strcmp(model.mets,abbrL)).dGft0-model.met(strcmp(model.mets,abbrR)).dGft0);
        end
    end

%     fprintf('%s\n','Differences between pairs of cofactors:')
%     fprintf('%20s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','left-right','#RxnLeft','#RxnRight','#Both','#LNotR','#RNotL','dGt0Keq','dGt0gc');
%     xx=0;
%     for x=1:length(leftAll)
%         if isempty(leftAll{x})
%             %         fprintf('\n');
%         else
%             nCoFcLRxn=length(find(model.S(strcmp(model.mets,leftAll{x}),:)~=0));
%             nCoFcRRxn=length(find(model.S(strcmp(model.mets,rightAll{x}),:)~=0));
%             nCoFc2Rxn=length(intersect(find(model.S(strcmp(model.mets,leftAll{x}),:)~=0),find(model.S(strcmp(model.mets,rightAll{x}),:)~=0)));
%             nCoLeftOnly=length(setdiff(find(model.S(strcmp(model.mets,leftAll{x}),:)~=0),find(model.S(strcmp(model.mets,rightAll{x}),:)~=0)));
%             nCoRightOnly=length(setdiff(find(model.S(strcmp(model.mets,rightAll{x}),:)~=0),find(model.S(strcmp(model.mets,leftAll{x}),:)~=0)));
%
%             %nothing to print out if no match
%             if any(strcmp(model.mets,leftAll{x}))  && any(strcmp(model.mets,rightAll{x}))
%                 fprintf('%20s\t\t%i\t\t\t%i\t\t%i\t\t%i\t\t%i\t\t%8.4g\t\t%8.4g\n',[leftAll{x} '-' rightAll{x}],nCoFcLRxn,nCoFcRRxn,nCoFc2Rxn,nCoLeftOnly,nCoRightOnly,...
%                     model.met(strcmp(model.mets,leftAll{x})).dGft0Keq-model.met(strcmp(model.mets,rightAll{x})).dGft0Keq,...
%                     model.met(strcmp(model.mets,leftAll{x})).dGft0GroupCont-model.met(strcmp(model.mets,rightAll{x})).dGft0GroupCont);
%             end
%             a=1;
%         end
%     end

    %edit the baseline of a cofactor that is not always used in a pair
    %with another cofactor
    coaSorted=0;
    x=1;
    while x<=length(leftAll)
         abbrL=leftAll{x};
         abbrR=rightAll{x};

        pause(eps)
        if strcmp('coa[c]',abbrR)
            pause(eps)
        end
        %check that both left and right cofactors are always used in the network
        %together because there is no need to change if they are always used
        %together on different sides of the reaction
        if any(strcmp(abbrL,model.mets)) && any(strcmp(abbrR,model.mets))
            %check if coa is involved since coa is a special case that is not a
            %simple cofactor pair
            if ~(any(strcmp(abbrL,coAset) | any(strcmp(abbrR,coAset))))
                nCoLeftOnly=length(setdiff(find(model.S(strcmp(model.mets,abbrL),:)~=0),find(model.S(strcmp(model.mets,abbrR),:)~=0)));
                nCoRightOnly=length(setdiff(find(model.S(strcmp(model.mets,abbrR),:)~=0),find(model.S(strcmp(model.mets,abbrL),:)~=0)));
                %identify which one in each cofactor pair is synthesised/used in
                %another reaction, besides just being used in reactions with its
                %paired cofactor
                if nCoLeftOnly==0 && nCoRightOnly~=0
                    %calculate the difference between the group contribution
                    %estimate and Albertys value
                    baseLineChange=model.met(strcmp(model.mets,abbrR)).dGft0GroupCont-model.met(strcmp(model.mets,abbrR)).dGft0Keq;
                    for m=1:nMet
                        abbr=model.mets{m};
                        if any(strcmp(model.mets{m},{abbrL,abbrR}))
                            %only change if we are using Albertys data
                            if strcmp(model.met(m).dGft0Source,'Keq')
                                model.met(m).dGft0=model.met(m).dGft0+baseLineChange;
                            end
                        end
                    end
                end

                if nCoLeftOnly~=0 && nCoRightOnly==0
                    %calculate the difference between the group contribution
                    %estimate and Albertys value for the left cofactor
                    baseLineChange=model.met(strcmp(model.mets,abbrL)).dGft0GroupCont-model.met(strcmp(model.mets,abbrL)).dGft0Keq;
                    for m=1:nMet
                        if any(strcmp(model.mets{m},{abbrL,abbrR})) % change baseline for both cofactors
                            %only change if we are using Albertys data
                            if strcmp(model.met(m).dGft0Source,'Keq')
                                model.met(m).dGft0=model.met(m).dGft0+baseLineChange;
                            end
                        end
                    end
                    if strcmp(abbrL,['nad' '[' uniqueCompartments{p} ']']) && strcmp(abbrR,['nadh' '[' uniqueCompartments{p} ']']) && any(strcmp(model.mets,['nmn' '[' uniqueCompartments{p} ']'] ))
                        fprintf('%s\n',['Assuming Albertys value for nmn is set to nad baseline']);
                        for m=1:nMet
                            if any(strcmp(model.mets{m},['nmn' '[' uniqueCompartments{p} ']']))
                                %only change if we are using Albertys data
                                if strcmp(model.met(m).dGft0Source,'Keq')
                                    model.met(m).dGft0=model.met(m).dGft0+baseLineChange;
                                end
                            end
                        end
                        %ensure that nad baseline is not changed twice due to nad also
                        %appearing as a cofactor with nmn
                        %skip the next pair as it is nad[c] & nmn[c]
                        x=x+1;
                    end
                end

            else
                %for the cofactors associated with coa by Alberty, then set coA to
                %have the same baseline as the group contribution data
                if coaSorted==0
                    pause(eps)
                    for s=1:length(coAset)
                        %Changed to make suitable for multiple compartments May 24th 2011
                        baseLineChange=model.met(strcmp(model.mets,['coa[' uniqueCompartments{p} ']'])).dGft0GroupCont-model.met(strcmp(model.mets,['coa[' uniqueCompartments{p} ']'])).dGft0Keq;
                        for m=1:nMet
                            if strcmp(coAset{s},model.mets{m})
                                %only change if we are using Albertys data
                                if strcmp(model.met(m).dGft0Source,'Keq')
                                    model.met(m).dGft0=model.met(m).dGft0+baseLineChange;
                                end
                            end
                        end
                    end
                    coaSorted=1;
                end
            end
        end
        x=x+1;
    end
    %compartment by compartment
    coASorted=0;
end

fprintf('\n\n')
fprintf('%s\n','After baseline edit of Cofactors:')
fprintf('%s\n','Metabolite properties:')
fprintf('%10s\t%30s\t%s\t%s\t%s\n','abbr','albertyAbbr','dGft0Keq',' dGft0gc','   dGft0');
%print out the new changes
for m=1:nMet
    if strcmp('nad[c]',model.mets{m})
        pause(eps)
    end
    if exceptionMetBool(m)
        fprintf('%10s\t%30s\t%8.4g\t%8.4g\t%8.4g\n',model.mets{m},model.met(m).albertyAbbreviation,model.met(m).dGft0Keq,model.met(m).dGft0GroupCont,model.met(m).dGft0);
    end
end

fprintf('\n\n');
fprintf('%s\n','Differences between pairs of cofactors, after baseline edit (cytoplasm only):')
fprintf('%22s%10s%10s%10s%10s%10s%16s%16s\n','left-right','#RxnLeft','#RxnRight','#Both','#LNotR','#RNotL','dGtr0Keq','dGrt0');
for x=1:length(leftAll)
    abbrL=leftAll{x};
    abbrL=[abbrL(1:end-3) '[c]'];
    abbrR=rightAll{x};
    abbrR=[abbrR(1:end-3) '[c]'];

    nCoFcLRxn=length(find(model.S(strcmp(model.mets,abbrL),:)~=0));
    nCoFcRRxn=length(find(model.S(strcmp(model.mets,abbrR),:)~=0));
    nCoFc2Rxn=length(intersect(find(model.S(strcmp(model.mets,abbrL),:)~=0),find(model.S(strcmp(model.mets,abbrR),:)~=0)));
    nCoLeftOnly=length(setdiff(find(model.S(strcmp(model.mets,abbrL),:)~=0),find(model.S(strcmp(model.mets,abbrR),:)~=0)));
    nCoRightOnly=length(setdiff(find(model.S(strcmp(model.mets,abbrR),:)~=0),find(model.S(strcmp(model.mets,abbrL),:)~=0)));

    %nothing to print out if no match
    if any(strcmp(model.mets,abbrL))  && any(strcmp(model.mets,abbrR))
        fprintf('%22s%10i%10i%10i%10i%10i\t%8.4g\t%8.4g\n',[abbrL '-' abbrR],nCoFcLRxn,nCoFcRRxn,nCoFc2Rxn,nCoLeftOnly,nCoRightOnly,...
            model.met(strcmp(model.mets,abbrL)).dGft0Keq-model.met(strcmp(model.mets,abbrR)).dGft0Keq,...
            model.met(strcmp(model.mets,abbrL)).dGft0-model.met(strcmp(model.mets,abbrR)).dGft0);
    end
end


%OLD CODE -may still be usefull for looking at nullspace of internal
%reactions that are also involve cofactors
% if ~exist('exceptions','var')
%     exceptions={'coa','aacoa','accoa','ppcoa','mmcoa_R','mmcoa-R',...
%         'succoa','gthrd','gthox','q8h2','q8','fmn','fmnh2','nad',...
%         'nadh','fad','fadh2','nadp','nadph','malcoa'};
% end
%
%
% [nMet,nRxn]=size(model.S);
%
% if ~isfield(model,'biomassRxnAbbr')
%     if ~exist('biomassRxnAbbr')
%         fprintf('\n%s\n','...checkObjective');
%         objectiveAbbr=checkObjective(model);
%         fprintf('%s\n',['Asumming objective is ' objectiveAbbr]);
%         model.biomassRxnAbbr=objectiveAbbr;
%     else
%         model.biomassRxnAbbr=biomassRxnAbbr;
%     end
% end
%
% %finds the reactions in the model which export/import from the model
% %boundary
% %e.g. Exchange reactions
% %     Demand reactions
% %     Sink reactions
% model=findSExRxnInd(model);
% %OUTPUT
% % model.SIntRxnInd          indices of internal reactions
% % model.SExRxnInd           indices of boundary reactions
% intRxnBool=false(1,nRxn);
% intRxnBool(model.SIntRxnInd)=1;
%

%
% %extract subnetwork
% modelE=model;
% %reactions
% exceptionRxnBool=logical(sign(sum(abs(model.S(exceptionMetBool,:)),1)));
% %only keep internal reactions involving exceptional metabolites
% modelE.S=modelE.S(:,exceptionRxnBool & intRxnBool);
% modelE.rxns=modelE.rxns(exceptionRxnBool & intRxnBool);
% modelE.lb=modelE.lb(exceptionRxnBool & intRxnBool);
% modelE.ub=modelE.ub(exceptionRxnBool & intRxnBool);
% %metabolites
% keepMetBool=false(nMet,1);
% for m=1:nMet
%     if nnz(modelE.S(m,:))~=0
%         keepMetBool(m,1)=1;
%     end
% end
% modelE.S=modelE.S(keepMetBool,:);
% modelE.mets=modelE.mets(keepMetBool);
%
% exceptionMetBool=false(nMet,1);
% for m=1:nMet
%     abbr=model.mets{m};
%     if any(strcmp(abbr(end-2:end),'[c]'))
%         abbr=abbr(1:end-3);
%         if any(strcmp(abbr,exceptions))
%             exceptionMetBool(m)=1;
%         end
%     end
% end
