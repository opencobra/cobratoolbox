%% Metabolic visualisation in ReconMap (Minerva) 

% Authors: Alberto Noronha, Ines Thiele, and Ronan M.T. Fleming,...
% Luxembourg Centre for Systems Biomedicine, University of Luxembourg, Luxembourg.

% Reviewer(s): Sylvain Arreckx

%% Equipment setup 

% use your credentials to remotely access to http://vmh.uni.lu.  
load('minerva.mat')
minerva.minervaURL = 'http://vmh.uni.lu/minerva/galaxy.xhtml';
minerva.login = 'user_name';
minerva.password = 'user_password';
minerva.model = 'ReconMap-2.01'; 

% Initialise the Cobra Toolbox.
initCobraToolbox 

% Change cobra solver 
changeCobraSolver('gurobi','qp')
changeCobraSolver('gurobi','lp')	

%Load your generic metabolic model (downloaded from http://vmh.uni.lu.)
model = readCbModel('Recon2.v04.mat')

%% Run FBA / sparseFBA to obtain the fluxes through your model
% we want to select as an objective function, ATP production. 
% Print reaction formula to see the biochemical process that will be
% Maximized in the model 

formula = printRxnFormula(model,'ATPS4m') 

% change objectiuve function and obtain the fluxes through the model
model_atp_production = model %re-name the model to do not modify the original one.
model_atp_production = changeObjective(model_atp_production, 'ATPS4m'); 
model_atp_production_max = optimizeCbModel(model_atp_production, 'max');

%% Visualise the fluxes in ReconMap 
buildFluxDistLayout(minerva, model, model_atp_production_max, 'atp_production_max')

%% Visualise a subSystem in ReconMap 
% Other information can be visualise, such as Subsystems. 
generateSubsytemsLayout(minerva, model, 'Citric acid cycle x', '#6617B5');

