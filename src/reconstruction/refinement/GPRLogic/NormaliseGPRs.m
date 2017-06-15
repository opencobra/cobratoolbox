function Outmodel = NormaliseGPRs(model,geneRegExp)
% Bring all GPRS into a DNF form and reduce them to the minimal DNF Form
% USAGE:
%
%    Outmodel = NormaliseGPRs(model,geneRegExp)
%
% INPUTS:
%
%    model:       The Model to convert the GPRs
%    geneRegExp:  A Regular expression matching the genes in the model.
% 
% OUTPUTS:
%    Outmodel:    The output model with all GPRS in minimal DNF form.
%
% .. Authors:
%    - Thomas Pfau 2016

gprs = model.rules;
FP = FormulaParser();
newgprs = cell(numel(gprs),1);
newrules = cell(numel(gprs),1);
for i = 1:numel(gprs)
    if strcmp(gprs{i},'') || isempty(gprs{i})
        newgprs{i} = '';
        newrules{i} = '';
        continue
    end
    fprintf('Currently calculating GPR #%i: \n %s\n',i,gprs{i});
    Head = FP.parseFormula(gprs{i});
    Head.reduce();    
    NewHead = Head.convertToDNF();    
    NewHead.reduce();
    if isa(NewHead,'OrNode')
        NewHead.removeDNFduplicates();
    end
    newrules{i} = NewHead.toString(1);    
end
Outmodel = model;
Outmodel.rules = newrules;
Outmodel = creategrRulesField(Outmodel);

end