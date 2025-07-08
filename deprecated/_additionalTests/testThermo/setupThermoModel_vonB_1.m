function [modelT,directions,FBASolutions,metGroupCont,computedSpeciesData]=setupThermoModel(model,metAbbrAlbertyAbbr,...
    Alberty2006,gcmOutputFile,gcmMetList,jankowskiGroupData,temp,PHA,IS,CHI,biomassRxnAbbr,...
    rxnAbbrDatabaseID,defaultMetBounds,metSpeciespKa,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,...
    nStdDevGroupCont,cumNormProbCutoff,figures,printToFile,secondPassAssignment)
% Thermodynamically constrains a COBRA model.
% 
% [modelT,directions,FBASolutions]=setupThermoModel(model,metAbbrAlbertyAbbr,...
%  Alberty2006,gcmOutputFile,gcmMetList,jankowskiGroupData,metSpeciespKa,temp,PHA,IS,CHI,biomassRxnAbbr,...
%  rxnAbbrDatabaseID,defaultMetBounds,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,...
%  nStdDevGroupCont,cumNormProbCutoff,figures,printToFile,secondPassAssignment)
%
% This function takes as input an ordinary COBRA model (such as from sbml.xml)
% then uses thermodynamic data to setup a thermodynamic COBRA model.
%
%INPUT
% model
% model.biomassRxnAbbr      abbreviation of biomass reaction
%
% Alberty2006  Basic data on the metabolite species that make
%              up a reactant, compiled by Robert A. Alberty,
%              Massachusetts Institute of Technology.
%              In Print: Robert A. Alberty, Biochemical Thermodynamics: 
%              Applications of Mathematica. John Wiley & Sons, 2006. p391-395
%              Online: BasicBioChemData3.nb
%              http://library.wolfram.com/infocenter/MathSource/5704/
%              Only species of interest in the range pH 5 to 9 are included.
%
% Alberty2006 is a structure with two fields for each metabolite:
% Alberty2006.abbreviation(i) Alberty reactant abbreviation
% Alberty2006.basicData(i) cell array with 4 columns: dGf0,dHf0,charge,#Hydrogens 
%
% metAbbrAlbertyAbbr    mapping from model metabolite primary key to
%                       primary key of reactants in Alberty2006
%
% gcmOutputFile         Path to output file from Jankowski et al.'s 2008
%                       implementation of the group contribution method.
% 
% gcmMetList            Cell array with metabolite ID for metabolites in
%                       gcmOutputFile. Metabolite order must be the same in
%                       gcmOutputFile and gcmMetList.
% 
% jankowskiGroupData    Data on groups included in Jankowski et al.'s 2008
%                       implementation of the group contribution method.
%                       Included with von Bertalanffy 1.1. Location:
%                       ...\vonBertalanffy\setupThermoModel\experimentalDat
%                       a\groupContribution\jankowskiGroupData.mat.
%
% temp              temperature 298.15 K to 313.15 K
%
% PHA.*             glass electrode pH, between 5-9, in compartment defined by letter *
%                   *   compartment
%                   c   cytoplasm
%                   p   periplasm
%                   e   extracellular environment
%                   m   mitochondria
%                   n   nucleus
%                   r   endoplasmic reticulum
%                   g   Golgi apparatus
%                   l   lysosome
%                   x   peroxisome
%
% IS.*              ionic strength (0 - 0.35M) in compartment defined by letter *
% 
% CHI.*             electrical potential (mV) in compartment defined byletter *
%
% rxnAbbrDatabaseID   n x 2 cell array of reaction abbreviation and
%                     corresponding database ID
% 
% defaultMetBounds.*  Default bounds on metabolite concentrations in mol/L. Used for
%                     all metabolites except those listed in metBoundsFile.
%                     *    ub or lb
%                     ub   upper bound
%                     lb   lower bound
%
%
% OPTIONAL INPUT
% 
% metSpeciespKa     Structure containing pKa for acid-base equilibria between
%                   metabolite species. pKa are estimated with ChemAxon's
%                   pKa calculator plugin (see function "assignpKasToSpecies").
%
% metBoundsFile     filename with upper & lower bounds on metabolite 
%                   concentrations (Molar)
%                   See 'model_met_bounds.txt' for format required
% rxnBoundsFile     filename with upper & lower bounds on fluxes 
%                   (mmol gDw-1 hr-1)
%                   See 'model_rxn_bounds.txt' for format required
%
% Legendre              {(1),0} Legendre Transformation of dGf0?
% useKeqData            {(1),0} Use dGf0 back calculated from Keq?
% nStdDevGroupCont      {1} number of standard deviations of group contribution
%                       uncertainty to be used for each metabolite
% cumNormProbCutoff     {0.1} positive real number between 0 and 0.5 that
%                       specifies to tolerance when there is uncertainty in group
%                       contribution estimates.
% figures               {0}, 1 = create figures
% printToFile           {0}, 1 = print out to log files
% secondPassAssignment  {0}, 1 = assign reaction directions based on the P(\Delta_{r}G^{\primeo}<0)
%                       that calculates the probability of a reaction being irreversible, given 
%                       the available thermodynamic data.
%                       Doing so may prevent the model from growing, therefore at this stage it
%                       is necessary to manually adjust some of the
%                       reaction directionalities
%                       such that the model can grow, and grow at a similar rate as observed in
%                       vivo. Therefore this script cannot be made model invariant as there is an
%                       essential manual debugging stage. 
%                       A script is provided for E. coli iAF1260:
%                       setThermoReactionDirectionalityiAF1260.m
%
%OUTPUT
% modelT        a thermodynamic constraints based model
%
% modelT.gasConstant       Gas Constant
% modelT.faradayConstant   Faraday Constant
% modelT.temp              Temp
%
% modelT.met(m).dGft0                standard transformed Gibbs energy of formation(kJ/mol)
% modelT.met(m).dGft0Source          origin of data, Keq or groupContFileName.txt 
% modelT.met(m).dGft0Keq             standard transformed Gibbs energy of formation(kJ/mol) 
% modelT.met(m).dGft0GroupCont            group. cont. estimate of standard transformed Gibbs energy of formation(kJ/mol)
% modelT.met(m).dGf0GroupCont             group. cont. estimate of standard Gibbs energy of formation(kJ/mol)
% modelT.met(m).dGf0GroupContUncertainty  group. cont. uncertainty in estimate of standard Gibbs energy of formation (kJ/mol) 
% modelT.met(m).mf           mole fraction of each species within a pseudoisomer group
% modelT.met(m).aveZi        average charge
% modelT.met(m).chi          electrical potential
% modelT.met(m).aveHbound    average number of protons bound to a reactant
%
% modelT.lb_reconThermo      lower bound from amalgamation of reconstruction
%                            and thermodynamic assignment directions
% modelT.ub_reconThermo      upper bound from amalgamation of reconstruction
%                            and thermodynamic assignment directions
%
% directions    a structue of boolean vectors with different directionality 
%               assignments where some vectors contain subsets of others
%
% qualitatively assigned directions 
%       directions.fwdReconBool
%       directions.revReconBool
%       directions.reversibleReconBool
%
% qualitatively assigned directions using thermo in preference to
% qualitative assignments but using qualitative assignments where
% thermodynamic data is lacking
%       directions.fwdReconThermoBool
%       directions.revReconThermoBool
%       directions.reversibleReconThermoBool
%
% reactions that are qualitatively assigned by thermodynamics
%       directions.fwdThermoOnlyBool
%       directions.revThermoOnlyBool
%       directions.reversibleThermoOnlyBool
%
% qualtiative -> quantiative changed reaction directions 
%       directions.ChangeReversibleFwd
%       directions.ChangeReversibleRev
%       directions.ChangeForwardReverse
%       directions.ChangeForwardReversible
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
%       directions.cumNormProbCutoff
%       directions.ChangeForwardForwardBool_dGfGC
%
% FBASolutions.solutionRecon    FBA solution with reconstruction directions
% FBASolutions.solutionThermo   FBA solution with thermodynamic in preference to 
%                               reconstruction directions 
%                               (see setThermoReactionDirectionality.m)
%
% DEPENDENCIES ON OTHER COBRA TOOLBOX FUNCTIONS
% findRxnIDs.m
% printRxnFormula.m
%
% OPTIONAL DEPENDENCIES ON OTHER PACKAGES (i.e. more accurate)
% Multiple Precision Toolbox for MATLAB by Ben Barrowes (mptoolbox_1.1)
% http://www.mathworks.com/matlabcentral/fileexchange/6446
%
% COBRA TOOLBOX solvers e.g. solveCobraLP.m and solveCobraLPCPLEX.m for
% conflict resolution for an infeasible LP.
%
% This code is part of the vonBertalanffy package for Systems Biothermodynamics.
% Ludwig von Bertalanffy
% http://en.wikipedia.org/wiki/Ludwig_von_Bertalanffy
%
% Ronan M.T. Fleming, Sept 2010.
% Hulda SH, Dec 2010    Added computedSpeciesData as input. Passed into
%                       assignThermoToModel for calculation of transformed Gibbs energies of
%                       formation.
% Hulda SH, Feb 2011    Made minor changes to some of the subfunctions.
% Hulda SH, Nov 2011    MetGroupCont now created within this function using
%                       gcmOutputFile and gcmMetList. Made changes to
%                       subfunctions.

if ~exist('Legendre','var')
    Legendre=1;
end
if ~exist('useKeqData','var')
    useKeqData=1;
end
if ~exist('nStdDevGroupCont','var')
    nStdDevGroupCont=1;
end
if ~exist('cumNormProbCutoff','var')
    cumNormProbCutoff=0.1;
end
if ~exist('figures','var')
    figures=0;
end
if figures==1
    close all
end
if ~exist('printToFile','var')
    printToFile=0;
end
if ~exist('heuristicAssignment','var')
    heuristicAssignment=0;
end

%all possible compartments
numChar=1;
[allMetCompartments,uniqueCompartments]=getCompartment(model.mets,numChar);

if ~isfield(model,'biomassRxnAbbr')
    if ~exist('biomassRxnAbbr')
        fprintf('\n%s\n','...checkObjective');
        objectiveAbbr=checkObjective(model);
        fprintf('%s\n',['Asumming objective is ' objectiveAbbr]);
        model.biomassRxnAbbr=objectiveAbbr;
    else
        model.biomassRxnAbbr=biomassRxnAbbr;
    end
end

model=findSExRxnInd(model);
fprintf('\n');

if printToFile
    %create a folder to contain the directionality report
    if ~isfield(model,'description')
        model.description='';
    end
    folderName=[model.description '_thermoDirectionality_' date];
    mkdir(folderName)
    fullFolderName=[pwd '/' folderName];
    cd(fullFolderName);
end

[nMet,nRxn]=size(model.S);
for m=1:nMet
    if 0 && strcmp(model.mets{m,1},'h[c]')
        pause(eps)
    end
    if strcmp(model.metFormulas{m,1},'')
        fprintf('%s\n',[model.mets{m} ' getting formula and charge from InChI.'])
        model.metCharges(m)=getChargeFromInChI(model.metInChIString{m});
        model.metFormulas{m}=getFormulaFromInChI(model.metInChIString{m});
    end
end

if printToFile==1
    [massImbalance,imBalancedMass,imBalancedCharge,imBalancedBool,Elements] = checkMassChargeBalance(model,[],-1);
else
    [massImbalance,imBalancedMass,imBalancedCharge,imBalancedBool,Elements] = checkMassChargeBalance(model,[],1);
end
%save imbalances to model structure
model.imBalancedMass=imBalancedMass;
model.imBalancedCharge=imBalancedCharge;

if isempty(imBalancedBool)
    imBalancedBool=false(nRxn,1);
end

if 0
    if ~isempty(imBalancedMass)
        error('Internal reactions are not mass balanced.')
    end
    if ~isempty(imBalancedCharge)
        error('Internal reactions are not charge balanced.')
    end
else
    if ~isempty(imBalancedMass)
        warning('Internal reactions are not mass balanced.')
    end
    if ~isempty(imBalancedCharge)
        warning('Internal reactions are not charge balanced.')
    end
end

%Physico-Chemical Constants (Energies are expressed in kJ/mol)
gasConstant = 8.314472/1000; % kJ K-1 mol-1
faradayConstant = 96.48;     % Coloumb mol-1
model.gasConstant=gasConstant;
model.faradayConstant=faradayConstant;
%stamp model with intensive thermodynamic constants
model.PHA=PHA;
model.IS=IS;
model.temp=temp;

%optionally map reaction database ID's to model structure
if exist('rxnAbbrDatabaseID','var')
    model=mapDatabaseID(model,rxnAbbrDatabaseID);
end

%create structure with group contribution estimates of metabolite standard
%Gibbs energies of formation
webCGMtoTabDelimitedFile(model,gcmOutputFile,gcmMetList); %Creates 'gc_data_webGCM.txt' in current folder
metGroupCont=createGroupContributionStruct('gc_data_webGCM.txt');

fprintf('\n%s\n','...convert COBRA model to metabolite and reaction centered format');
%DASHES NOT changed to UNDERSCORES in abbreviations
model=convertToCobraV2(model);

%adjust for reactions involving co2 and succinate dehydrogenase reaction
model=thermodynamicAdjustmentToStoichiometry(model);
[nMet,nRxn]=size(model.S);

%readjust the length of the boolean vector indicating unbalanced reactions
% imBalancedBool2=false(nRxn,1);
% imBalancedBool2(1:length(imBalancedBool),1)=imBalancedBool;
% imBalancedBool=imBalancedBool2;
massImbalance=[massImbalance;sparse(nRxn-size(massImbalance,1),size(massImbalance,2))];

if 0 %set this off by default from Jan 30th 2011
    % Sets any reactions that have equal upper bounds to be forward reaction
    fprintf('%s\n','Checking for reactions that have equal upper and lower bounds...');
    for n=1:nRxn
        if model.lb(n)==0 && model.ub(n)==0
            %         error(['Reaction ' model.rxns{n} ' lb=ub=zero'])
            warning(['Reaction ' model.rxns{n} ' lb=ub=zero']);
            fprintf('%s\n',['Reaction ' model.rxns{n} ' ' model.rxn(n).officialName ' set to forward']);
            model.lb(n)=0;
            model.ub(n)=1000;
            model.rxn(n).directionality='forward';
            model.rxn(n).regulationStatus='Off';
        else
            model.rxn(n).regulationStatus='On';
        end
    end
end
    
%new reactions may have been added so update model size
[nMet,nRxn]=size(model.S);

%add constraint sense, including for new rows, if any.
if ~isfield(model,'csense')
    model.csense(1:nMet)='E';
end

%replace any underscores in metabolite abbreviations with dashes
fprintf('%s\n','...replace any underscores in metabolite abbreviations with dashes');
for m=1:length(metGroupCont)
    x = strfind(metGroupCont(m).abbreviation,'_');
    if x~=0
        metGroupCont(m).abbreviation(x)='-';
    end
end

% load Ecoli_metName_albertyAbbreviation;
nAlbertyMet=size(metAbbrAlbertyAbbr,1);

for m=1:nAlbertyMet
    abbr=metAbbrAlbertyAbbr{m,2};
    x = strfind(abbr,'_');
    if x~=0
        abbr(x)='-';
        metAbbrAlbertyAbbr{m,2}=abbr;
    end
end

fprintf('\n%s\n','...mapping Alberty abbreviations to model using metAbbrAlbertyAbbr.');
if printToFile
    fid=fopen('metabolites_with_no_Alberty_abbreviation.txt','w');
end
for m=1:nMet
    got=0;
    for a=1:nAlbertyMet
        metAbbr=model.mets{m};
        %dont include compartment
        metAbbr=metAbbr(1:end-3);
        if strcmp(metAbbr,metAbbrAlbertyAbbr{a,2})
            if ~isempty(metAbbrAlbertyAbbr{a,3})
                model.met(m).albertyAbbreviation=metAbbrAlbertyAbbr{a,3};
                got=1;
            end
            break;
        end
    end
    if got==0
        metAbbr=model.mets{m};
        if strcmp(metAbbr(end-2:end),'[c]')
            if printToFile==0
                fprintf('%s\t%s\t%20s\t%s\n','No Alberty abbreviation for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
            else
                fprintf(fid,'%s\t%s\t%s\t%s\n','No Alberty abbreviation for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
            end
        end
    end
end
if printToFile
    fclose(fid);
end

fprintf('\n%s\n','...assignment of Group Contribution data to model using metGroupCont structure.');
%assign Group Contribution data to model using metGroupCont
 fprintf('%s\n','Energies are expressed in kJ mol^-1')
nMetGroupCont=length(metGroupCont);
NaNdGf0GCMetBool=false(nMet,1);
metGroupContAbbr=cell(nMetGroupCont,1);
for a=1:nMetGroupCont
    metGroupContAbbr{a,1}=metGroupCont(a).abbreviation;
end
%check if compartment identifier is also in metabolite abbreviation
if strcmp(metGroupCont(1).abbreviation(end),']')
    %check if metabolite abbreviation in model matches any in group
    %contribution data
    for m=1:nMet
        bool=strcmp(model.mets{m},metGroupContAbbr);
        if ~any(bool)
            %mark as missing
            NaNdGf0GCMetBool(m,1)=1;
            model.met(m).dGf0GroupCont=NaN;
            model.met(m).dGf0GroupContUncertainty=NaN;
            model.met(m).formulaMarvin=NaN;
            model.met(m).chargeMarvin=NaN;
            model.met(m).groupContribution_pH=NaN;
            model.met(m).groupContribution_file=NaN;
        else
            if nnz(bool)>1
                error([metAbbr ': duplicated abbreviation[*] in group contribution data']);
            else
                %chemical standard chemical potential is  independent of compartment
                %TODO - group contribution estimate specific to pH
                %Energies are expressed in kJ mol^-1 so convert from  kCal
                model.met(m).dGf0GroupCont=metGroupCont(bool).delta_G_formation*(8.314472/1.987);
                model.met(m).dGf0GroupContUncertainty=metGroupCont(bool).delta_G_formation_uncertainty*(8.314472/1.987);
                model.met(m).formulaMarvin=metGroupCont(bool).formulaMarvin;
                model.met(m).chargeMarvin=metGroupCont(bool).chargeMarvin;
                model.met(m).groupContribution_pH=metGroupCont(bool).pH;
                model.met(m).groupContribution_file=metGroupCont(bool).file;
            end
        end
    end
else
    for m=1:nMet
        if strcmp(model.met(m).abbreviation,'damval[c]');
            pause(eps)
        end
        
        %check if metabolite abbreviation in model matches any in group
        %contribution data
        metAbbr=model.met(m).abbreviation;
        metAbbr=metAbbr(1:end-3);
        bool=strcmp(metAbbr,metGroupContAbbr);
        if ~any(bool)
            %mark as missing
            NaNdGf0GCMetBool(m,1)=1;
            
            model.met(m).dGf0GroupCont=NaN;
            model.met(m).dGf0GroupContUncertainty=NaN;
            model.met(m).formulaMarvin=NaN;
            model.met(m).chargeMarvin=NaN;
            model.met(m).groupContribution_pH=NaN;
            model.met(m).groupContribution_file=NaN;
        else
            bool=find(bool);
            bool=bool(1);
            if nnz(bool)>1
                error([metAbbr ': duplicated abbreviation in group contribution data']);
            else
                %chemical standard chemical potential is  independent of compartment
                %TODO - Assign pH to input for OpenBabel to get InChi strings specific
                %to pH
                %Energies are expressed in kJ mol^-1 so convert from  kCal
                model.met(m).dGf0GroupCont=metGroupCont(bool).delta_G_formation*(8.314472/1.987);
                model.met(m).dGf0GroupContUncertainty=metGroupCont(bool).delta_G_formation_uncertainty*(8.314472/1.987);
                model.met(m).formulaMarvin=metGroupCont(bool).formulaMarvin;
                model.met(m).chargeMarvin=metGroupCont(bool).chargeMarvin;
                model.met(m).groupContribution_pH=metGroupCont(bool).pH;
                model.met(m).groupContribution_file=metGroupCont(bool).file;
            end
        end
    end
end

% Create a new stoichiometric matrix (gcmS) where reactions are balanced in
% terms of the species returned by the group contribution method
% imBalancedBool = [imBalancedBool; true(nRxn-length(imBalancedBool),1)];
% model = balanceRxnsForGcmSpecies(model,imBalancedBool);

% Apparent glass electrode pH is not the same as real pH for thermodynamic calculations.
% Given the experimental glass electrode measurement of pH, this function returns
% the real pH to be used for thermodynamic calculations, pHr = -log10[H+], 
% by subtracting the effect of the ion atmosphere around H+ which 
% reduces its activity coefficient below unity.
% See p49 Alberty 2003
fprintf('\n%s\n','...realpH');
for p=1:length(uniqueCompartments)
    if isfield(PHA,uniqueCompartments{p,1})
        %if comparing this program against Albertys tables then use an apparent pH, i.e. pHa,
        %with a thermodynamic pH, i.e. pHr, that is equivalent
        compareAgainstAlbertysTables=1; %changed
        if compareAgainstAlbertysTables
            [pHr,pHAdjustment]=realpH(PHA.(uniqueCompartments{p,1}),temp,IS.(uniqueCompartments{p,1}));
            PHA.(uniqueCompartments{p,1})=PHA.(uniqueCompartments{p,1})+pHAdjustment;
        else
            fprintf('\n%s\n','If comparing this data with Albertys tables, note that they use real pH.');
        end
        
        [pHr,pHAdjustment]=realpH(PHA.(uniqueCompartments{p,1}),temp,IS.(uniqueCompartments{p,1}));
        %real thermodynamic pH
        PHR.(uniqueCompartments{p,1})=pHr;
    end
end

%Incorportate the electrochemical potential across the membrane by adding a
%component to the standard chemical potential of external protons:
%"Escherichia coli Glutamate- and Arginine-Dependent Acid Resistance Systems Increase Internal pH and
%Reverse Transmembrane Potential" by Hope Richard and John W. Foster*
%Data from Table 1
%Given a medium at pH 7 the exterior of the cell has an electrical
%potential 90mV lower than the exterior. Interior pH of 7.8. Culture temp
%of 310.15K.

%By default, make a Legendre transformation for electrical potential
LegendreCHI=1;

GCpriorityMetList={'camp'; 'met-L'; 'malcoa'; 'acac'; 'nmn'; 'aps'}; %by default use all albertys data over group contribution data, except for the metabolites in this cell array. % The entries for these metabolites in Alberty's tables contain errors (incorrect nr. of hydrogen atoms relative to charge).

%Assign Alberty data to model, or Legendre transformed Group Contribution
%data if no data is available from Alberty
%This function is where most of the detailed physical chemistry implemented
%by Alberty in mathematica, is implemented in matlab.
[model,computedSpeciesData]=assignThermoToModel(model,Alberty2006,temp,PHR,IS,CHI,uniqueCompartments,NaNdGf0GCMetBool,Legendre,LegendreCHI,useKeqData,printToFile,GCpriorityMetList,metGroupCont,metSpeciespKa); % Added computedSpeciesData as input. - Hulda
 
    
% In reaction thermodynamics, all metabolite standard Gibbs energies
% must refer to the a single predefined baseline.
% Reported metabolite standard Gibbs energies can sometimes differ in the
% baseline used. One must not have metabolites with different baselines
% when calculating reaction properties.
% e.g. Alberty provides standard transformed Gibbs energies of reactants
% with their own baseline adjusted such that the relative thermodynamic
% difference between certain paired cofactors, e.g. fad & fadh2, is correct
% but not correct if only one cofactor appears in a reaction, for instance
% when it is being synthesised. Here we try to ensure that the absolute
% metabolite standard Gibbs energies of formation are consistent
% with the group contribution data buy adjusting all metabolites to a
% common baseline.
% e.g. CoA & Acetyl CoA defined with own baseline by Alberty 2007 p137:
% this may cause problems when such cofactors are synthesized elsewhere
% in the network.

%This list of cofactors contains metabolites with own baselines reported
%by Alberty in his 2006 book, plus some metabolites that appear on the
%other side of a reaction from Alberty's set. It is important to keep an
%eye on the latter as they must all be on a common baseline when the
%adjustment is done.
adjustedMetList={'coa','aacoa','accoa','ppcoa','mmcoa_R','mmcoa-R',...
    'succoa','gthrd','gthox','q8h2','q8','fmn','fmnh2','nad',...
    'nadh','nmn','fad','fadh2','nadp','nadph','malcoa'};

%%%%% If one is sure ones thermodynamic data is all from the same baseline
%%%%% then one can avoid this step. %%%%% 
if ~isempty(Alberty2006)
    alberty2006Mets = cell(length(Alberty2006),1);
    for AMet = 1:length(alberty2006Mets)
        alberty2006Mets{AMet} = Alberty2006(AMet).abbreviation;
    end
    if Alberty2006(ismember(alberty2006Mets,'fadox')).basicData(1,1) ~=0
        setCommonBaselineForStandardGibbsEnergyOfFormation=false;
    else
        setCommonBaselineForStandardGibbsEnergyOfFormation = true;
    end
    if setCommonBaselineForStandardGibbsEnergyOfFormation
        % Set all metabolites to have a common baseline.
        model=setCommonZeroStandardGibbsEnergyOfFormation(model,adjustedMetList);
        fprintf('\n%s\n','...setCommonZeroStandardGibbsEnergyOfFormation');
    else
        fprintf('Assuming that all metabolites in Alberty2006 refer to the same thermodynamic baseline as group contribution data');
    end
end

%balance the protons in each reaction given the number of Hydrogens bound
%to each reactant calculated thermodynamically using assignThermoToModel.m
if 0 %TODO Jan 30th 2011 Balancing protons changes growth rate ~0.7 -> 1.1  Need to check
    fprintf('\n%s\n','...pHbalanceProtons');
    model=pHbalanceProtons(model,massImbalance); % Minor changes - Hulda
end

%plot statistics on the number of reactants with significant
%non-predominant mole fractions >0.05
molefractions = cat(1,model.met.mf);
if any(molefractions < 0.99)
if figures
    moleFractionStats(model) % Minor changes - Hulda
end
end

fprintf('\n%s\n','... readMetRxnBoundsFiles');
%assign bounds on metabolite concentrations and fluxes

% setDefaultConc            sets default bounds on conc [1e-5,0.02]     
setDefaultConc=1;
% setDefaultFlux            sets all reactions reversible [-1000,1000]
setDefaultFlux=0;% set to zero since we use the bounds given by

%locations of the files with the bounds on metabolite concentration 
%and reaction flux
if ~exist('metBoundsFile','var')
%     metBoundsFile='model_met_bounds.txt';
%    metBoundsFile='Schuetz_met_data.txt';
    metBoundsFile='Bennet_Glucose_Aerobic.txt';
%     metBoundsFile='Bennet_Glucose_Aerobic_Cofactor.txt';
%    metBoundsFile='Bennet_Glucose_Aerobic_Cofactor_ATPs.txt';
%      metBoundsFile='Bennet_Glucose_Aerobic_Cofactor_NAD.txt';
end
if ~exist('rxnBoundsFile','var')
%     rxnBoundsFile='model_rxn_bounds.txt';
    rxnBoundsFile='Ecoli_glucose_aerobic_rxn_bounds.txt';
end
% metBoundsFile=[];
% rxnBoundsFile=[];
%assign bounds to model +/- read in data from flat file 
model=readMetRxnBoundsFiles(model,setDefaultConc,setDefaultFlux,defaultMetBounds,metBoundsFile,rxnBoundsFile); % Passed in defaultMetBounds - Hulda

%Special concentration bounds for o2, co2, h2o and h
for m=1:nMet
    abbr=model.mets{m};
    abbrShort=abbr(1:end-3);
    compartment=abbr(end-1);
    
    %water concentration assumed to be one molar p107 Alberty 2003
    if strcmp('h2o',abbrShort)
        model.met(m).concMin=0.99;%55.5062-1;;
        model.met(m).concMax=1;%55.5062+1;;
    end

    if strcmp('co2',abbrShort)
        if strcmp('co2[c]',abbr)
            model.met(m).concMin=10e-8;
            model.met(m).concMax=0.0014;
        else
            model.met(m).concMin=0.0001;
            model.met(m).concMax=0.0001;
        end
    end
    
    %From Henry et al
    % oxygen concentration selected for the media is 8.2E-6 M
    % and the oxygen concentration in the cell cannot exceed the concentration
    % in the media, the bounds on the oxygen concentration in the cell
    % were set from 10E-7 M to 8.2E-6M
    if strcmp('o2',abbrShort)
        if strcmp('o2[c]',abbr)
            model.met(m).concMin=10e-8;
            model.met(m).concMax=8.2e-6;
        else
            model.met(m).concMin=8.2e-8;
            model.met(m).concMax=8.2e-6;
        end
    end
    %hydrogen ion concentration uses real pH (not apparent pH)
    if strcmp('h',abbrShort)
        model.met(m).concMin=10^-PHR.(compartment);
        model.met(m).concMax=10^-PHR.(compartment);
    end
end

fprintf('\n%s\n','... deltaG0concFluxConstraintBounds');
%Set reaction directionality bounds from thermodynamic data:
%set up bounds  on metabolite chemical potential
%use to set upper & lower thermodynamic bounds on internal fluxes
%******************first pass***************
model=deltaG0concFluxConstraintBounds(model,Legendre,LegendreCHI,gcmOutputFile,gcmMetList,jankowskiGroupData,figures,nStdDevGroupCont); % Minor changes - Hulda

fprintf('\n%s\n','...standardGibbsFormationEnergyStats');
% figures=0;
[nKeq,nGC,nNone]=standardGibbsFormationEnergyStats(model,figures);
% figures=1;

fprintf('\n%s\n','...directionalityCheckAll');
%check the thermodynamically feasible directions with respect to the
%reconstruction directions
if printToFile
    %print out problematic reactions in summary table format for paper
    printToTable=1;
    % cumNormProbCutoff     {0.1} positive real number between 0 and 0.5 that
    %                       specifies to tolerance when there is uncertainty in group
    %                       contribution estimates.
else
    printToTable=0;
end

%create new standard Gibbs Free Energy based on the geometric mean of each
%metabolites concentration range
thorStandard=0; %zero for first pass is adivisable since growth may be infeasible  
directions=directionalityCheckAll(model,cumNormProbCutoff,thorStandard,printToFile,printToTable,figures);
%boolean vectors indexing the reaction directionalities according to
%different criteia
model.directions=directions;

%test the functionality of the model if cobra toolbox installed
if 0%exist('solveCobraLP','file')==0
    fprintf('\n')
    fprintf('%s\n','No LP solver configured with a COBRA toolbox installation.');
    fprintf('%s\n','See http://gcrg.ucsd.edu/Downloads/Cobra_Toolbox');
    fprintf('%s\n','Checking the assignment of reaction directionality with FBA requires an LP solver.');
    solutionRecon=[];
    solutionThermoRecon=[];
    model1=[];
else
    %******************first pass starts here ***************
    %minimiseNorm of all reactions
    % changeOK = changeCobraSolverParams('LP','minNorm',1e-6);
    
    %FBA with reconstruction directions
    solutionRecon = optimizeCbModel(model);
    
    %FBA with qualitatively assigned directions using thermo in preference to
    % qualitative assignments but using qualitative assignments where
    % thermodynamic data is lacking
    % model.lb_reconThermo              lower bounds from dGtMin/dGtMax and recon
    %                                   directions if thermo data missing
    % model.ub_reconThermo              upper bounds from dGtMin/dGtMax and recon
    %                                   directions if thermo data missing
    modelD=model;
    bool=~modelD.NaNdG0RxnBool & (modelD.directions.ChangeReversibleFwd | modelD.directions.ChangeReversibleRev | modelD.directions.ChangeForwardReverse);
    if ~any(bool)
       warning('No change in reactions')
    end
    %Amalgamation of recon & thermo directions
    modelD.lb(bool)=model.lb_reconThermo(bool);
    modelD.ub(bool)=model.ub_reconThermo(bool);
    %FBA
    solutionThermoRecon = optimizeCbModel(modelD);
    clear modelD
    fprintf('\n%s\t%g\n','Growth with reconstruction directions: ',solutionRecon.f);
    fprintf('\n%s\t%g\n','Growth with amalgamation of recon & thermo directions: ',solutionThermoRecon.f);
    
    
    %******************second pass starts here ***************
    %automatically run second pass at directionality assignment for iAF1260
    if secondPassAssignment || strcmp(model.description,'iAF1260')
        %requires manual curation
        [model,solutionThermoRecon,solutionRecon,model1]=secondPassDirectionalityAssignment(model);
    end
end

FBASolutions.solutionRecon = solutionRecon;
FBASolutions.solutionThermoRecon = solutionThermoRecon;

fprintf('\n%s\n','...readableCobraModel');
%make the model readable
model=readableCobraModel(model);

if Legendre==1 && LegendreCHI
    fprintf('\n%s\n','N.B. Thermodynamic properties calculated using a Legendre transform for pH and electrical potential.');
else
    fprintf('\n%s\n','N.B. Thermodynamic properties have not been calculated using a Legendre transform.');
end

%move out of folder
cd ..
if printToFile
    fprintf('\n%s\n',['Directionality report in folder: ' folderName]);
end
%change name of model
modelT=model;
end

%%%%%%%%% helper function which shadows a function in the COBRA toolbox
function [massImbalance,imBalancedMass,imBalancedCharge,imBalancedBool,Elements] = checkMassChargeBalance(model,rxnBool,printLevel)
%checkMassChargeBalance tests for a list of reactions if these reactions are
%mass-balanced by adding all elements on left hand side and comparing them
%with the sums of elements on the right hand side of the reaction.
%
% [UnbalancedRxns] = checkMassChargeBalance(model,RxnList)
%
%INPUT
% model                         COBRA model structure
%
%OPTIONAL INPUT
% rxnBool       Boolean vector corresponding to reactions in model to be
%               tested. If empty, then all tested.
%               Alternatively, can be the indices of reactions to test:
%               i.e. rxnBool(indixes)=1;
% printLevel    {-1,(0),1} 
%               -1 = print out diagnostics on problem reactions to a file 
%                0 = silent
%                1 = print out diagnostics on problem reactions to screen
%
%OUTPUTS
% massImbalance                 nRxn x nElement matrix with mass imblance
%                               for each element checked. 0 if balanced.
% imBalancedMass                nRxn x 1 cell with charge imbalance
%                               e.g. -3 H means three hydrogens disappear
%                               in the reaction.
% imBalancedCharge              nRxn x 1 vector with charge imbalance,
%                               empty if no imbalanced reactions
%
% imbalancedBool                boolean vector indicating imbalanced reactions
%       
% Elements                      nElement x 1 cell array of element
%                               abbreviations checked 
% Ines Thiele 12/09
% IT, 06/10, Corrected some bugs and improved speed.
% RF, 09/09/10, Support for very large models and printing to file.

model.S = full(model.S);

[nMet,nRxn]=size(model.S);
if exist('rxnBool','var')
    if ~isempty(rxnBool)
        if length(rxnBool)~=nRxn
            rxnBool2=false(nRxn,1);
            rxnBool2(rxnBool)=1;
            rxnBool=rxnBool2;
        end
        model=findSExRxnInd(model);
        %only check mass balance of internal reactions
        rxnBool=rxnBool & model.SIntRxnBool;
    else
        model=findSExRxnInd(model);
        %only check mass balance of internal reactions
        rxnBool=model.SIntRxnBool;
    end
else
    model=findSExRxnInd(model);
    %only check mass balance of internal reactions
    rxnBool=model.SIntRxnBool;
end
if ~exist('printLevel','var')
    printLevel=0;
end

% List of Elements
Elements = {'H','C', 'O', 'P', 'S', 'N', 'Mg','X','Fe','Zn','Co','R'};

E=sparse(nMet,length(Elements));
massImbalance=sparse(nRxn,length(Elements));
for j = 1 : length(Elements)
    if j==1
        [dE,E_el]=checkBalance(model,Elements{j},printLevel);
        massImbalance(:,j)=dE;
        E(:,j)=E_el;
        fprintf('%s\n',['Checked element ' Elements{j}]);  
    else
        %no need to print out for each element which metabolites have no
        %formula
        [massImbalance(:,j),E(:,j)]=checkBalance(model,Elements{j},0);
        fprintf('%s\n',['Checking element ' Elements{j}]);
    end
end
E = full(E);
massImbalance(~rxnBool,:)=0;
massImbalance = full(massImbalance);
imBalancedBool=sum(abs(massImbalance'))'~=0;

imBalancedBool=rxnBool & imBalancedBool;

imBalancedMass=cell(nRxn,1);
for i = 1 : nRxn
    imBalancedMass{i,1}='';   
    if imBalancedBool(i)
        for j = 1 : length(Elements)
            if massImbalance(i,j)~=0
                if ~strcmp(imBalancedMass{i,1},'')
                    imBalancedMass{i,1} = [imBalancedMass{i,1} ', ' int2str(massImbalance(i,j)) ' ' Elements{j}];
                else
                    imBalancedMass{i,1} = [int2str(massImbalance(i,j)) ' ' Elements{j}];
                end
            end
            
        end
        if strfind(imBalancedMass{i,1},'NaN')
            imBalancedMass{i,1}='NaN';
        end
    end
    if mod(i,1000)==0
        fprintf('%n\t%s\n',i,['reactions checked for ' Elements{j} ' balance']);
    end
end
if printLevel==-1
    firstMissing=0;
    for p=1:nRxn
        if ~strcmp(imBalancedMass{p,1},'')
            %at the moment, ignore reactions with a metabolite that have
            %no formula
            if ~strcmp(imBalancedMass{p,1},'NaN')
                if ~firstMissing
                    fid=fopen('mass_imbalanced_reactions.txt','w');
                    fprintf(fid,'%s;%s;%s;%s\n','#Rxn','rxnAbbr','imbalance','equation');

                    warning('There are mass imbalanced reactions, see mass_imbalanced_reactions.txt')
                    firstMissing=1;
                end
                equation=printRxnFormula(model,model.rxns(p),0);
                fprintf(fid,'%s;%s;%s;%s\n',int2str(p),model.rxns{p},imBalancedMass{p,1},equation{1});
                for m=1:size(model.S,1)
                    if model.S(m,p)~=0
                        fprintf(fid,'%s\t%s\t%s\t%s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,p)),int2str(E(m)),model.metFormulas{m});
                    end
                end
            end
        end
    end
    if firstMissing
        fclose(fid);
    end
end
if printLevel==1
    for p=1:nRxn
        if ~strcmp(imBalancedMass{p,1},'')
            %at the moment, ignore reactions with a metabolite that have
            %no formula
            if ~strcmp(imBalancedMass{p,1},'NaN')
                equation=printRxnFormula(model,model.rxns(p),0);
                fprintf('%6s\t%30s\t%10s\t%s\n',int2str(p),model.rxns{p},imBalancedMass{p,1},equation{1});
                if 0
                for m=1:size(model.S,1)
                    if model.S(m,p)~=0
                        fprintf(fid,'%s\t%s\t%s\t%s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,p)),int2str(E(m)),model.metFormulas{m});
                    end
                end
                end
            end
        end
    end
end

%
if nnz(strcmp('',imBalancedMass))==nRxn
    imBalancedMass=[];
end

% Check for charge balance
imBalancedCharge=[];
firstMissing=0;
if isfield(model, 'metCharges')
    for m=1:nMet
        if isnan(model.metCharges(m)) && ~isempty(model.metFormulas{m})
            if printLevel==1
                fprintf('%s\t%s\n',int2str(m),[model.mets{m} ' has no charge but has formula.'])
                if ~firstMissing
                    warning('model structure must contain model.metCharges field for each metabolite');
                end
                firstMissing=1;
            end
            if printLevel==-1
                if ~firstMissing
                    fid=fopen('metabolites_without_charge.txt','w');
                end
                firstMissing=1;
                fprintf(fid,'%s\t%s\n',int2str(m),model.mets{m})
            end
        else
            dC=model.S'*model.metCharges;
        end
    end
    if any(dC(rxnBool))~=0
        imBalancedCharge=dC;
        imBalancedCharge(~rxnBool)=0;
    else
        imBalancedCharge=[];
    end
end

if printLevel==-1
    firstMissing=0;
    if ~isempty(imBalancedCharge)
        for q=1:nRxn
            if model.SIntRxnBool(q) && dC(q)~=0 && strcmp(imBalancedMass{p,1},'')
                if ~firstMissing
                    fid=fopen('charge_imbalanced_reactions.txt','w');
                    warning('There are charged imbalanced reactions (that are mass balanced), see charge_imbalanced_reactions.txt')
                    firstMissing=1;
                end
                equation=printRxnFormula(model,model.rxns(q),0);
                fprintf(fid,'%s\t%s\t%s\n',int2str(q),model.rxns{q},equation{1});
                if 0
                    for m=1:size(model.S,1)
                        if model.S(m,q)~=0
                            fprintf(fid,'%s\t%15s\t%3s\t%3s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,q)),int2str(model.metCharges(m)),model.metFormulas{m});
                        end
                    end
                end
            end
        end
        if firstMissing
            fclose(fid);
        end
    end
end

if printLevel==1
    if ~isempty(imBalancedCharge)
        fprintf('%s\n','Mass balanced, but charged imbalanced reactions:')
        for q=1:nRxn
            if model.SIntRxnBool(q) && dC(q)~=0 && strcmp(imBalancedMass{p,1},'')
                equation=printRxnFormula(model,model.rxns(q),0);
                fprintf('%s\t%s\t%s\n',int2str(q),model.rxns{q},equation{1});
                if 1
                    for m=1:size(model.S,1)
                        if model.S(m,q)~=0
                            fprintf('%s\t%15s\t%3s\t%3s\t%s\n',int2str(m),model.mets{m},int2str(model.S(m,q)),int2str(model.metCharges(m)),model.metFormulas{m});
                        end
                    end
                end
            end
        end
    end
end

if ~isempty(imBalancedCharge)
    imBalancedBool = imBalancedBool |  imBalancedCharge~=0;
end
model.S = sparse(model.S);
end

