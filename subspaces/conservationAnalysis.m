function [L,N,Lzero,Nzero,Pl,Pn,iR,dR,iC,dC,rankS]=conservationAnalysis(model,massBalanced,printLevel,tol)
% Returns the left and right nullspaces of a given stoichiometric matrix
% in echelon form.
% i.e.  L*S = 0 where [-Lzero I]*Pl'*S = 0;
%       and
%       S*N = 0 where S*Pn*[-Nzero; I]=S*[-Nzero' I']*Pn' = 0; 
%
% See: Conservation analysis of large biochemical networks
% Ravishankar Rao Vallabhajosyula , Vijay Chickarmane and Herbert M. Sauro
% 
%INPUT
% model.S                   m x n stoichiometric matrix
%
%OPTIONAL INPUT
% massBalanced      {(0),1,-1}  0 = conservation analysis of entire model.S
%                               1 = conservation analysis of mass balanced reactions only
%                              -1 = conservation analysis of all except biomass reaction
%
% model.SIntRxnBool         boolean vector indicating mass balanced
%                           reactions only. Optional if conservation
%                           analysis of massBalanced reactions only as
%                           otherwise findSExRxnInd will be used to find
%                           the mass imbalanced reactions
% 
% model.biomassRxnAbbr      String with abbreviation of biomass reaction
% model.c                   n x 1 linear objective function
% 
% printLevel    {(0),1}     0 = Silent
%                           1 = Print out conservation relations using metabolite and reaction
%                           abbreviations
% model.mets    m x 1 cell array of metabolite abbreviations
% model.rxns    n x 1 cell array of reaction abbreviations
% 
% tol           upper bound on tolerance of linear independence,default
%               no greater than 1e-12
% 
%OUTPUT
% L             Echelon form Left nullspace of S
% N             Echelon form Right nullspace of S
% iR            Boolean index of Independent rows
% dR            Boolean index of Dependent rows
% iC            Boolean index of Independent columns
% dC            Boolean index of Dependent columns
%
% Ronan M.T. Fleming

if ~exist('massBalanced','var')
    massBalanced=0;
end
if ~exist('printLevel','var')
    printLevel=0;
end

[nMet,nRxn]=size(model.S);
switch massBalanced
    case 1
        if ~isfield(model,'SIntRxnBool');
            model=findSExRxnInd(model,nMet);
        end
        model.S=model.S(:,model.SIntRxnBool);
        if printLevel>0
            model.rxns=model.rxns(model.SIntRxnBool);
        end
        
    case -1
        %locate biomass reaction if there is one
        biomassBool=false(nRxn,1);
        if ~isfield(model,'biomassRxnAbbr')
            if 0
                fprintf('%s\n','No model.biomassRxnAbbr ? Give abbreviation of biomass reaction if there is one.');
            else
                %tries to identify biomass reaction from linear objective
                bool=model.c~=0;
                if nnz(bool)==1
                    model.biomassRxnAbbr=model.rxns{model.c~=0};
                    fprintf('%s%s\n','Assuming biomass reaction is: ', model.biomassRxnAbbr);
                    biomassBool(bool)=1;
                else
                    if nnz(bool)==0
                        fprintf('%s\n','No model.biomassRxnAbbr ? Give abbreviation of biomass reaction if there is one.');
                    else
                        error('More than one biomass reaction?');
                    end
                end
            end
        else
            bool=strcmp(model.biomassRxnAbbr,model.rxns);
            if nnz(bool)==1
                fprintf('%s%s\n','Found biomass reaction: ', model.biomassRxnAbbr);
            else
                error('More than one biomass reaction?');
            end
            biomassBool(bool)=1;
        end
        model.SIntRxnBool=model.SIntRxnBool(~biomassBool);
        model.S=model.S(:,~biomassBool);
        model.rxns=model.rxns(~biomassBool);
end
[nMet,nRxn]=size(model.S);
S=model.S;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%metabolites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%qr factorisation
%for full matrix S', produces a permutation matrix P, an upper triangular
%matrix R with decreasing diagonal elements, and a unitary matrix Q 
%so that S'*P = Q*R, or S = P*R'*Q'
%The column permutation P is chosen so that abs(diag(R)) is decreasing.
[Q,R,Pl]=qr(full(S'));

%if tol not provided, compute the tolerance on non-zero diagonals of R
if ~exist('tol','var')
    %from matlab help
    tol = max(size(S))*eps*abs(R(1,1));
    %1e-15 is asking too much
    if tol<1e-12
        tol=1e-12;
    end
end
rankS  = length(find(abs(diag(R)) > tol));

fprintf('\n%s\n',['#met        ' int2str(nMet)])
fprintf('%s\n',['#rxn        ' int2str(nRxn)])
fprintf('%s\n',['Rank(S)     ' int2str(rankS)])
        
[nlt,mlt]=size(R);
%all of the rows below the first rankS non-zero rows should contain only
%zeros and reflect the dependencies in the network
R(abs(R)<tol)=0;

%scale each nonzero row such that there is unity along the main diagonal
for n=1:rankS
    R(n,:)=R(n,:)/R(n,n);
end

%Gauss-Jordan elimination produces a reduced row echelon form
[IM,rf]=rref(R(1:rankS,:));

% R =[I M;
%     0 0]
R=zeros(nlt,mlt);
R(1:rankS,:)=IM;

%separate parts of R
I=IM(:,1:length(rf));
M=IM(:,length(rf)+1:end);

%Reduced left null space?
Lzero = M';

%link matrix is transpose of the reduced row form of R
xLink = [I;Lzero];

% conservationMatrix=[-Lzero,I];
%i.e. Echelon form left null space of S
L=[-Lzero, speye(nMet-rankS)];

%original order of species
originalOrder=[1:nMet];
%in the new order of species the first rankS species are the independent species
newOrder=originalOrder*Pl;

%conserved pools
if printLevel
    [na,nb]=size(L);
    fprintf('%s\n','Conserved pools:')
    if 0
        names=cell(nMet,1);
        for m=1:nMet
            names{m}=['m' int2str(newOrder(m))];
        end
    else
        names=model.mets(newOrder);
    end
    for a=1:na
        for b=1:nb
            if abs(L(a,b))>tol
                fprintf('%s',' ');
                if (abs(L(a,b))-1)>tol
                    fprintf('%s%s%s',num2str(L(a,b)),'*',names{b});
                else
                    fprintf('%s',names{b});
                end
            end
        end
        fprintf('\n');
    end
end

%boolean indexing
indepRow=false(nMet,1);
depRow=false(nMet,1);
indepRow(newOrder(1:rankS))=1;
depRow(newOrder(rankS+1:mlt))=1;

%return L corresponding to the order of the rows in the imput S matrix
L=L*Pl';

if 1
    fprintf('%s\n',['Coefficients in left null space < ' num2str(tol) ' set to zero'])
    L(abs(L)<tol)=0;
    Lzero(abs(Lzero)<tol)=0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fluxes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%qr factorisation
%for full matrix S, produces a permutation matrix P, an upper triangular
%matrix R with decreasing diagonal elements, and a unitary matrix Q 
%so that S*P = Q*R, S' = P*R'*Q', S = Q*R*P'  
%The column permutation P is chosen so that abs(diag(R)) is decreasing.
[Q,R,Pn]=qr(full(S));

[mlt,nlt]=size(R);
%all of the rows below the first rankS non-zero rows should constain only
%zeros and reflect the dependencies in the network
R(abs(R)<tol)=0;

%scale each nonzero row such that there is unity along the main diagonal
for n=1:rankS
    R(n,:)=R(n,:)/R(n,n);
end

%Gauss-Jordan elimination produces a reduced row echelon form
[IM,rf]=rref(R(1:rankS,:));

% R =[I M;
%     0 0]
R=zeros(mlt,nlt);
R(1:rankS,:)=IM;

%separate parts of R
I=IM(:,1:length(rf));
M=IM(:,length(rf)+1:end);

%Right nul
Nzero = M;

%flux link matrix is transpose of the reduced row form of R
vLink = [I Nzero];

% conservationMatrix=[-Nzero,I];
%i.e. Echelon form right null space of S, in new row order
N = [-Nzero;speye(nRxn-rankS)];

%original order of fluxes
originalOrder = [1:nRxn];
%new order of fluxes
newOrder = originalOrder*Pn;

%boolean indexing
indepCol=false(nRxn,1);
depCol=false(nRxn,1);
%the first rankS fluxes are the independent fluxes
indepCol(newOrder(1:rankS))=1;
depCol(newOrder(rankS+1:nlt))=1;

%return N corresponding to the order of the columns in the imput S matrix
N = Pn*N;

%correlated fluxes?
if printLevel
    [na,nb]=size(N);
    fprintf('%s\n','Correlated fluxes?:')
    names=cell(nRxn,1);
    if 0
        for n=1:nRxn
            names{n}=['v' int2str(n)];
        end
    else
        names=model.rxns;
    end
    for b=1:nb
        for a=1:na
            if abs(N(a,b))>tol
                fprintf('%s',' ');
                if (abs(N(a,b))-1)>tol
                    fprintf('%s%s%s',int2str(N(a,b)),'*',names{a});
                else
                    fprintf('%s',names{a});
                end
            end
        end
        fprintf('\n');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%shorthand for boolean indices of different rows
iR  = indepRow;       %Boolean index of Independent rows
dR  = depRow;         %Boolean index of Dependent rows
iC  = indepCol;       %Boolean index of Independent columns
dC  = depCol;         %Boolean index of Dependent columns

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%checking conserved pools are correct
[Q,R,P]=qr(Pl'*S);
% Q(1:rankS,1:rankS) from reordered S should be non-singular so should be
% invertible
Lzero2=mrdivide(Q(rankS+1:mlt,1:rankS),Q(1:rankS,1:rankS)); 
if max(max(Lzero-Lzero2))>tol
    fprintf('%s\n','Lzero: QR check failed');
end

%checking correlated fluxes are correct
[Q,R,P]=qr(Pn'*S');
% Q(1:rankS,1:rankS) is singular to working precision so not invertible
Nzero2=mrdivide(Q(rankS+1:nlt,1:rankS),Q(1:rankS,1:rankS)); 
if max(max(Nzero-(Nzero2')))>tol
    fprintf('%s\n','Nzero: QR check failed');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%