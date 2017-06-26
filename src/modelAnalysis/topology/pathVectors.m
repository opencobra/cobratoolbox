
function [output] = pathVectors(model, directory, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code can be used to compute elementary mode and extreme pathway 
% (convex basis) of an arbitrary COBRA model by the CNA software 
% package.
%
% INPUT           :
% model           :    COBRA model
% directory       :    A path that CNA model is going to be saved there
% constraints     :    empty 
%                      cnap.numr
%                      many rows and up to 4 columns:
%                   -  COLUMN1 specifies excluded/enforced reactions: if
%                      (constraints(i,1)==0) then onlythose modes / rays 
%                      / points will be computed that do not include 
%                      reaction i; constraints(i,1)~=0 and
%                      constraints(i)~=NaN enforces reaction i, i.e. only  
%                      those modes / rays / points will be computed that
%                      involve reaction i; for all other reactions choose
%                      constraint(i,1)=NaN; several reactions may be 
%                      suppressed/enforced simultaneously
%                   -  COLUMN2: specifies lower boundaries for the 
%                      reaction rates (choose NaN if none is active).
%                      Note that zero boundaries (irreversibilities) are
%                      better described by cnap.reacMin. In any case, the
%                      lower boundary eventually considered will be zero 
%                      if cnap.reaMin(i)==0 and constraints(i,2)<0.
%                   -  COLUMN3: specifies upper boundaries for the 
%                      reaction rates (choose NaN if none is active)
%                   -  COLUMN4: specifies equalities for the reaction 
%                      rates (choose NaN if none is active). 
% mexVersion      :    (default:4)
%                   1, CNA mex files,
%                   2, Metatool mex files,
%                   3, CNA and Metatool mex files
%                   4, Marco Terzer's EFM tool  
%
% irrevFlag      :    (default: 1)
%                   0, reversible
%                   1, irreversible
%
% convBasisFlag  :    (Default: 0)
%                   0, elementary modes
%                   1, extreme pathways
%
% isoFlag        :    (default: 0)
%                   0, not consider isoenzymes
%                   1, consider isoenzymes
%
% cMacro         :    (default: cnap.macroDefault)
%                      empty
%                      cnap.macroComposition
                      
% printLevel         :    (default: 'All')
%                      'None'
%                      'Iteration'
%                      'All'
%                      'Details'
%     
% efmToolOptions :    (default: {})
%                      'arithmetic'
%                      'fractional'
%                      'compression'
%                      'off'
% positivity      : 0, normal convex basis
%                   1, positive convex basis
%
% OUTPUT          :
% efm             :    matrix that contains (row-wise) the elementary
%                      modes (or elemenatry vectors) or a minimal set
%                      of generators (lineality space + extreme rays/
%                      points), depending on the chosen scenario. The
%                      columns  correspond to the reactions; the column
%                      indices of efms (with respect to the columns in
%                      cnap.stoichMat) are stored in the returned 
%                      variable idx (see below; note that columns are
%                      removed in efms if the corresponding reactions
%                      are not contained in any mode) %
%
% rev             :    vector indicating for each mode whether it is 
%                      reversible(0)/irreversible (1)
%
% idx             :    maps the columns in efm onto the column indices
%                      in cnap.stoichmat, i.e. idx(i) refers to the 
%                      column number in cnap.stoichmat (and to
%	                   the row number in cnap.reacID)
%
% ray             :    indicates whether the i-th row (vector) in efm
%                      is an unbounded (1) or bounded (0) direction 
%                      of the flux cone / flux polyhedron. Bounded
%                      directions (such as extreme points) can only
%                      arise if an inhomogeneous problem was defined
%                      (see also above for 'constraints').
% cbmodel         :    If the input model be changed during computations 
%                      then the new model will be saved as cbmodel (COBRA
%                      model)
%
% Code by         : 
%                      Susan Ghaderi, Systems Biochemistry Group, LCSB,
%                      University of Luxembourg.
%
%
% Last update     :
%                       06.06.2017
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% default value of varargin

constraints = [];
positivity = 0;
mexVersion = 4;
irrevFlag = 1;
convBasisFlag = 0;
isoFlag = 0;
cMacro = 0;
efmToolOptions = {};
display = 'None';

%% varargin checking 
if numel(varargin) > 1 
    for i = 1:2:numel(varargin)
        key = varargin{i};
        value = varargin{i+1};
        switch key
            case 'constraints'
                constraints = value;
            case 'positivity'
                positivity = value;
            case 'mexVersion'
                mexVersion = value;
            case 'irrevFlag'
                irrevFlag = value;
            case 'convBasisFlag'
                convBasisFlag = value;
            case 'isoFlag'
                isoFlag = value;
            case 'cMacro'
                cMacro = value;
            case 'efmToolOptions'
                efmToolOptions = value;
            case 'display'
                display = value;
            otherwise
                msg = sprintf('Unexpected key %s',key)
                error(msg);
        end

    end
end

%% Error checking
if mexVersion~=1 && mexVersion~=2 && mexVersion~=3 && mexVersion~=4
    error('mexversion should be either 1 or 2 or 3 or 4');
end

if irrevFlag~=0 && irrevFlag~=1
    error('irrev_flag should be either 0 or 1');
end

if convBasisFlag~=0 && convBasisFlag~=1
    error('convbasis_flag should be either 0 or 1');
end

if isoFlag~=0 && isoFlag~=1
    error('iso_flag should be either 0 or 1');
end

if positivity~=0 && positivity~=1
    error('positivity should be either 0 or 1');
end

%% Convertining reversible reactions into irreversible reactions 
if positivity
       
    ind = model.rev==1;
    rev = [model.rev; model.rev(ind)];
    rxns = strcat(model.rxnNames(ind), '-rev');
    c = [model.c; model.c(ind)];
    model.S = [model.S, -model.S(:,ind)];
    model.lb = zeros(length(model.rev)+length(model.rev(ind)),1);
    model.ub = [model.ub; Inf*ones(size(model.lb(ind),1),1)];
    model.rxns = [model.rxns; rxns];
    model.c = [model.c; zeros(length(model.rev(ind)),1)];
    model.rxnNames = [model.rxnNames; rxns];
    
end

%% converting a cobra model to CNA model 
cnap      = CNAcobra2cna(model);
cnap.path = directory;
cnap      = CNAsaveNetwork(cnap);


%% computing convex basis or elementary modes 
[output.efm,rev,idx,ray] = CNAcomputeEFM(cnap,constraints,mexVersion,...
                                         irrevFlag,convBasisFlag,...
                                         isoFlag,cMacro,display,...
                                         efmToolOptions);
%% export CNA model to COBRA model              
cbmodel           = CNAcna2cobra(cnap);                

%% OUTPUT 
output.rev   = rev;
output.idx   = idx;
output.ray   = ray;
output.model = cbmodel;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
