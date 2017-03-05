load('debugging.mat');
model = new.modelT;
load('Alberty2006.mat');
load('metGroupCont_Ecoli_iAF1260.mat');
model.metGroupCont = metGroupCont;
load('metSpeciespKa_Recon1.mat');
model.metSpeciespKa = metSpeciespKa;
[model,~] = assignThermoToModel(model,Alberty2006,1,1,1);
defaultBounds.lb = 0.02; %1e-5; %min(model.lb);
defaultBounds.ub = 20; %0.02; %max(model.ub);
metBoundsFile = 'model_met_bounds.txt'; % optional metabolite bounds file input
rxnBoundsFile = 'model_rxn_bounds.txt'; % optional reaction bounds file input
model = readMetRxnBoundsFiles(model,1,1,defaultBounds,metBoundsFile,rxnBoundsFile);
[D,DGC]=plotConcVSdGft0GroupContUncertainty(model); % fig 1
moleFractionStats(model); % fig 2


% load('iAF1260.mat');
% 
% 
load('gcmMetList_iAF1260.mat');
load('jankowskiGroupData.mat');
gcmOutputFile='gcmOutputFile_iAF1260.txt';
model.gcmOutputFile = gcmOutputFile;
model.gcmMetList = gcmMetList;
model.jankowskiGroupData = jankowskiGroupData;
% model.Alberty2006 = Alberty2006;
% 
% %setenv('PATH', [getenv('PATH') ':/opt/ChemAxon/MarvinBeans/bin']);
% %setenv('CHEMAXON_LICENSE_URL',[getenv('HOME') '/.chemaxon/license.cxl']);
% 
% 
% 
% model.lb = new.modelT.lb;
% model.ub = new.modelT.ub;
% 
% model.cellCompartments = new.modelT.cellCompartments;
% model.ph = new.modelT.ph;
% model.is = new.modelT.is;
% model.T = new.modelT.T;
% model.gasConstant = new.modelT.gasConstant;
% model.chi = new.modelT.chi;
% model.mets = new.modelT.mets;
% model.metFormulas = new.modelT.metFormulas;
% model.metCharges = new.modelT.metCharges;
% model.metNames = new.modelT.metNames;
% model.b = new.modelT.b;
% model.c = new.modelT.c;
% model.subSystems = new.modelT.subSystems;
% 
%model.SIntRxnBool = new.modelT.SIntRxnBool;
%model=thermodynamicAdjustmentToStoichiometry(model); % does some stuff to model.SIntRxnBool
model=findSExRxnInd(model);

% 
% model.xmin = new.modelT.xmin;
% model.xmax = new.modelT.xmax;
% model.DfG0 = new.modelT.DfG0;
% model.DrGtMin = new.modelT.DrGtMin;
% model.DrGtMax = new.modelT.DrGtMax;
% model.ur = new.modelT.ur;
% 
% % if model.S(952,350)==0
% %     model.S(952,350)=1; % One reaction needing mass balancing in iAF1260
% % end
% % model.metCharges(strcmp('asntrna[c]',model.mets))=0; % One reaction needing charge balancing
% 
% molfileDir = 'iAF1260Molfiles'; % Directory containing molfiles
% 
% cid = []; % KEGG Compound identifiers. Not required since molfile directory is specified.
% 
% T = 310.15; % Temperature in Kelvin
% cellCompartments = ['c'; 'e'; 'p']; % Cell compartment identifiers
% ph = [7.7; 7.7; 7.7]; % Compartment specific pH
% is = [0.25; 0.25; 0.25]; % Compartment specific ionic strength in mol/L
% chi = [0; 90; 90]; % Compartment specific electrical potential relative to cytosol in mV
% 
% xmin = 1e-5*ones(size(model.mets)); % Lower bounds on metabolite concentrations in mol/L
% xmax = 0.02*ones(size(model.mets)); % Upper bounds on metabolite concentrations in mol/L
% 
% confidenceLevel = 0.95; % Confidence level for estimated standard transformed reaction Gibbs energies. Used to quantitatively assign reaction directionality.
% 
% %model = setupThermoModel(model,molfileDir,cid,T,cellCompartments,ph,is,chi,xmin,xmax,confidenceLevel);
% model=addThermoToModel(model,0);
model.training_data.groups = jankowskiGroupData.groups;
model.training_data.DgrG0 =  jankowskiGroupData.DgrG0;
model.training_data.SEgr = jankowskiGroupData.SEgr;
% 
% model.quantDir = assignQuantDir(model.DrGtMin,model.DrGtMax,0);
% model = assignQualDir(model); % assign qualitative directions
% 
% 
% [model.metCompartments,~] = getCompartment(model.mets,1);
% 
% 
[model.massImbalance,model.imBalancedMass,model.imBalancedCharge,model.imBalancedRxnBool,model.Elements,model.missingFormulaeBool,model.balancedMetBool] = checkMassChargeBalance(model,0);
model = deltaG0concFluxConstraintBounds(model,0,0,gcmOutputFile,gcmMetList,model.training_data,1,1);

directions = directionalityStats(model,0.1,1,0);
% directionalityCheck(model,directions,0,0);
% 
forwardReversibleFiguresGC(model,directions,0);
% 
% 
% figures = gcf;
% directionalityStatFigures(model,directions,figures);