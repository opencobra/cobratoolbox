%test lusol_mex with stoichiometric matrix from iAF120
%clear
if ~exist('iAF1')
    load('/home/rfleming/workspace/Stanford/convexFBA/data/iAF1260')
end
A=iAF1.S;

%initialaize
mylu = lusol(A);

%default options
[inform nsing depcol] = mylu.factorize(A);
disp(inform)
%matrices
L = mylu.L0();
U = mylu.U();
% row permutation
p = mylu.p();
% column permutation
q = mylu.q();

%options
options64 = lusol.luset();
options64.Ltol1 = 1.5;
options64.pivot  = 'TRP';
options64.nzinit = 50000;
mylu = lusol(A,options64);
stats = mylu.stats()
%matrices
L = mylu.L0();
U = mylu.U();
% row permutation
p = mylu.p();
% column permutation
q = mylu.q();

if 0
    %old options
    %options.FactorTol = 1.5;
    %64 bit options
    options64.Ltol1 = 1.5;
    
    % ??? Error using ==> sparse
    % Index into matrix must be positive.
    %
    % Error in ==> lusol>lusol.U at 727
    %       U = sparse(ui,uj,ua,m,n);
    %
    % Error in ==> test_lusol_mex at 30
    
    %Are FactorTol and Ltol1 the same???????????
end

[inform nsing depcol] = mylu.factorize(A,options64);
disp(inform)
%matrices
L = mylu.L0();
U = mylu.U();
% row permutation
p = mylu.p();
% column permutation
q = mylu.q();