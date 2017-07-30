function [modelD, solutionThermoRecon, solutionRecon, model1] = setThermoReactionDirectionalityiAF1260(model, maxFlux, hardCoupleOxPhos)
% Second pass assignment of reaction directionality (E. coli specific)
%
% Set the upper and lower bounds for each internal flux based on
% thermodynamic data where available. The remainder of the reactions without
% thermodynamic data stay as they were in the reconstruction
% To apply this script to a particular stoichiometric model, one would have
% to modify it manually. At the moment, it is specfic to E. coli. The same
% manual adjustment of reaction directionality made here to get the model to
% grow, and grow at the rate seen in vivo, may not work for other organisms.
% Nevertheless, this script outlines the steps needed to identify what needs
% to be changed to get a model to grow and then to get it to grow at the
% correct rate. There is currently no automatic substitution for manual curation.
%
% USAGE:
%
%     [modelD, solutionThermoRecon, solutionRecon, model1] = setThermoReactionDirectionalityiAF1260(model, maxFlux, hardCoupleOxPhos)
%
% INPUT:
%    model:                  structure with fields:
%
%                              * model.NaNdG0RxnBool - reactions with NaN Gibbs Energy
%                              * model.transportRxnBool - transport reactions
%                              * model.directions: Reactions that are qualitatively assigned by thermodynamics:
%
%                                * directions.fwdThermoOnlyBool
%                                * directions.revThermoOnlyBool
%                                * directions.reversibleThermoOnlyBool
%
%                                subsets of forward qualtiative -> reversible quantiative change:
%
%                                * directions.ChangeForwardReversible_dGfKeq
%                                * directions.ChangeForwardReversibleBool_dGfGC
%                                * directions.ChangeForwardReversibleBool_dGfGC_byConcLHS
%                                * directions.ChangeForwardReversibleBool_dGfGC_byConcRHS
%                                * directions.ChangeForwardReversibleBool_dGfGC_bydGt0
%                                * directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS
%                                * directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid
%                                * directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS
%                                * directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS
%                                * directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS
%
% OUTPUTS:
%    model:                  structure with fields:
%
%                              * model.lb_reconThermo - lower bound
%                              * model.ub_reconThermo - upper bound
%    solutionThermoRecon:    FBA with thermodynamic in preference to
%                            reconstruction directions, with exceptions
%                            specific to E. coli given below
%    solutionRecon:          FBA with reconstruction direction
%
% .. Author: - Ronan M. T. Fleming

if ~exist('maxFlux','var')
    maxFlux=1000;
end

if ~exist('hardCoupleOxPhos','var')
    hardCoupleOxPhos=0;
end
directions=model.directions;
if nnz(directions.fwdThermoOnlyBool & directions.revThermoOnlyBool & directions.reversibleThermoOnlyBool)~=0
    error('Thermodynamically forward, reverse and reversible must be mutually exclusive')
end

changeOK = changeCobraSolverParams('LP','printLevel',0);
changeOK = changeCobraSolverParams('LP','minNorm',0);

%bypass changes to the model when used in setupThermoModel, such that
%setThermoReactionDirectionality can be debugged.
model1=model;

%test if modelD can grow with reconstruction directions
printLevel=0;
global CBTLPSOLVER
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    conflictResolve=0;
    contFunctName=[];
    minNorm=1e-6;
    [solutionRecon,model]=solveCobraLPCPLEX(model,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
else
    solutionRecon = optimizeCbModel(model);
end
fprintf('\n%s\t%g\n','Growth with reconstruction directions: ',solutionRecon.f);

%manipulate reaction directionality of a duplicate: modelD
modelD=model;

%reaction directionality
%keep exchange bounds the same as for the reconstruction
modelD.lb_reconThermo=modelD.lb;
modelD.ub_reconThermo=modelD.ub;

%this makes this extra condition ineffective, the idea was to assign
%direction also based on where mean dG0 was, but its tricky and cant easily
%be justified so for now, it is left out.
dGt0MeanCutoff=Inf;

[nMet,nRxn]=size(modelD.S);
%now set internal reaction directions
for n=1:nRxn
%     if strcmp('SUCOAS',modelD.rxns{n})
%         pause(0.01)
%     end
    if modelD.SIntRxnBool(n)
        free=1;
        if modelD.NaNdG0RxnBool(n)
            %for the reactions that involve a NaN metabolite standard Gibbs energy of
            %formation, use the directions given by the reconstruction
            if modelD.lb(n)<0 && modelD.ub(n)>0 && free
                modelD.lb_reconThermo(n)=-maxFlux;
                modelD.ub_reconThermo(n)=maxFlux;
                free=0;
            end
            if modelD.lb(n)>=0 && modelD.ub(n)>0 && free
                modelD.lb_reconThermo(n)=0;
                modelD.ub_reconThermo(n)=maxFlux;
                free=0;
            end
            if modelD.lb(n)<0 && modelD.ub(n)<=0 && free
                modelD.lb_reconThermo(n)=-maxFlux;
                modelD.ub_reconThermo(n)=0;
                %                 free=0;
            end
            if 0
                if modelD.lb(n)==0 && modelD.ub(n)==0
                    error(['Reaction ' modelD.rxns{n} ' set to zero. Why?'])
                end
            end
            %note that there is no thermodynamic directionality assignment
            %for this reaction
            modelD.rxn(n).directionalityThermo=NaN;
        else
            %first set them all to be reversible
            modelD.rxn(n).directionalityThermo='reversible';
            modelD.lb_reconThermo(n)=-maxFlux;
            modelD.ub_reconThermo(n)=maxFlux;
            yyyy=1;
            % reactions that are qualitatively assigned by thermodynamics
            if directions.fwdThermoOnlyBool(n) && free && yyyy
                modelD.rxn(n).directionalityThermo='forward';
                modelD.lb_reconThermo(n)=0;
                modelD.ub_reconThermo(n)=maxFlux;
                free=0;
            end
            if directions.revThermoOnlyBool(n) && free && yyyy
                modelD.rxn(n).directionalityThermo='reverse';
                modelD.lb_reconThermo(n)=-maxFlux;
                modelD.ub_reconThermo(n)=0;
                free=0;
            end
            yyyy=1;
            if yyyy
                if directions.reversibleThermoOnlyBool(n) && free
                    %thermodynamic assignments from Albertys data
                    if directions.ChangeForwardReversible_dGfKeq(n) && free
                        if ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)<=-dGt0MeanCutoff && free
                            modelD.rxn(n).directionalityThermo='forward';
                            modelD.lb_reconThermo(n)=0;
                            modelD.ub_reconThermo(n)=maxFlux;
                            free=0;
                        end
                        if ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)>=dGt0MeanCutoff && free
                            modelD.rxn(n).directionalityThermo='reverse';
                            modelD.lb_reconThermo(n)=-maxFlux;
                            modelD.ub_reconThermo(n)=0;
                            free=0;
                        end
                        if ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)>-dGt0MeanCutoff && ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)<dGt0MeanCutoff && free
                            modelD.rxn(n).directionalityThermo='reversible';
                            modelD.lb_reconThermo(n)=-maxFlux;
                            modelD.ub_reconThermo(n)=maxFlux;
                            free=0;
                        end
                    end
                    %thermodynamic assignments from reactions with at least
                    %one metabolite with dGft0 from group contribution data
                    if directions.ChangeForwardReversibleBool_dGfGC(n) && free
                        if directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorLHS(n) && free
                            modelD.rxn(n).directionalityThermo='forward';
                            modelD.lb_reconThermo(n)=0;
                            modelD.ub_reconThermo(n)=maxFlux;
                            free=0;
                            %                             if ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)<=-dGt0MeanCutoff && free
                            %                                 modelD.rxn(n).directionalityThermo='forward';
                            %                                 modelD.lb_reconThermo(n)=0;
                            %                                 modelD.ub_reconThermo(n)=maxFlux;
                            %                                 free=0;
                            %                             else
                            %                                 modelD.rxn(n).directionalityThermo='reversible';
                            %                                 modelD.lb_reconThermo(n)=-maxFlux;
                            %                                 modelD.ub_reconThermo(n)=maxFlux;
                            %                                 free=0;
                            %                             end
                        end
                        if directions.ChangeForwardReversibleBool_dGfGC_byConcLHS(n) || directions.ChangeForwardReversibleBool_dGfGC_bydGt0LHS(n) && free
                            modelD.rxn(n).directionalityThermo='forward';
                            modelD.lb_reconThermo(n)=0;
                            modelD.ub_reconThermo(n)=maxFlux;
                            free=0;
                        end
                        %
                        if directions.ChangeForwardReversibleBool_dGfGC_bydGt0Mid(n)
                            %too much error in estimates, or too evenly
                            %spread about zero to make an assignment either
                            %way
                            modelD.rxn(n).directionalityThermo='reversible';
                            modelD.lb_reconThermo(n)=-maxFlux;
                            modelD.ub_reconThermo(n)=maxFlux;
                            free=0;
                        end
                        if directions.ChangeForwardReversibleBool_dGfGC_byConcRHS(n)&& free
                            if ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)>=dGt0MeanCutoff && free
                                modelD.rxn(n).directionalityThermo='reverse';
                                modelD.lb_reconThermo(n)=-maxFlux;
                                modelD.ub_reconThermo(n)=0;
                                free=0;
                            else
                                modelD.rxn(n).directionalityThermo='reversible';
                                modelD.lb_reconThermo(n)=-maxFlux;
                                modelD.ub_reconThermo(n)=maxFlux;
                                free=0;
                            end
                        end
                        if directions.ChangeForwardReversibleBool_dGfGC_bydGt0RHS(n) && free
                            if ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)>=dGt0MeanCutoff && free
                                modelD.rxn(n).directionalityThermo='reverse';
                                modelD.lb_reconThermo(n)=-maxFlux;
                                modelD.ub_reconThermo(n)=0;
                                free=0;
                            else
                                modelD.rxn(n).directionalityThermo='reversible';
                                modelD.lb_reconThermo(n)=-maxFlux;
                                modelD.ub_reconThermo(n)=maxFlux;
                                free=0;
                            end
                        end
                        if directions.ChangeForwardReversibleBool_dGfGC_byConc_No_dGt0ErrorRHS(n) && free
                            if ((modelD.rxn(n).dGt0Min+modelD.rxn(n).dGt0Max)/2)>=dGt0MeanCutoff && free
                                modelD.rxn(n).directionalityThermo='reverse';
                                modelD.lb_reconThermo(n)=-maxFlux;
                                modelD.ub_reconThermo(n)=0;
                                %                             free=0;
                            else
                                modelD.rxn(n).directionalityThermo='reversible';
                                modelD.lb_reconThermo(n)=-maxFlux;
                                modelD.ub_reconThermo(n)=maxFlux;
                                %                             free=0;
                            end
                        end
                    end
                end
            end

            if modelD.lb_reconThermo(n)==0 && modelD.ub_reconThermo(n)==0
                error(['Reaction ' modelD.rxns{n} ' set to zero. Why?'])
            end
        end
    end
end


%test if modelD can grow with thermodynamically assigned directions
modelD.lb=modelD.lb_reconThermo;
modelD.ub=modelD.ub_reconThermo;
%
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    conflictResolve=0;
    contFunctName=[];
    minNorm=1e-6;
    [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
else
    solution = optimizeCbModel(modelD);
end
fprintf('\n%s\t%g\n','Growth with thermo & recon directions: ',solution.f);

%reset the reconstruction directions
modelD.lb=model.lb;
modelD.ub=model.ub;


if abs(solution.f)<abs(solutionRecon.f/10) || solution.origStat~=1

    thermoForwardNeededReverseBool=false(nRxn,1);
    thermoReverseNeededForwardBool=false(nRxn,1);

    fprintf('\n%s\n%s\n', 'Checking for reaction directions in the optimal reconstruction FBA',...
        'that might possibly conflict with the directions set by thermodynamics...');

    rt=modelD.gasConstant*modelD.temp;
    %find the directions of the optimal solution that might possibly conflict
    %with the directions set by thermodynamics in preference to the
    %reconstruction directions
    v=solutionRecon.x;
    minV=0.001;
    fprintf('%s\n', ['Assuming any flux with magnitude less than ' num2str(minV) ' is zero']);
    v(abs(v)<minV)=0;
    for n=1:nRxn
        if sign(v(n))==1 && strcmp(modelD.rxn(n).directionalityThermo,'reverse')
            thermoReverseNeededForwardBool(n)=1;
            fprintf('%s\n','Thermodynamically reverse reaction that may be needed in a forward direction')
            fprintf('%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax,'substrates:');
            sInd=find(modelD.S(:,n)<0);
            for p=1:length(sInd)
                fprintf('%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),modelD.S(sInd(p),n),modelD.met(sInd(p)).dGft0,rt*log(modelD.met(sInd(p)).concMin),rt*log(modelD.met(sInd(p)).concMax),modelD.met(sInd(p)).abbreviation,modelD.met(sInd(p)).officialName);
            end
            fprintf('%s\n','products:');
            pInd=find(modelD.S(:,n)>0);
            for p=1:length(pInd)
                fprintf('%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),modelD.S(pInd(p),n),modelD.met(pInd(p)).dGft0,rt*log(modelD.met(pInd(p)).concMin),rt*log(modelD.met(pInd(p)).concMax),modelD.met(pInd(p)).abbreviation,modelD.met(pInd(p)).officialName);
            end
            fprintf('\n');
        end
        if sign(v(n))==-1 && strcmp(modelD.rxn(n).directionalityThermo,'forward')
            thermoForwardNeededReverseBool(n)=1;
            fprintf('%s\n','Thermodynamically forward reaction that may be needed in a reverse direction:')
            fprintf('%i\t%s\t%s\t%6.2f\t%6.2f\n%s\n',n,modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax,'substrates:');
            sInd=find(modelD.S(:,n)<0);
            for p=1:length(sInd)
                fprintf('%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',sInd(p),modelD.S(sInd(p),n),modelD.met(sInd(p)).dGft0,rt*log(modelD.met(sInd(p)).concMin),rt*log(modelD.met(sInd(p)).concMax),modelD.met(sInd(p)).abbreviation,modelD.met(sInd(p)).officialName);
            end
            fprintf('%s\n','products:');
            pInd=find(modelD.S(:,n)>0);
            for p=1:length(pInd)
                fprintf('%i\t%8g\t%8.2f\t%6.2f\t%6.2f\t%20s\t%s\n',pInd(p),modelD.S(pInd(p),n),modelD.met(pInd(p)).dGft0,rt*log(modelD.met(pInd(p)).concMin),rt*log(modelD.met(pInd(p)).concMax),modelD.met(pInd(p)).abbreviation,modelD.met(pInd(p)).officialName);
            end
            fprintf('\n');
        end
    end

    runThrough=0;
    %run through each of the possible changes one by one to see which one
    %is stoping the modelD from growing
    if runThrough
        for n=1:nRxn
            if thermoReverseNeededForwardBool(n) || thermoForwardNeededReverseBool(n)
                modelD.lb=modelD.lb_reconThermo;
                modelD.ub=modelD.ub_reconThermo;
                if thermoForwardNeededReverseBool(n)
                    modelD.lb(n)=-maxFlux;
                    modelD.ub(n)=0;
                else
                    modelD.lb(n)=0;
                    modelD.ub(n)=maxFlux;
                end

                %test if modelD can grow
                if strcmp(CBTLPSOLVER,'cplex_direct')
                    basisReuse=0;
                    conflictResolve=0;
                    contFunctName=[];
                    minNorm=1e-6;
                    [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
                else



                    solution = optimzeCbModel(modelD);

                end
                fprintf('%s%70s%s%g\n','Changed ' , modelD.rxn(n).officialName,'. Growth: ',solution.f);
            end
        end
        fprintf('\n');

        %run through each of the possible changes adding one by one to see which one
        %is stoping the modelD from growing
        modelD.lb=modelD.lb_reconThermo;
        modelD.ub=modelD.ub_reconThermo;
        for n=1:nRxn
            if thermoReverseNeededForwardBool(n) || thermoForwardNeededReverseBool(n)

                if thermoForwardNeededReverseBool(n)
                    modelD.lb(n)=-maxFlux;
                    modelD.ub(n)=0;
                else
                    modelD.lb(n)=0;
                    modelD.ub(n)=maxFlux;
                end

                %test if modelD can grow
                if strcmp(CBTLPSOLVER,'cplex_direct')
                    basisReuse=0;
                    conflictResolve=0;
                    contFunctName=[];
                    minNorm=1e-6;
                    [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
                else



                    solution = optimzeCbModel(modelD);
                    modelD=rmfield(modelD,'A');model=rmfield(modelD,'osense');
                end
                fprintf('%s%70s%s%g\n','Changed also ' , modelD.rxn(n).officialName,'. Growth: ',solution.f);
            end
        end
        fprintf('\n');
    end


    %relax all
    modelD.lb=modelD.lb_reconThermo;
    modelD.ub=modelD.ub_reconThermo;
    %     modelD.lb(thermoReverseNeededForwardBool)=-maxFlux;
    %     modelD.ub(thermoReverseNeededForwardBool)=maxFlux;
    %     modelD.lb(thermoForwardNeededReverseBool)=-maxFlux;
    %     modelD.ub(thermoForwardNeededReverseBool)=maxFlux;

    %qualitatively forward -> quantiatively reverse
    if dGt0MeanCutoff~=Inf;
        %officialName: 'histidinol phosphatase'
        %equation: 'h2o[c] + hisp[c]  -> histd[c] + pi[c] '
        modelD.lb(strcmp(modelD.rxns,'HISTP'))=0;
        modelD.ub(strcmp(modelD.rxns,'HISTP'))=maxFlux;

        %officialName: 'tetrahydrodipicolinate succinylase'
        %equation: 'h2o[c] + succoa[c] + thdp[c]  -> coa[c] + sl2a6o[c] '
        modelD.lb(strcmp(modelD.rxns,'THDPS'))=0;
        modelD.ub(strcmp(modelD.rxns,'THDPS'))=maxFlux;

        %   officialName: 'glycogen phosphorylase'
        %   equation: 'glycogen[c] + pi[c]  -> g1p[c] '
        modelD.lb(strcmp(modelD.rxns,'GLCP'))=0;
        modelD.ub(strcmp(modelD.rxns,'GLCP'))=maxFlux;

        %   officialName: 'glycogen phosphorylase'
        %   equation: 'bglycogen[c] + pi[c]  -> g1p[c] '
        modelD.lb(strcmp(modelD.rxns,'GLCP2'))=0;
        modelD.ub(strcmp(modelD.rxns,'GLCP2'))=maxFlux;
    end


    %THESE APPEAR TO BE ESSENTIAL MANUALLY CURATED DIRECTIONS
    %   officialName: 'methionine adenosyltransferase'
    %    equation: 'atp[c] + h2o[c] + met-L[c]  -> amet[c] + pi[c] + ppi[c] '
    modelD.lb(strcmp(modelD.rxns,'METAT'))=0;
    modelD.ub(strcmp(modelD.rxns,'METAT'))=maxFlux;

    %   officialName: '2 C methyl D erythritol 2 4 cyclodiphosphate synthase'
    %   equation: '2p4c2me[c]  -> 2mecdp[c] + cmp[c] '
    modelD.lb(strcmp(modelD.rxns,'MECDPS'))=0;
    modelD.ub(strcmp(modelD.rxns,'MECDPS'))=maxFlux;

    %     officialName: 'phosphoribosylaminoimidazole synthase'
    %     equation: 'atp[c] + fpram[c]  -> adp[c] + air[c] + 2 h[c] + pi[c] '
    modelD.lb(strcmp(modelD.rxns,'PRAIS'))=0;
    modelD.ub(strcmp(modelD.rxns,'PRAIS'))=maxFlux;
    modelD.rxn(n).directionalityThermo='forward';

    %   officialName: 'IMP cyclohydrolase'
    %   equation: 'h2o[c] + imp[c]  <=> fprica[c] '
    modelD.lb(strcmp(modelD.rxns,'IMPC'))=-maxFlux;
    modelD.ub(strcmp(modelD.rxns,'IMPC'))=0;

    %ATP MAINTENANCE
    %     officialName: 'ATP maintenance requirement'
    %     equation: 'atp[c] + h2o[c]  -> adp[c] + h[c] + pi[c] '
    modelD.lb(strcmp(modelD.rxns,'ATPM'))=8.39;%-0.000001;
    modelD.ub(strcmp(modelD.rxns,'ATPM'))=8.39;%+0.000001;

    % phosphate reversible transport via symport periplasm 	PIt2rpp
    modelD.lb(strcmp(modelD.rxns,'PIt2rpp'))=0;
    modelD.ub(strcmp(modelD.rxns,'PIt2rpp'))=maxFlux;


    if 1 %2011
        %   officialName: 'FMN adenylyltransferase'
        modelD.lb(strcmp(modelD.rxns,'FMNAT'))=0;
        modelD.ub(strcmp(modelD.rxns,'FMNAT'))=maxFlux;
    end

    %     for n=1:nRxn
    %         if strcmp(modelD.rxn(n).regulationStatus,'Off')
    %             modelD.lb(n)=0;
    %             modelD.ub(n)=0;
    %         end
    %     end

    %     modelD.lb(strcmp(modelD.rxns,'DUTPDP'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'NTPP8'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'RBK'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'GLYCL'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'XPPT'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'CYTDK2'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'CMPN'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'FMNRx2'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'HACD1i'))=0;
    %     %Transhydrogenase reactions which together with the transport reactions
    %     %were allowing too fast growth
    %     modelD.lb(strcmp(modelD.rxns,'THD2pp'))=0;
    %     modelD.lb(strcmp(modelD.rxns,'NADTRHD'))=0;

    %test if modelD can grow
    if strcmp(CBTLPSOLVER,'cplex_direct')
        basisReuse=0;
        conflictResolve=0;
        contFunctName=[];
        minNorm=1e-6;
        [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
    else
        solution = optimizeCbModel(modelD);
    end
    fprintf('%s%g\n','Reconstruction directions for essential reactions. Growth: ',solution.f);
end

%set thermodynamically reversible reactions to forward if high potential
%cofactors are is consumed (only for internal reactions)
for n=1:nRxn
    if modelD.SIntRxnBool(n)
        if  strcmp(modelD.rxn(n).directionalityThermo,'reversible') && strcmp(modelD.rxn(n).directionality,'forward')
% %             cofactor substrates
            if modelD.S(strcmp('atp[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('atp[p]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('atp[e]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('gtp[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('ctp[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('utp[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            %cofactor breakdown products
            if modelD.S(strcmp('ppi[c]',modelD.mets),n)>0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('pi[c]',modelD.mets),n)>0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('pi[e]',modelD.mets),n)>0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end

            if 0
            %quinones
            if modelD.S(strcmp('q8[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('q8h2[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('mqn8[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('mql8[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('2dmmql8[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('2dmmq8[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            end

            %coa
            if modelD.S(strcmp('coa[c]',modelD.mets),n)>0 && modelD.S(strcmp('h2o[c]',modelD.mets),n)<0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
            if modelD.S(strcmp('o2[c]',modelD.mets),n)<0 && modelD.S(strcmp('o2s[c]',modelD.mets),n)>0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
            end
        end
    end
end

%test if modelD can grow
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    conflictResolve=0;
    contFunctName=[];
    minNorm=1e-6;
    [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
else
    solution = optimizeCbModel(modelD);
end
fprintf('\n%s%g\n','Reactions driven by cofactors set to irreversible. Growth: ',solution.f);

%print out reactions going against reconstruction directions
fprintf('\n%s\n','Reactions still going against qualitative directions')
fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','AllTransportRecon','Equation','Reaction');
for n=1:nRxn
    if strcmp(modelD.rxn(n).directionality,'forward') && solution.x(n)<-0.1
        fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',modelD.rxns{n},solutionRecon.x(n),solution.x(n),modelD.rxn(n).equation,modelD.rxn(n).officialName);
    end
end

%oxidative phosphorylation reactions
oxPhos={'EX_o2(e)';'ATPS4rpp';'CRNBTCT';'CRNCAL2';'CRNCAR';'CRNCBCT';'CRNCDH';'CRNDCAL2';...
    'CTBTCAL2';'CYTBD2pp';'CYTBDpp';'CYTBO3_4pp';'DMSOR1';'DMSOR1pp';'DMSOR2';...
    'DMSOR2pp';'FDH4pp';'FDH5pp';'G3PD5';'G3PD6';'G3PD7';'GLCDpp';'HYD1pp';...
    'HYD2pp';'HYD3pp';'LDH_D2';'L_LACD2';'L_LACD3';'NADH10';'NADH16pp';...
    'NADH17pp';'NADH18pp';'NADH5';'NADH9';'NADPHQR2';'NADPHQR3';'NADPHQR4';...
    'NADTRHD';'NO3R1pp';'NO3R2pp';'NTRIR2x';'POX';'PPK2r';'PPKr';'QMO2';...
    'QMO3';'SUCDi';'FRD2';'FRD3';'THD2pp';'TMAOR1';'TMAOR1pp';'TMAOR2';'TMAOR2pp';'TRDR'};
fprintf('\n');
%print out oxidative phosphorylation reactions
fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','Thermo','Equation','Reaction');
for p=1:length(oxPhos)
    fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',oxPhos{p},solutionRecon.x(strcmp(oxPhos{p,1},modelD.rxns)),solution.x(strcmp(oxPhos{p,1},modelD.rxns)),modelD.rxn(strcmp(oxPhos{p,1},modelD.rxns)).equation,modelD.rxn(strcmp(oxPhos{p,1},modelD.rxns)).officialName);
end

if 0
fprintf('\n%s\n','**************************************************************')
fprintf('\n%s\n','************All transport reactions to recon directions*******')
fprintf('\n%s\n','**************************************************************')
%set all transport reaction directions to reconstruction directions
modelTransportRecon=modelD;
for n=1:nRxn
    if model.transportRxnBool(n)
        if strcmp(modelD.rxn(n).directionality,'forward')
            modelTransportRecon.lb(n)=0;
            modelTransportRecon.ub(n)=maxFlux;
            modelTransportRecon.rxn(n).directionalityThermo='forward';
        end
    end
end
%test growth rate with reconstruction directions for transport
%reactions
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    conflictResolve=0;
    contFunctName=[];
    minNorm=1e-6;
    [solutionTransportRecon,modelTransportRecon]=solveCobraLPCPLEX(modelTransportRecon,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
%     clear modelTransportRecon
else
    solutionTransportRecon = optimizeCbModel(modelTransportRecon);
%     clear modelTransportRecon
end
fprintf('\n%s%g\n','All transport reactions set to reconstruction directions. Growth: ',solution.f);

%print out reactions going against reconstruction directions
fprintf('\n%s\n','Reactions still going against qualitative directions')
fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','AllTransportRecon','Equation','Reaction');
for n=1:nRxn
    if strcmp(modelD.rxn(n).directionality,'forward') && solutionTransportRecon.x(n)<-0.1
        fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',modelD.rxns{n},solutionRecon.x(n),solutionTransportRecon.x(n),modelD.rxn(n).equation,modelD.rxn(n).officialName);
    end
end
end

if 0
%test if hard couplong ox phos with all recon transport directions can
%reduce growth rate
modelTransportReconHardC=modelTransportRecon;
if hardCoupleOxPhos
    fprintf('%s\n%s\n','Hard coupling pairs of oxidative phosphorylation reactions,','(this appends extra rows to the end of S).')
    % NDH-1:NDH-2 is 1:1 in iAF1260 flux2 (3 pairs of reactions - different quinone usage)
    %Hard couple pairs of oxidative phosphorylation  reactions
    %see supplementary material on iAF1260 Feist et al
    pair={'NADH10','NADH17pp';'NADH5','NADH16pp';'NADH9','NADH18pp'};
    [nMet,nRxn]=size(modelTransportReconHardC.S);
    for p=1:length(pair)
        modelTransportReconHardC.S(nMet+p,strcmp(modelTransportReconHardC.rxns,pair{p,1}))=1;
        modelTransportReconHardC.S(nMet+p,strcmp(modelTransportReconHardC.rxns,pair{p,2}))=-1;
        %pad out abbreviations and names
        modelTransportReconHardC.mets{nMet+p}=['coupleOxPhos' int2str(p)];
        modelTransportReconHardC.met(nMet+p).abbreviation=modelTransportReconHardC.mets{nMet+p};
        modelTransportReconHardC.met(nMet+p).officialName=['coupleOxPhos_' pair{p,1} '_' pair{p,2}];
    end
    if isfield(modelTransportReconHardC,'A')
        modelTransportReconHardC.A=modelTransportReconHardC.S;
    end
    %pad out the right hand side vector
    %S.v=b
    modelTransportReconHardC.b=[modelTransportReconHardC.b;sparse(length(pair),1)];
    modelTransportReconHardC.csense(nMet+1:nMet+length(pair))='E';
end
%test growth rate with reconstruction directions for transport reactions
%and hard coupling of oxidative phosphorylation
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    conflictResolve=0;
    contFunctName=[];
    minNorm=1e-6;
    [solutionTransportReconHardC,modelTransportReconHardC]=solveCobraLPCPLEX(modelTransportReconHardC,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
    clear modelTransportReconHardC
else
    solutionTransportReconHardC = optimizeCbModel(modelTransportReconHardC);
    clear modelTransportReconHardC
end
if hardCoupleOxPhos
    %print out the flux through the coupled pairs of oxidative
    %phosphorylation reactions
    for p=1:size(pair,1)
        fprintf('%s\t%6.4g\t\t%s\t%6.4g\n',pair{p,1},solutionTransportReconHardC.x(strcmp(pair{p,1},modelD.rxns)),pair{p,2},solutionTransportReconHardC.x(strcmp(pair{p,2},modelD.rxns)));
    end
end
fprintf('\n%s%g\n','All transport with reconstruction directions, plus hard coupling ox phos. Growth: ',solutionTransportReconHardC.f);
end

if 1
fprintf('\n%s\n','**************************************************************')
fprintf('\n%s\n','***Now only certain transport reactions to recon directions***')
fprintf('\n%s\n','**************************************************************')
%set thermodynamically reversible reactions to forward for certain
%transport reactions, only if they are qualitatively set to forward
for n=1:nRxn
    %     if strcmp('CO2tpp',modelD.rxns{n})
    %         pause(eps)
    %     end
    %model.transportRxnBool is a boolean vector which is an output
    %from deltaG0concFluxConstraintBounds
    if model.transportRxnBool(n)
        %         if strcmp(modelD.rxn(n).directionality,'forward')
        %             %recon direction applied to all
        %             %remaining transport reactions
        %             modelD.lb(n)=0;
        %             modelD.ub(n)=maxFlux;
        %             modelD.rxn(n).directionalityThermo='forward';
        %         end
        %abc transporter
        if ~isempty(strfind(modelD.rxns{n},'abc'))
            modelD.lb(n)=0;
            modelD.ub(n)=maxFlux;
            modelD.rxn(n).directionalityThermo='forward';
            %                     fprintf('\n%s\t%s\t%6.2f\t%6.2f\t%s\t%s\n',modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax, modelD.rxn(n).equation,' set to forward');
        else
            %find the other reactions which can generate atp if running
            %in reverse besides abc transportes
            if nnz(strcmp('atp[c]',modelD.mets(modelD.S(:,n)~=0)))~=0
                modelD.lb(n)=0;
                modelD.ub(n)=maxFlux;
                modelD.rxn(n).directionalityThermo='forward';
                %                         fprintf('\n%s\t%s\t%6.2f\t%6.2f\t%s\t%s\n',modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax, modelD.rxn(n).equation,' set to forward');
            else
                if 0 %%%%%%%%%%%%
                    %                 fprintf('\n%s\t%s\t%6.2f\t%6.2f\t%s\t%s\n',modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax, modelD.rxn(n).equation,'  skipped');
                    %reactions involving protons
                    if  strcmp(modelD.rxn(n).directionality,'forward')
                        if nnz(strcmp('h[c]',modelD.mets(modelD.S(:,n)~=0)))~=0 || nnz(strcmp('h[e]',modelD.mets(modelD.S(:,n)~=0)))~=0
                            modelD.lb(n)=0;
                            modelD.ub(n)=maxFlux;
                            modelD.rxn(n).directionalityThermo='forward';
                            %                             fprintf('\n%s\t%s\t%6.2f\t%6.2f\t%s\t%s\n',modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax, modelD.rxn(n).equation,' set to forward');
                        else
                            %reactions not involving protons and with more
                            %than two metabolites involved
                            if nnz(modelD.S(:,n))>2 %&& 0  %what is this doing?
                                modelD.lb(n)=-maxFlux;
                                %                         modelD.lb(n)=0;
                                modelD.ub(n)=maxFlux;
                                modelD.rxn(n).directionalityThermo='reversible';
                                %                                 fprintf('\n%s\t%s\t%6.2f\t%6.2f\t%s\t%s\n',modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax, modelD.rxn(n).equation,'  set to forward');
                            else
                                %set the remainder to forward also
                                remainderForward=0;
                                if remainderForward==1
                                    if strcmp(modelD.rxn(n).directionality,'forward')
                                        %recon direction applied to all
                                        %remaining transport reactions
                                        modelD.lb(n)=0;
                                        modelD.ub(n)=maxFlux;
                                        modelD.rxn(n).directionalityThermo='forward';
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %                 %doesnt seem to be any need to set these reactions forward
        %                 %other transport reactions
        %                 if modelD.rxn(n).dGt0Min~=modelD.rxn(n).dGt0Max
        %                     modelD.lb(n)=-maxFlux;
        %                     modelD.ub(n)=maxFlux;
        % %                     fprintf('\n%s\t%s\t%6.2f\t%6.2f\t%s\t%s\n',modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax, modelD.rxn(n).equation,' set to forward');
        %                 end
%     else
        %doesnt seem to be any need to set these forward either
        %                 if ~isempty(strfind(model.rxns{n},'pp')) && ~isempty(strfind(model.subSystems{n},'Transport'))
        % %                     error('There should be no other transport reactions than model.transportRxnBool')
        %                     fprintf('\n%s\t%s\t%6.2f\t%6.2f\t%s\t%s\n',modelD.rxn(n).officialName,modelD.rxn(n).abbreviation,modelD.rxn(n).dGtMin,modelD.rxn(n).dGtMax, modelD.rxn(n).equation,' set to forward');
        %                     modelD.lb(n)=-maxFlux;
        %                     modelD.ub(n)=maxFlux;
        %                     forwardTransportQuantReverseBool(n,1)=1;
        %                 end
    end
end
%test if modelD can grow
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    conflictResolve=0;
    contFunctName=[];
    minNorm=1e-6;
    [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
else
    solution = optimizeCbModel(modelD);
end
%print out difference between transport reactions
fprintf('\n%s\n','Difference between transport reactions')
fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','TranspRecon','Equation','Reaction');
for n=1:nRxn
    if strcmp(modelD.rxn(n).directionality,'forward') && solution.x(n)<-0.1
        fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',modelD.rxns{n},solutionRecon.x(n),solution.x(n),modelD.rxn(n).equation,modelD.rxn(n).officialName);
    end
end
fprintf('\n%s%g\n','Certain transport reactions set to irreversible. Growth: ',solution.f);
fprintf('\n')
end

if hardCoupleOxPhos
    fprintf('%s\n%s\n','Hard coupling pairs of oxidative phosphorylation reactions,','(this appends extra rows to the end of S).')
    % NDH-1:NDH-2 is 1:1 in iAF1260 flux2 (3 pairs of reactions - different quinone usage)
    %Hard couple pairs of oxidative phosphorylation  reactions
    %see supplementary material on iAF1260 Feist et al
    pair={'NADH10','NADH17pp';'NADH5','NADH16pp';'NADH9','NADH18pp'};
    [nMet,nRxn]=size(modelD.S);
    for p=1:length(pair)
        modelD.S(nMet+p,strcmp(modelD.rxns,pair{p,1}))=1;
        modelD.S(nMet+p,strcmp(modelD.rxns,pair{p,2}))=-1;
        %pad out abbreviations and names
        modelD.mets{nMet+p}=['coupleOxPhos' int2str(p)];
        modelD.met(nMet+p).abbreviation=modelD.mets{nMet+p};
        modelD.met(nMet+p).officialName=['coupleOxPhos_' pair{p,1} '_' pair{p,2}];
    end
    if isfield(modelD,'A')
        modelD.A=modelD.S;
    end
    %pad out the right hand side vector
    %S.v=b
    modelD.b=[modelD.b;sparse(length(pair),1)];
    modelD.csense(nMet+1:nMet+length(pair))='E';

    %test if modelD can grow
    if strcmp(CBTLPSOLVER,'cplex_direct')
        basisReuse=0;
        conflictResolve=0;
        contFunctName=[];
        minNorm=1e-6;
        [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
    else
        solution = optimizeCbModel(modelD);
    end
    fprintf('\n%s%g\n','Certain transport reactions set to irreversible * hard coupling ox phos. Growth: ',solution.f);
    fprintf('\n')

    %print out reactions going against reconstruction directions
    fprintf('\n%s\n','Reactions still going against qualitative directions')
    fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','AllTransportRecon','Equation','Reaction');
    for n=1:nRxn
        if strcmp(modelD.rxn(n).directionality,'forward') && solution.x(n)<-0.1
            fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',modelD.rxns{n},solutionRecon.x(n),solution.x(n),modelD.rxn(n).equation,modelD.rxn(n).officialName);
        end
    end
end



fprintf('\n%s\n','**************************************************************')
fprintf('\n%s\n','***Now certain transport and other misc to recon directions***')
fprintf('\n%s\n','**************************************************************')
%other misc. reactions set to forward
%%%Set to off in iAF1260_flux1%%
%CAT catalase 'CAT'
%FHL Formate hydrogen lyase 'FHL'
%SPODM superoxide dismutase 'SPODM'
%SPODMpp superoxide dismutase 'SPODMpp'

% otherRxn={'NADTRHD','ATPS4rpp'};
% otherRxn={[]};
% % otherRxn={'FEROpp','SUCOAS','NDPK1','PPKr','ALAALAr'};
% otherRxn={'PPKr','NDPK1','FEROpp','ALAALAr','SUCOAS','ALDD2y'};
% otherRxn={'NADTRHD','2DGULRy','HPYRRy','2DGLCNRy','FMNRx2','FLVR','DKGLCNR2y','IDOND2'...
%     'GLUSy'};


otherRxn={[]};
%transhydrogenase
% otherRxn{end+1}='NADTRHD'; %nad[c] + nadph[c]  -> nadh[c] + nadp[c]  NAD transhydrogenase
% otherRxn{end+1}='THD2pp'; % '2 h[p] + nadh[c] + nadp[c]  -> 2 h[c] + nad[c] + nadph[c] ''NAD P transhydrogenase periplasm '

%creating nad by going in reverse
% otherRxn{end+1}='GLYCL'; %gly[c] + nad[c] + thf[c]  -> co2[c] + mlthf[c] + nadh[c] + nh4[c]  Glycine Cleavage System
% otherRxn{end+1}='ME1'; %mal-L[c] + nad[c]  -> co2[c] + nadh[c] + pyr[c]  malic enzyme NAD
% otherRxn{end+1}='THRD'; %nad[c] + thr-L[c]  -> 2aobut[c] + h[c] + nadh[c]  L threonine dehydrogenase
% otherRxn{end+1}='GLYCDx'; %glyc[c] + nad[c]  -> dha[c] + h[c] + nadh[c] 	Glycerol dehydrogenase
% %
%creating nadh by going in reverse

%creating nadp by going in reverse
% otherRxn{end+1}='ALDD2y'; %acald[c] + h2o[c] + nadp[c]  -> ac[c] + 2 h[c] + nadph[c]  aldehyde dehydrogenase acetaldehyde NADP
% otherRxn{end+1}='GND'; %6pgc[c] + nadp[c]  -> co2[c] + nadph[c] + ru5p-D[c]  phosphogluconate dehydrogenase
% otherRxn{end+1}='ME2'; %mal-L[c] + nadp[c]  -> co2[c] + nadph[c] + pyr[c]  malic enzyme NADP

%seems to want to go in reverse
%otherRxn{end+1}='ACALD'; %acald[c] + coa[c] + nad[c]  <=> accoa[c] + h[c] + nadh[c]  acetaldehyde dehydrogenase acetylating

%creating nadph by going in reverse
% otherRxn{end+1}='HPYRRy'; %h[c] + hpyr[c] + nadph[c]  -> glyc-R[c] + nadp[c]  Hydroxypyruvate reductase NADPH
% otherRxn{end+1}='2DGLCNRy'; %2dhglcn[c] + h[c] + nadph[c]  -> glcn[c] + nadp[c]  2 dehydro D gluconate reductase NADPH
% otherRxn{end+1}='FMNRx2'; %fmn[c] + h[c] + nadph[c]  -> fmnh2[c] + nadp[c]  FMN reductase
% otherRxn{end+1}='FLVR'; %h[c] + nadph[c] + ribflv[c]  -> nadp[c] + rbflvrd[c]  flavin reductase
% otherRxn{end+1}='DKGLCNR2y'; %25dkglcn[c] + h[c] + nadph[c]  -> 5dglcn[c] + nadp[c]  2 5 diketo D gluconate reductase NADPH
% otherRxn{end+1}='IDOND2'; %5dglcn[c] + h[c] + nadph[c]  -> idon-L[c] + nadp[c]  L indonate 5 dehydrogenase NADP
% otherRxn{end+1}='GLUSy'; %akg[c] + gln-L[c] + h[c] + nadph[c]  -> 2 glu-L[c] + nadp[c]  glutamate synthase NADPH
% otherRxn{end+1}='GMPR'; %gmp[c] + 2 h[c] + nadph[c]  -> imp[c] + nadp[c] + nh4[c]  GMP reductase
% otherRxn{end+1}='2DGULRy'; %2dhguln[c] + h[c] + nadph[c]  -> idon-L[c] + nadp[c]  2 dehydro L gulonate reductase NADPH

%ines debuggin --> fix
% otherRxn{end+1}='ACKr';
%otherRxn{end+1}='PTAr';

%otherRxn{end+1}='ALAALAD';
% otherRxn{end+1}='ALAALAr';
otherRxn{end+1}='GLYCL';

%otherRxn{end+1}='CITL';
% otherRxn{end+1}='SUCOAS';

%ronan changes
% otherRxn{end+1}='THD2pp';

if 0
    %2011 Changes
    otherRxn{end+1}='DMSOR2pp';
    otherRxn{end+1}='TMAOR2pp';
    otherRxn{end+1}='THD2pp';
    %
    otherRxn{end+1}='AKGDH';
    otherRxn{end+1}='ALAALAD';
    otherRxn{end+1}='NADTRHD';
    otherRxn{end+1}='FRD3';

    bool=strcmp(modelD.rxns,'FEROpp');
    modelD.lb(bool)=0;
    %modelD.ub(bool)=0;
end
% if 1
% bool=strcmp(modelD.rxns,'AKGDH');
% modelD.lb(bool)=0;
% %modelD.ub(bool)=0;
% end
% if 0
% bool=strcmp(modelD.rxns,'MALS');
% modelD.lb(bool)=0;
% end
% %modelD.ub(bool)=0;
% %bool=strcmp(modelD.rxns,'NADTRHD');
% %modelD.lb(bool)=0;

for x=1:length(otherRxn)
    bool=strcmp(otherRxn{x},modelD.rxns);
    if any(bool)
%         if strcmp(modelD.rxn(bool).directionality,'forward')
            modelD.lb(bool)=0;
            modelD.ub(bool)=maxFlux;
            modelD.rxn(bool).directionalityThermo='forward';
            fprintf('\n%s%g\n',[otherRxn{x} ' set to irreversible.']);
%         else
         %    error([otherRxn{x} ' is qualitatively reversible.']);
%         end
    else
       if ~isempty(otherRxn{1})
            error([otherRxn{x} ' could not be found.']);
       end
    end
end

if 0
%relaxed reactions
otherRelaxedRxn{1}=[];
otherRelaxedRxn{end+1}='PPKr';
for x=1:length(otherRelaxedRxn)
     bool=strcmp(otherRelaxedRxn{x},modelD.rxns);
    if any(bool)
           modelD.lb(bool)=-maxFlux;
            modelD.ub(bool)=maxFlux;
            modelD.rxn(bool).directionalityThermo='reversible';
    end
end
end


%test if modelD can grow
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    conflictResolve=0;
    contFunctName=[];
    minNorm=1e-6;
    [solution,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
else
    solution = optimizeCbModel(modelD);
end
if hardCoupleOxPhos
    fprintf('\n%s%g\n','Certain transport & Hard Coupling & other reactions irreversible. Growth: ',solution.f);
else
    fprintf('\n%s%g\n','Certain transport & other reactions irreversible. Growth: ',solution.f);
end

%print out reactions going against reconstruction directions
fprintf('\n%s\n','Reactions still going against qualitative directions')
fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','AllTransportRecon','Equation','Reaction');
for n=1:nRxn
    if strcmp(modelD.rxn(n).directionality,'forward') && solution.x(n)<-0.1
        fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',modelD.rxns{n},solutionRecon.x(n),solution.x(n),modelD.rxn(n).equation,modelD.rxn(n).officialName);
    end
end

%print out quantitatively tightened reactions i.e tighter than reconstruction directions
fprintf('\n%s\n','Quantitatively tightened reactions')
fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','AllTransportRecon','Equation','Reaction');
for n=1:nRxn
    if strcmp(modelD.rxn(n).directionality,'reversible') && strcmp(modelD.rxn(n).directionalityThermo,'forward')
        fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',modelD.rxns{n},solutionRecon.x(n),solution.x(n),modelD.rxn(n).equation,modelD.rxn(n).officialName);
    end
end

%test if modelD can grow
if strcmp(CBTLPSOLVER,'cplex_direct')
    basisReuse=0;
    %set conflict resolve to 1 if you want a log file to be printed which
    %will help to identify the source of the infeasibility. The code in
    %cplex uses Chinnek's heuristics which dont always work but often they
    %are useful.
    %http://www.sce.carleton.ca/faculty/chinneck/chinneck_pub.shtml
    conflictResolve=0;
    if conflictResolve==1
        %set the lower bound on the objective to a minimum value to force
        %biomass production
        modelD.lb(strcmp(modelD.rxns,modelD.biomassRxnAbbr))=0.1;
    end
    contFunctName=[];
    minNorm=1e-6;
    [solutionThermoRecon,modelD]=solveCobraLPCPLEX(modelD,printLevel,basisReuse,conflictResolve,contFunctName,minNorm);
else
    solutionThermoRecon = optimizeCbModel(modelD);
end

if hardCoupleOxPhos
    %print out the flux through the coupled pairs of oxidative
    %phosphorylation reactions
    for p=1:size(pair,1)
        fprintf('%s\t%6.4g\t\t%s\t%6.4g\n',pair{p,1},solutionThermoRecon.x(strcmp(pair{p,1},modelD.rxns)),pair{p,2},solutionThermoRecon.x(strcmp(pair{p,2},modelD.rxns)));
    end
end

fprintf('\n%s%g\n','Final ThermoRecon growth: ',solutionThermoRecon.f);
fprintf('%s\t%g\n','c.f. growth with reconstruction directions: ',solutionRecon.f);


hardCoupleOxPhos=1;
if hardCoupleOxPhos
    %oxidative phosphorylation reactions
    oxPhos={'EX_o2(e)';'ATPS4rpp';'CRNBTCT';'CRNCAL2';'CRNCAR';'CRNCBCT';'CRNCDH';'CRNDCAL2';...
        'CTBTCAL2';'CYTBD2pp';'CYTBDpp';'CYTBO3_4pp';'DMSOR1';'DMSOR1pp';'DMSOR2';...
        'DMSOR2pp';'FDH4pp';'FDH5pp';'G3PD5';'G3PD6';'G3PD7';'GLCDpp';'HYD1pp';...
        'HYD2pp';'HYD3pp';'LDH_D2';'L_LACD2';'L_LACD3';'NADH10';'NADH16pp';...
        'NADH17pp';'NADH18pp';'NADH5';'NADH9';'NADPHQR2';'NADPHQR3';'NADPHQR4';...
        'NADTRHD';'NO3R1pp';'NO3R2pp';'NTRIR2x';'POX';'PPK2r';'PPKr';'QMO2';...
        'QMO3';'SUCDi';'FRD2';'FRD3';'THD2pp';'TMAOR1';'TMAOR1pp';'TMAOR2';'TMAOR2pp';'TRDR'};
    fprintf('\n');
    %print out oxidative phosphorylation reactions
    fprintf('%15s\t%6s%6s\t%65s\t%s\n','Abbr','iAF  ','Thermo','Equation','Reaction');
    for p=1:length(oxPhos)
        fprintf('%15s\t%4.2f\t%4.2f\t%65s\t%s\n',oxPhos{p},solutionRecon.x(strcmp(oxPhos{p,1},modelD.rxns)),solutionThermoRecon.x(strcmp(oxPhos{p,1},modelD.rxns)),modelD.rxn(strcmp(oxPhos{p,1},modelD.rxns)).equation,modelD.rxn(strcmp(oxPhos{p,1},modelD.rxns)).officialName);
    end
end

% model.lb_reconThermo      lower bound
% model.ub_reconThermo      upper bound
modelD.lb_reconThermo=modelD.lb;
modelD.ub_reconThermo=modelD.ub;

%restore reconstruction reaction directionality
modelD.lb=model.lb;
modelD.ub=model.ub;
