function statusOK = testGDLS()
%testGDLS tests the functionality of GDLS.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

%load model
load('ecoli_core_model.mat');

%Set conditions to anaerobic and glucose uptake of 20
model = changeRxnBounds(model,{'EX_o2(e)','EX_glc(e)'},[0 -20],'l');

% Select reactions that can be knocked out
selectedRxns = {model.rxns{1},model.rxns{3:5},model.rxns{7:8}, ...
    model.rxns{10},model.rxns{12},model.rxns{15:16},model.rxns{18}, ...
    model.rxns{40:41},model.rxns{44},model.rxns{46},model.rxns{48:49}, ...
    model.rxns{51},model.rxns{53:55},model.rxns{57},model.rxns{59:62}, ...
    model.rxns{64:68},model.rxns{71:77},model.rxns{79:83}, ...
    model.rxns{85:86},model.rxns{89:95}}';

%run GDLS
[gdlsSolution] = GDLS(model, 'EX_succ(e)', 'minGrowth', 0.05, 'selectedRxns', selectedRxns, 'maxKO', 5, 'nbhdsz', 3);

%check solution
if length(gdlsSolution.KOs)==5 && all(ismember(gdlsSolution.KOs,{'ACALD';'ALCD2x';'GLUDy';'LDH_D';'PFL';'THD2'}))
    statusOK = 1;
else
    statusOK = 0;
end

%return to original directory
cd(oriDir);