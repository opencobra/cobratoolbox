%script for testing functionality of vonBertalanffy COBRA toolbox extension

%setup the path to the stripts and data
initVonBertalanffy

% modelToTest='iCore';
%modelToTest='iCoreED';
modelToTest='Recon1';
%modelToTest='ReconX';

switch modelToTest
    case 'iAF1260'
        %name of biomass reaction
        biomassRxnAbbr='Ec_biomass_iAF1260_core_59p81M';
        
        load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'reconstructions' filesep 'iAF1260_flux1.mat']);
        model.description='iAF1260';
        
        %group contrbuion data for E. coli
        gcmOutputFile = [vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'gcmOutputFile_iAF1260.txt'];
        load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'gcmMetList_iAF1260.mat']);
        %load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'metGroupCont_Ecoli_iAF1260.mat']);
        
        if model.S(952,350)==0
            model.S(952,350)=1;%one reaction needing mass balanced in iAF1260
        end
        model.metCharges(strcmp('asntrna[c]',model.mets))=0;%one reaction needing charge balancing
        
        % default thermodynamic parameters
        if 1
            temp=310.15;
            PHA.c=7.7;
            PHA.p=7.7;
            PHA.e=7.7;
            IS.c=0.25;
            IS.p=0.25;
            IS.e=0.25;
            CHI.c=0;
            CHI.p=90; %milliVolts
            CHI.e=90;
        else
            temp=310.15;
            PHA.c=7.7;
            PHA.p=5;
            PHA.e=5;
            IS.c=0.25;
            IS.p=0.15;
            IS.e=0.15;
            CHI.c=0;
            CHI.p=90; %milliVolts
            CHI.e=90;
        end
        metSpeciespKa=[];
        
        %default metabolite concentration bounds
        defaultMetBounds.lb = 1e-5; %Molar
        defaultMetBounds.ub = 0.02; %Molar
        
        %flag to include heursitic assignment in addition to thermodynamic
        %assignment
        secondPassAssignment=0;
        metBoundsFile=[];
        rxnBoundsFile=[];
        
    case 'iCore'
        %Ecoli core
        biomassRxnAbbr='Biomass_Ecoli_core_w/GAM';
        %Ecoli core
        load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'reconstructions' filesep 'ecoli_core_xls2model.mat']);
        model.description='iCore';
        %group contrbuion data for E. coli
        gcmOutputFile = [vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'gcmOutputFile_Ecoli_core.txt'];
        load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'gcmMetList_Ecoli_core.mat']);
        %load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'metGroupCont_Ecoli_iAF1260.mat']);
        
        
        % default thermodynamic parameters
        if 0
            temp=310.15;
            PHA.c=7.7;
            PHA.p=7.7;
            PHA.e=7.7;
            IS.c=0.25;
            IS.p=0.25;
            IS.e=0.25;
            CHI.c=0;
            CHI.p=90; %milliVolts
            CHI.e=90;
        else
            temp=310.15;
            PHA.c=7.7;
            PHA.p=5;
            PHA.e=5;
            IS.c=0.25;
            IS.p=0.15;
            IS.e=0.15;
            CHI.c=0;
            CHI.p=90; %milliVolts
            CHI.e=90;
        end
        metSpeciespKa=[];
        
        defaultMetBounds.lb = 1e-5; %Molar
        defaultMetBounds.ub = 0.02; %Molar
        
        secondPassAssignment=0;
        metBoundsFile=[];
        rxnBoundsFile=[];
        
%     case 'iCoreED'
%         %Ecoli core
%         biomassRxnAbbr='Biomass_Ecoli_core_w/GAM';
%         %Ecoli core
%         load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'reconstructions' filesep 'iCoreED.mat']);
%         model=iCoreED;
%         model.description='iCoreED';
%         %group contrbuion data for E. coli
%         gcmOutputFile = ;
%         gcmMetList = ;
%         %load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'metGroupCont_Ecoli_iAF1260.mat']);
%         
%         % default thermodynamic parameters
%         if 0
%             temp=310.15;
%             PHA.c=7.7;
%             PHA.p=7.7;
%             PHA.e=7.7;
%             IS.c=0.25;
%             IS.p=0.25;
%             IS.e=0.25;
%             CHI.c=0;
%             CHI.p=90; %milliVolts
%             CHI.e=90;
%         else
%             temp=310.15;
%             PHA.c=7.7;
%             PHA.p=5;
%             PHA.e=5;
%             IS.c=0.25;
%             IS.p=0.15;
%             IS.e=0.15;
%             CHI.c=0;
%             CHI.p=90; %milliVolts
%             CHI.e=90;
%         end
%         metSpeciespKa=[];
%         
%         defaultMetBounds.lb = 1e-5; %Molar
%         defaultMetBounds.ub = 0.02; %Molar
%         
%         secondPassAssignment=0;
%         metBoundsFile=[];
%         rxnBoundsFile=[];

    case 'Recon1'
        %biomass reaction
        biomassRxnAbbr='biomass_reaction';
        %Recon1 model
        load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'reconstructions' filesep 'Recon1.mat']);
        model.description='Recon1';
        %group contribution data for Recon 1
        gcmOutputFile = [vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'gcmOutputFile_Recon1.txt'];
        load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'gcmMetList_Recon1.mat']);
        %pka estimates for Recon1 species
        load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'groupContribution' filesep 'metSpeciespKa_Recon1.mat']);
        
        % Set standard enthalpy to 0 kJ/mol for all metabolites in Alberty's
        % tables. Makes Alberty and GCM values more compatible
        for n = 1:length(Alberty2006)
            Alberty2006(n).basicData(~isnan(Alberty2006(n).basicData(:,2)),2) = nan;
        end
        
        %thermodynamic parameters
        temp=310.15;
        
        %log10(hydrogen ion activity)
        PHA.c = 7.2;
        PHA.e = 7.4;
        PHA.g = 6.35;
        PHA.l = 5.5;
        PHA.m = 8;
        PHA.n = 7.2;
        PHA.r = 7.2;
        PHA.x = 7;
        
        %ionic strength
        someIonicStrength=0.15; % 0.05-0.25 - Alberty 2003, top of page 4.
        IS.c=someIonicStrength;
        IS.e=someIonicStrength;
        IS.g=someIonicStrength;
        IS.l=someIonicStrength;
        IS.m=someIonicStrength;
        IS.n=someIonicStrength;
        IS.r=someIonicStrength;
        IS.x=someIonicStrength;
        
        %milliVolts
        CHI.c = 0; % Electrical potential in cytosol assumed to be zero. All other potentials relative to cytosol.
        CHI.e = 30;
        CHI.g = 0;
        CHI.l = 19;
        CHI.m = -155;
        CHI.n = 0;
        CHI.r = 0;
        CHI.x = -2.303*8.3144621e-3*temp*(PHA.x - PHA.c)/(96485.3365e-6); % Assumes the proton motive force across the peroxisomal membrane is 0 kJ/mol, i.e. Donnan equilibrium
        
        defaultMetBounds.lb = 1e-7; % M
        defaultMetBounds.ub = 1e-2; % M
        
        secondPassAssignment=0;
        metBoundsFile=[vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'metaboliteConcentrations' filesep 'Recon1CofactorConcentrations.txt'];
        rxnBoundsFile=[];
end

pause(eps)

if 1
    %parameters for routine setup WITH printouts and figures
    Legendre=1;
    useKeqData=1;
    nStdDevGroupCont=2;
    cumNormProbCutoff=0.2;
    figures=1;
    printToFile=1;
else
    %other choice of parameters for routine setup WITHOUT printouts or
    %figures
    Legendre=1;
    useKeqData=1;
    nStdDevGroupCont=2;
    cumNormProbCutoff=0.2;
    figures=0;
    printToFile=0;
end

rxnAbbrDatabaseID=[];

changeCobraSolver('glpk');

%setup a thermodynamically constrained model of metabolism
[modelT,directions,FBASolutions,metGroupCont,computedSpeciesData]=setupThermoModel(model,metAbbrAlbertyAbbr,...
    Alberty2006,gcmOutputFile,gcmMetList,jankowskiGroupData,temp,PHA,IS,CHI,biomassRxnAbbr,...
    rxnAbbrDatabaseID,defaultMetBounds,metSpeciespKa,metBoundsFile,rxnBoundsFile,Legendre,useKeqData,...
    nStdDevGroupCont,cumNormProbCutoff,figures,printToFile,secondPassAssignment);