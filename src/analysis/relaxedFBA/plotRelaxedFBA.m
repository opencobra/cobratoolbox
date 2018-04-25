function plotRelaxedFBA(sol, model,tol)

if sol.stat ~= 1
    disp('relaxedFBA did not complete successfully, nothing to display');
    disp('relaxedFBA problem infeasible, check relaxOption fields');
    return
end

if ~exist('tol','var')
    %Set the tolerance to distinguish between zero and non-zero flux
    feasTol = getCobraSolverParams('LP', 'feasTol');
    tol=feasTol*100;
end

%useful for numerical debugging
if 0
    tol=0;
end

optTol = getCobraSolverParams('LP', 'optTol');
sol.p(abs(sol.p)<optTol*10)=0;
sol.q(abs(sol.q)<optTol*10)=0;

if norm(model.S*sol.v-model.b)>optTol*10
    warning(['relaxedFBA relaxed steady state constraints too much, norm(S*v-b)= ' num2str(norm(model.S*sol.v-model.b))])
end

[v,r,p,q] = deal(sol.v,sol.r,sol.p,sol.q);

p(p<tol) = 0;%lower bound relaxation
q(q<tol) = 0;%upper bound relaxation
r(abs(r)<tol) = 0;%steady state constraint relaxation

%Summarise the proposed relaxation sol
printFlag=0;
lineChangeFlag=0;

[nMet,nRxn]=size(model.S);

%totals
fprintf('%u%s\n',nnz(r),' steady state constraints relaxed');
fprintf('%u%s\n',nnz(p & q & model.SIntRxnBool),' internal lower and upper bounds relaxed');
fprintf('%u%s\n',nnz(p & q & ~model.SIntRxnBool),' external lower and upper bounds relaxed');
fprintf('%u%s\n',nnz(p | q & ~model.SIntRxnBool),' external lower or upper bounds relaxed');
maxUB = max(max(model.ub),-min(model.lb));
minLB = min(-max(model.ub),min(model.lb));
intRxnFiniteBound = ((model.ub < maxUB) & (model.lb > minLB));
fprintf('%u%s\n',nnz(p & intRxnFiniteBound),' finite lower bounds relaxed');
exRxn00 = ((model.ub == 0) & (model.lb == 0));
fprintf('%u%s\n',nnz(p & exRxn00),' lower bounds relaxed on fixed reactions (lb=ub=0)');
fprintf('\n');

bool=r~=0;
if any(bool)
    fprintf('%u%s\n',nnz(r),' steady state constraints relaxed');
    fprintf('%-20s%12s%12s\n','mets{n}','r','dxdt')
    for m=1:nMet
        if bool(m)
            fprintf('%-20s%12.4g%12.4g\n',...
                model.mets{m},sol.r(m),model.b(m));
        end
    end
else
    fprintf('%s\n','No steady state constraints relaxed');
end
fprintf('\n');

bool=p~=0 & q==0 & model.SIntRxnBool;
if any(bool)
    fprintf('%u%s\n',nnz(bool),' internal reaction lower bounds relaxed...');
    fprintf('%-20s%12.4s%12.4s%12.4s%12.4s%12.4s%12.8s\n','rxns','p','lb','v','ub','q','formula');
    for n=1:nRxn
        if bool(n)
            rxnAbbrList=model.rxns(n);
            formulas = printRxnFormula(model, rxnAbbrList, printFlag, lineChangeFlag);
            fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%6g%-100s\n',...
            model.rxns{n},sol.p(n),model.lb(n),sol.v(n),model.ub(n),sol.q(n),formulas{1});
        end
    end
else
    fprintf('%s\n','No internal reaction lower bounds relaxed');
end
fprintf('\n');

bool=p==0 & q~=0 & model.SIntRxnBool;
if any(bool)
    fprintf('%u%s\n',nnz(bool),' internal reaction lower bounds relaxed...');
    fprintf('%-20s%12.4s%12.4s%12.4s%12.4s%12.4s%12.8s\n','rxns','p','lb','v','ub','q','formula');
    for n=1:nRxn
        if bool(n)
            rxnAbbrList=model.rxns(n);
            formulas = printRxnFormula(model, rxnAbbrList, printFlag, lineChangeFlag);
            fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%6g%-100s\n',...
            model.rxns{n},sol.p(n),model.lb(n),sol.v(n),model.ub(n),sol.q(n),formulas{1});
        end
    end
else
    fprintf('%s\n','No internal reaction lower bounds relaxed');
end
fprintf('\n');

bool=p~=0 & q==0 & ~model.SIntRxnBool;
if any(bool)
    fprintf('%u%s\n',nnz(bool),' external reaction lower bounds relaxed...');
    fprintf('%-20s%12.4s%12.4s%12.4s%12.4s%12.4s%12.8s\n','rxns','p','lb','v','ub','q','formula');
     for n=1:nRxn
        if bool(n)
            rxnAbbrList=model.rxns(n);
            formulas = printRxnFormula(model, rxnAbbrList, printFlag, lineChangeFlag);
            fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%6g%-100s\n',...
            model.rxns{n},sol.p(n),model.lb(n),sol.v(n),model.ub(n),sol.q(n),formulas{1});
        end
    end
else
    fprintf('%s\n','No external reaction lower bounds relaxed');
end
fprintf('\n');

bool=p==0 & q~=0 & ~model.SIntRxnBool;
if any(bool)
    fprintf('%u%s\n',nnz(bool),' external reaction lower bounds relaxed...');
    fprintf('%-20s%12.4s%12.4s%12.4s%12.4s%12.4s%12.8s\n','rxns','p','lb','v','ub','q','formula');
     for n=1:nRxn
        if bool(n)
            rxnAbbrList=model.rxns(n);
            formulas = printRxnFormula(model, rxnAbbrList, printFlag, lineChangeFlag);
            fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%6g%-100s\n',...
            model.rxns{n},sol.p(n),model.lb(n),sol.v(n),model.ub(n),sol.q(n),formulas{1});
        end
    end
else
    fprintf('%s\n','No external reaction lower bounds relaxed');
end
fprintf('\n');


