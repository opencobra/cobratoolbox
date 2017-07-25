function generateThermodynamicTables(model, resultsBaseFileName)
% Generate tab delimited tables detailing the thermodynamic estimates
% generated for a model
%
% USAGE:
%
%    generateThermodynamicTables(model, resultsBaseFileName)
%
% INPUTS:
%    model:                  structure
%    resultsBaseFileName:    default = 'out'

if ~exist('resultsBaseFileName','var')
    resultsBaseFileName='out';
end

%% Print results to tables
% Generate file names
parameterTab = [resultsBaseFileName 'thermo_parameters.csv'];
reactionTab = [resultsBaseFileName 'thermo_reactions.csv'];
metaboliteTab = [resultsBaseFileName 'thermo_metabolites.csv'];

% Format data
% Parameters
compartments = cellstr(model.compartments);
compartment_pH = model.ph;
compartment_I = model.is; % mol/L
compartment_phi = model.chi; % mV
T = model.T; % K

% Rxns
rxnID = model.rxns;
DrG0 = model.DrG0;
DrGt0_Uncertainty = model.DrGt0_Uncertainty;
DrGt0 = model.DrGt0;
DrGtMin = model.DrGtMin;
DrGtMax = model.DrGtMax;

% Mets
metID = model.mets;
DfG0 = model.DfG0;
DfG0_Uncertainty = model.DfG0_Uncertainty;
DfGt0 = model.DfGt0;
DfGtMin = model.DfGtMin;
DfGtMax = model.DfGtMax;
concMin = model.concMin;
concMax = model.concMax;

% Print data
% Parameter tab
fid = fopen(parameterTab,'w+');
fprintf(fid, ['Compartment' repmat('\t%s',1,length(compartments)) '\r\n'], compartments{:});
fprintf(fid, ['Temperature (K)' repmat('\t%.2f',1,length(compartments)) '\r\n'], repmat(T,1,length(compartments)));
fprintf(fid, ['pH' repmat('\t%.2f',1,length(compartments)) '\r\n'], compartment_pH);
fprintf(fid, ['Ionic strength (M)' repmat('\t%.2f',1,length(compartments)) '\r\n'], compartment_I);
fprintf(fid, ['Electrical potential relative to cytosol (mV)' repmat('\t%.2f',1,length(compartments)) '\r\n'], compartment_phi);
fclose(fid);

% Reaction tab
fid = fopen(reactionTab,'w+');
fprintf(fid, 'Reaction ID\tStandard reaction Gibbs energy (kJ/mol)\tUncertainty corresponding to 95%% confidence interval (kJ/mol)\tStandard transformed reaction Gibbs energy (kJ/mol)\tMinimum transformed reaction Gibbs energy (kJ/mol)\tMaximum transformed reaction Gibbs energy (kJ/mol)\r\n');
for n = 1:length(rxnID)
    fprintf(fid, '%s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\r\n', rxnID{n}, DrG0(n), DrGt0_Uncertainty(n), DrGt0(n), DrGtMin(n), DrGtMax(n));
end
fclose(fid);

% Metabolite tab
fid = fopen(metaboliteTab,'w+');
fprintf(fid, 'Metabolite ID\tStandard Gibbs energy of formation (kJ/mol)\tUncertainty corresponding to 95%% confidence interval (kJ/mol)\tStandard transformed Gibbs energy of formation (kJ/mol)\tMinimum transformed Gibbs energy of formation (kJ/mol)\tMaximum transformed Gibbs energy of formation (kJ/mol)\tMinimum concentration (M)\tMaximum concentration (M)\r\n');
for n = 1:length(metID)
    fprintf(fid, '%s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2e\t%.2e\r\n', metID{n}, DfG0(n), DfG0_Uncertainty(n), DfGt0(n), DfGtMin(n), DfGtMax(n), concMin(n), concMax(n));
end
fclose(fid);
end

%old code
%     %print out each metabolite in turn
%     fid=fopen('MetabolitesTab.txt','w');
%     fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
%         'Abbreviation','Name','dGft0Source','AlbertyAbbreviation','dGft0_Alberty',...
%         'dHft0_Alberty','Average charge','Average H bound','dGf0_GroupCont','dGft0_GroupCont',...
%         'dGft0_GroupContUncertainty','chargeMarvin','formulaMarvin');
%     for m=1:nMet
%         if strcmp(model.mets{m},'acorn[c]')
%             pause(eps)
%         end
%         %round to one decimal place in tables
%         fprintf(fid,'%s\t%s\t%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%s',...
%             model.mets{m},...
%             model.metNames{},...
%             model.concMin,...
%             model.DfGtMin,...
%             model.DfGtMax,...
%             model.met(m).aveZi,...
%             model.met(m).aveHbound,...
%             model.met(m).dGf0GroupCont,...
%             model.met(m).dGft0GroupCont,...
%             model.met(m).dGft0GroupContUncertainty,...
%             model.met(m).chargeMarvin,...
%             model.met(m).formulaMarvin);
%         fprintf(fid,'\n');
%     end
%     fclose(fid);
%
%     %print out each reaction in turn and its directionality
%     fid=fopen('ReactionsTab.txt','w');
%     fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
%         'Abbreviation','Name','Equation','Qualitative Direction','Quantitative direction (1st pass)',...
%         'dGt0Min','dGt0Max','dGtmMin','dGtmMax','dGtMin','dGtMax');
%     for n=1:nRxn
%         if strcmp(model.rxns{n},'PNS1')
%             pause(eps)
%         end
%         %round to one decimal place in tables
%         if isfield(model.rxn(n),'dGtmMin')
%             fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\n',...
%                 model.rxns{n},...
%                 model.rxn(n).officialName,...
%                 model.rxn(n).equation,...
%                 model.rxn(n).directionality,...
%                 model.rxn(n).directionalityThermo,...
%                 model.rxn(n).dGt0Min,...
%                 model.rxn(n).dGt0Max,...
%                 model.rxn(n).dGtmMin,...
%                 model.rxn(n).dGtmMax,...
%                 model.rxn(n).dGtMin,...
%                 model.rxn(n).dGtMax);
%         else
%                 fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\n',...
%                 model.rxns{n},...
%                 model.rxn(n).officialName,...
%                 model.rxn(n).equation,...
%                 model.rxn(n).directionality,...
%                 model.rxn(n).directionalityThermo,...
%                 model.rxn(n).dGt0Min,...
%                 model.rxn(n).dGt0Max,...
%                 NaN,...
%                 NaN,...
%                 model.rxn(n).dGtMin,...
%                 model.rxn(n).dGtMax);
%
%         end
%     end
%     fclose(fid);
