if 1
    clear
    load('FRresults_20150529T145822.mat')
    model=FRresults(21).model;
end

[nMet,nRxn]=size(model.S);

%vanilla forward and reverse half stoichiometric matrices
F       = -model.S;
F(F<0)  =    0;
R       =  model.S;
R(R<0)  =    0;

%metaboliteList={'sphgn[r]','hexccoa[r]','ttccoa[r]','psphings[r]','pi[r]','cer1_24[r]','cer1_26[r]','sph1p[r]'}';
metaboliteList={'ttccoa[r]','hexccoa[r]','pi[r]','psphings[r]','sphgn[r]'};

boolRxns=false(nRxn,1);
boolMets=false(nMet,1);
for z=1:length(metaboliteList)
    boolMet=strcmp(model.mets,metaboliteList{z});
    if model.FRrows(boolMet)==0
        error('not metabolite in proper FR')
    end
    boolMets= boolMets | boolMet;
    boolRxn=(model.S(boolMet,:)~=0)';
    boolRxns=boolRxns | (boolRxn & model.FRVcols);
    if 0
        fprintf('%s\n',metaboliteList{z})
        formulas = printRxnFormula(model,model.rxns(bool),1,1);
        fprintf('\n')
    end
end
metaboliteList2=model.mets(boolMets);
reactionList=model.rxns(boolRxns);

if 1
    model.mets(boolMets)
    %model.rxns(boolRxns)
    FRsubset1=[F(boolMets,boolRxns), R(boolMets,boolRxns)];
    full(FRsubset1)
    rank(full(FRsubset1))
    [rankFR,p,q]=getRankLUSOL(FRsubset1);
    iR=metaboliteList2(p(1:rankFR))
    full(FRsubset1(p(1:rankFR),:))
    dR=metaboliteList2(p(rankFR+1:length(p)))
end

formulas = printRxnFormula(model,model.rxns(boolRxns),1,1);

FRsubset=[F(boolMets,boolRxns), R(boolMets,boolRxns)];
[rankFR,p,q]=getRankLUSOL(FRsubset);
iR=metaboliteList2(p(1:rankFR))
full(FRsubset(p(1:rankFR),:))
dR=metaboliteList2(p(rankFR+1:length(p)))
full(FRsubset(p(rankFR+1:length(p)),:))
fprintf('%s\n',[int2str(size(FRsubset,1)) ' x ' int2str(size(FRsubset,2)) ' FR subset of rank ' int2str(rankFR) ' according to LUSOL.'])
%full([F(strcmp(model.mets,'pi[r]'),boolRxns), R(strcmp(model.mets,'pi[r]'),boolRxns)])
%full([F(strcmp(model.mets,'sphgn[r]'),boolRxns), R(strcmp(model.mets,'sphgn[r]'),boolRxns)])


%code below reproduces the LUSOL problem with zero columns
if 0
A=FRsubset;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('%s\n','----------------------------------------------')
disp(full(A))
%modification of default options
options.pivot  = 'TRP';
options.Ltol1 = 1.5;
options.nzinit = 1e7;
%factorise
mylu = lusol_obj(A,options);
%extract results
stats = mylu.stats();
%matrices
L = mylu.L0();
U = mylu.U();
% row permutation
p = mylu.p();
% column permutation
q = mylu.q();
%rank
rankA=mylu.rank();

fprintf('%s\n','----------------------------------------------')
disp(full(A(:,7:12)))
%modification of default options
options.pivot  = 'TRP';
options.Ltol1 = 1.5;
options.nzinit = 1e7;
%factorise
mylu = lusol_obj(A(:,7:12),options);
%extract results
stats = mylu.stats();
%matrices
L = mylu.L0();
U = mylu.U();
% row permutation
p = mylu.p();
% column permutation
q = mylu.q();
%rank
rankA2=mylu.rank();

fprintf('%s\n',[int2str(size(FRsubset,1)) ' x ' int2str(size(FRsubset,2)) ' FR subset of rank ' int2str(rankA) ' according to LUSOL.'])
fprintf('%s\n',[int2str(size(A(:,7:12),1)) ' x ' int2str(size(A(:,7:12),2)) ' FR subset of rank ' int2str(rankA2) ' according to LUSOL.'])
fprintf('%s\n',[int2str(size(A(:,7:12),1)) ' x ' int2str(size(A(:,7:12),2)) ' FR subset of rank ' int2str(rankA2) ' according to LUSOL.'])
[rankA3,p,q] = getRankLUSOL(A);
fprintf('%s\n',[int2str(size(FRsubset,1)) ' x ' int2str(size(FRsubset,2)) ' FR subset of rank ' int2str(rankA3) ' according to matlab.'])
end
        