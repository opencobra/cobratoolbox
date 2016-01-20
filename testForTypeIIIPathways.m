function testForTypeIIIPathways(model,ListExch,filename)
%testForTypeIIIPathways Set up the model to run extreme pathway analysis 
%(expa) for identifying loops in the model (Type III pathways) and runs expa.
%
% TestForTypeIIIPathways(model,ListExch)
%
%INPUTS
% model     COBRA model structure
% ListExch  List of position of exchange reactions in S matrix
%
%
% Ines Thiele   02/09

warning off all
if nargin < 3
    filename = 'ModelTestTypeIII';
end

% set exchange constraints to 0
model.lb(ListExch)=0;
model.ub(ListExch)=0;

tol = 1e-10;

% flux variability analysis
cnt=1;
for i = 1:size(model.lb,1)
    model.c(logical(model.c)) = 0;
    model.c(i,1) = 1;
    solMax=optimizeCbModel(model,'max');
    SolMin=optimizeCbModel(model,'min');
    MinMax(i,:)=[SolMin.f solMax.f];
    if (SolMin.f==solMax.f && abs(SolMin.f) <= tol)
        rxnzero(cnt,1)=i;
        cnt=cnt+1;
    end
    if (SolMin.f<0)
        model.rev(i)=1;
    else
        model.rev(i)=0;
    end
end

% write expa file
convertModelToEX(model,strcat(filename, '.expa'),rxnzero,model.rxns(ListExch));

% run expa analysis
[status,result] = dos(['X3 -p ' strcat(filename, '.expa')]);

if strfind(result,'ERROR')>0
    fprintf('\n Error with X3.exe:\n');
    fprintf('%s\n',result);
else
    % check if Type III pathways were found
    if result(strfind(result,'There are ') + length('There are ')) > 0
        fprintf('Type III pathways were found in model. A table of Type III pathways can be found in ');
        fprintf('%s',strcat(filename,'_myT3.txt'));
        fprintf(' or as  Sparse format in ');
        fprintf('%s',strcat(filename,'_myT3_Sprs.txt'));
    else
        fprintf('No Type III pathways can be found in model.');
        dos(['rm ' strcat(filename,'_myT3_Sprs.txt') strcat(filename,'_myT3.txt') strcat(filename,'_myRxnMet.txt')]);
    end
    % clean up files
    dos(['del ' strcat(filename,'_myPaths.txt') ' ' strcat(filename,'_myPaths_sparse.txt')]);
end
