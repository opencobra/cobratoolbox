function rxnFBS = diffexprs2rxnFBS(model, diff_exprs, Vref, separate_transcript, logFC, pval)
% Returns Forward - Backward - Unchanged (+1;0;-1) information of whatever 
% a reaction associated to this gene should increase in Forward direction
% or decrease inBackward direction (1), decrease or increase in Backward 
% direction (-1) or remain unchanged.
% (+1)R_f    (-1)R_b     (0)unchanged
%
% USAGE:
%
%    rxnFBS = diffexprs2rxnFBS(model, diff_exprs, Vref, separate_transcript, logFC, pval)
%
% INPUT:
%    model:             The COBRA Model structure
%    diff_exprs:        MATLB Table including the information of the
%                       differentially expressed genes.
%                       Required columns (with this names):
%                           - gene ( ID of gene, same as in model)
%                           - logFC (Study must be SOURCE VS TARGET)
%                           - pval (p-value or adjusted-p-value)     
%    Vref:              Reference flux of the model
%
% OPTIONAL INPUT:
%    separate_transcript:   Character used to separate
%                           different transcripts of a gene. (default: '').
%    logFC:             minimum log2 (fold change) requiered (default = 0).
%    pval:              maximum p-value admited (default = 0.05).
%
% OUTPUT:
%    rxnFBS             array containting the information of the changed 
%                       reactions. It has Forward - Backward - Unchanged 
%                       (+1;0;-1) values corresponding to each reaction;
% 
% Note:
%    It is highly recommended to use as diff_exprs the TopTable result from
%    limma in R and change names if neccesary
%    In the tutorial there is further information to load data from GEO or
%    using R to calculate the absolute gene expression and the differential
%    expression.
%
% .. Authors:
%       - Luis V. Valcarcel, 25/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.

% if no separate_transcript requered, default = ''
if ~exist('separate_transcript','var')
    separate_transcript = '';
end

% if no logFC requered, default = 0
if ~exist('logFC','var')
    logFC = 0;
end

% if no p-value requered, default = 0.05
if ~exist('pval','var')
    pval = 0.05;
end

% Traduce onmic data from gene level to reaction level
if ~isempty(separate_transcript)
    aux_table = table(strtok(model.genes,separate_transcript),model.genes,'VariableNames',{'gene' 'transcript'});
    diff_exprs = innerjoin(aux_table, diff_exprs, 'Keys','gene');
	diff_exprs.gene = diff_exprs.transcript;
end

% Minimun Fold Change to admit the changes
idx = abs(diff_exprs.logFC)>logFC;
diff_exprs = diff_exprs(idx,:);

% Maximum p-value to admit the changes
idx = abs(diff_exprs.pval)<=pval;
diff_exprs = diff_exprs(idx,:);

pos_up = diff_exprs.logFC > 0;     % source state bigger than target state
pos_down = diff_exprs.logFC < 0;   % source state smaller than target state

% As we cannot map the reaction to genes, we can discretize this values as
% (+1, 0 -1), to create geneFBS
geneFBS_aux = zeros(size(diff_exprs,1),1);
geneFBS_aux(pos_up) = +1;
geneFBS_aux(pos_down) = -1;

% Generate geneFBS for all genes in the model
geneFBS = zeros(length(model.genes),1);
[~,idx] = ismember(diff_exprs.gene,model.genes);
geneFBS(idx) = geneFBS_aux;

% If the source state has a gene whose expression is reduced compared with
% the target state, the flux activity related with this gene should
% increase to be transformated into the target state. 
% We can appreciate that if a gene is differentially expressed up, gene
% should be reduced, and viceverse: if the gene is differentially expressed
% down, it should increase
% For this reason we change the sign of geneFBS
geneFBS = -geneFBS;

% Change to Cobra format
geneFBS = struct('gene',{model.genes},'value',geneFBS);

if isempty(separate_transcript)
    fprintf('\tGene expression changes calculated\n');
    fprintf('\tThere are %u genes that are differentially expressed\n',sum(geneFBS.value~=0));
else
    fprintf('\tGene expression changes calculated\n');
    fprintf('\tThere are %u trainscripts that are differentially expressed\n',sum(geneFBS.value~=0));
    [~,idx] = unique(strtok(geneFBS.gene,separate_transcript));
    fprintf('\tThere are %u genes that are differentially expressed\n',sum(geneFBS.value(idx)~=0));
end

% Transform geneFBS into rxnFBS
% in order to produce changes, all changes must be in the same sense

% Calculate changes to produce more flux
geneFBS_plus = geneFBS;
geneFBS_plus.value(geneFBS_plus.value<=0) = 0;
rxnFBS_plus = mapExpressionToReactions(model, geneFBS_plus);  % COBRA function

% Calculate changes to produce less flux
geneFBS_minus = geneFBS;
geneFBS_minus.value(geneFBS_minus.value>=0) = 0;
geneFBS_minus.value(geneFBS_minus.value<0) = +1;
rxnFBS_minus = mapExpressionToReactions(model, geneFBS_minus);  % COBRA function

% all changes in same sense or they neglect each other
rxnFBS_plus(rxnFBS_plus<=0) = 0;
rxnFBS_minus(rxnFBS_minus<=0) = 0;
rxnFBS = rxnFBS_plus - rxnFBS_minus;
rxnFBS(strcmp(model.grRules,'')) = 0; % not mapped reactions have no change in activity


% We have considered all reactions as Forward reactions. GeneFBS gives the
% informatio whatever a reaction should increase activity in absolute
% values. 
% For Forward reactions, (+1) increase flux, (-1) decrease flux
% For Forward reactions, (+1) decrease flux (increase in absolute values), 
% (-1) increase flux, (decrease in absolute values)
rxnFBS(Vref < 0) = - rxnFBS(Vref < 0);
fprintf('\tReaction expression changes calculated\n');
fprintf('\tThere are %u reactions that are differentially expressed\n',sum(rxnFBS~=0));

end

