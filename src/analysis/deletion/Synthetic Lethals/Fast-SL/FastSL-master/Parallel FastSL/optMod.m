function [sol,sol_x]=optMod(modeldel,delIdx,model,rhs)

if exist('rhs', 'var')
    if ~isempty(rhs)
        orig=modeldel.Model.lhs(end);
        modeldel.Model.lhs(end) = rhs;
        
    end
end
modeldel.Model.lb(delIdx)=0;
modeldel.Model.ub(delIdx)=0;
modeldel.Param.simplex.display.Cur=0;

soln   =  modeldel.solve();
modeldel.Model.lb(delIdx)=model.lb(delIdx);
modeldel.Model.ub(delIdx)=model.ub(delIdx);

if exist('rhs', 'var')
    if ~isempty(rhs)
        modeldel.Model.lhs(end) = orig;
    end
end
%     [x,fval]=cplexlp(-1*model.c,[],[],model.S,model.b,model.lb,model.ub,x0);
if soln.status==0 
    sol=0
    sol_x=[];
else
    sol = model.c'*soln.x(1:length(model.rxns));
    sol_x=soln.x(1:length(model.rxns))';
end

end