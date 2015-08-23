function [minFlux,maxFlux,success,status] = CNAfluxVariability(cnap,reacval,macromol,solver)
%           
% ------------------------------------------------ 
% CellNetAnalyzer API function 'CNAfluxVariability
% ------------------------------------------------
% --> flux variability analysis in mass-flow networks
%
% Usage: [minFlux,maxFlux,success,status] = CNAfluxVariability(cnap,reacval,macromol,solver)
%
% Given a mass-flow project (with or without GUI) and a set of predefined
% fluxes this function determines the range of feasible fluxes for each 
% reaction by solving linear optimization  problems.
%
% Input: 
%   cnap: (mandatory) is a CellNetAnalyzer (mass-flow) project variable.
%         The function accesses the following fields of cnap (see manual):
%
%      cnap.stoichmat: the stoichiometric matrix of the network
%      cnap.numr: number of reactions (columns in cnap.stoichMat)
%      cnap.numis: number of internal species
%      cnap.mue: index of the biosynthesis reaction; can be empty
%      cnap.macroComposition: matrix defining the stoichiometry of
%        the macromolecules with respect to the metabolites (species); matrix
%        element macroComposition(i,j) stores how much of metabolite i (in mmol)
%        is required to synthesize 1 gram of macromolecule j
%      cnap.specInternal: vector with the indices of the internal species
%      cnap.macroDefault: default concentrations of the macromolecules
%      cnap.reacMin: lower boundaries of reaction rates
%       (if reacMin(i)=0 --> reaction i is irreversible)
%      cnap.reacMax: upper boundaries of reaction rates
%
%  reacval: is a (numrx1) vector specifying the predefined fluxes;  
%     reacval(i) is either a number defining a fixed flux or t is NaN 
%      indicating a free flux (whose feasible upper and lower boundaries 
%      subject to the predefined fluxes are determined by this function)
%      (default value of reacval: a (numr x 1) NaN vector)
%
%  macromol: vector containing the macromolecule values (concentrations);
%     can be empty when cnap.mue or cnap.macroComposition is empty
%     (default: cnap.macroDefault)
%
%  solver: selects the LP solver
%     0: GLPK (glpk function)
%     1: MATLAB Optimization Toolbox (linprog function)
%     2: CPLEX (cplexlp function)
%     (default: 0)
%
%
%  The following results are returned:
%
%   minFlux: contains the mnimal feasible fluxes (for every reaction)
%	     consistent with predefined values in reacval;
%            note that minFlux(i)=reacval(i) for all predefined fluxes
%            (i.e. where reacval(i) was a numerical value)
%            when success == false: minFlux(j)=NaN for all j not predefined
%
%   maxFlux: contains the maximal feasible fluxes (for every reaction)
%	     consistent with predefined values in reacval;
%            note that maxFlux(i)=reacval(i) for all predefined fluxes
%            (i.e. where reacval(i) was a numerical value)
%            when success == false: maxFlux(j)=NaN for all j not predefined
%
%   Note that a flux i is uniquely determined if minFlux(i)=maxFlux(i).
%
%   success: flag indicating whether the optimizations were successful
%
%   status: solver status (useful for checking reasons of unsuccessful 
%           optimization (e.g. overly stirngent systems); for interpretation 
%           check the documentation of the selected LP solver


if(nargin<4)
   solver=0;
end
if(nargin<3 || isempty(macromol))
	macromol=cnap.macroDefault;
end
if(nargin<2 || isempty(reacval))
	reacval=nan(cnap.numr,1);
end

minFlux= reacval;
maxFlux= reacval;
objold=cnap.objFunc;

success=1;
status=0;

if(~any(isnan(reacval)))
	return;
end

LPavail=LP_solver_availability(true);
if(LPavail(solver+1)==false)
	solvers={'GLPK (glpk)','MATLAB (linprog)','CPLEX (cplexlp)'};
	disp(['Solver ',solvers{solver+1},' not found. Please check whether you have porperly installed the toolbox and added the path!']);
	return;
end

if(solver==1)
 objfuncblank=zeros(cnap.numr,1);
 for i=1:cnap.numr
     % reset objective function
     cnap.objFunc=objfuncblank;

    if isnan(reacval(i))
         % maximization
         cnap.objFunc(i)= -1;
         [maxiVec_aux,success,status]=CNAoptimizeFlux(cnap,reacval,macromol,solver,0);
         if(status==-3)
		maxFlux(i)=inf;
		success=1;
	 elseif(status~=1)
                disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent.']);
                cnap.objFunc=objold;
                return;
	else
         	maxFlux(i)=maxiVec_aux(i);

        end
         % minimization
         cnap.objFunc(i)= 1;
         [miniVec_aux,success,status]=CNAoptimizeFlux(cnap,reacval,macromol,solver,0);
         if(status==-3)
		minFlux(i)=-inf;
		success=1;
	 elseif(status~=1)
                disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent.']);
                cnap.objFunc=objold;
                return;
	else
         	minFlux(i)=miniVec_aux(i);
        end

     end

 end

cnap.objFunc=objold;

elseif solver==0 || solver==2	%% GLPK (with warm start) or CPLEX

	t=initsmat(cnap.stoichMat,cnap.mue,cnap.macroComposition,macromol,cnap.specInternal);
	if(isempty(t))
    		disp('No reactions and/or internal metabolites defined! Procedure can not be performed!');
  		cnap.continue= false;
  		return;
	end
	rn=find(isnan(reacval));
	rbek=find(~isnan(reacval));
	tn=t(:,rn);
	if(~isempty(rbek))
		tb=t(:,rbek);
		bb=-tb*reacval(rbek);
	else
		tb=[];
		bb=zeros(cnap.numis,1);
	end

        ctype= repmat('S', 1, cnap.numis);
        vtype= repmat('C', 1, numel(rn));

	LB=cnap.reacMin(rn);
	UB=cnap.reacMax(rn);
	%NB_A=[];
  	%NB_b=[];
	%opts=optimset('Display','off');

	param.presol=0;
	param.lpsolver=1;

	objfuncblank=zeros(numel(rn),1);
	objfunc=objfuncblank;

	if(solver==0) %GLPK
		%Kaltstart
		objfunc(1)=1;

		[res,fminval,status]= glpk(objfunc, tn, bb, LB, UB, ctype, vtype);
  		if status==6
			minFlux(rn(1))=-inf;
		elseif status==5
  			minFlux(rn(1))=res(1);
		else
			success=0;
       	        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent.']);
			return;
  		end

		objfunc(1)=-1;
		[res,fminval,status]= glpk(objfunc, tn, bb, LB, UB, ctype, vtype);
  		if status==6
  			maxFlux(rn(1))=inf;
		elseif status==5
  			maxFlux(rn(1))=res(1);
		else
			success=0;
       	        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent.']);
			return;
  		end

		for i=2:numel(rn) 	%% Warmstart
			objfunc=objfuncblank;
			objfunc(i)=1;
			[res,fminval,status]= glpk(objfunc, tn, bb, LB, UB, ctype, vtype,1,param);
  			if status==6
				minFlux(rn(i))=-inf;
			elseif status==5
	  			minFlux(rn(i))=res(i);
			else
				success=0;
       		        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent.']);
				return;
  			end

			objfunc(i)=-1;
			[res,fminval,status]= glpk(objfunc, tn, bb, LB, UB, ctype, vtype,1,param);
  			if status==6
  				maxFlux(rn(i))=inf;
			elseif status==5
  				maxFlux(rn(i))=res(i);
			else
				success=0;
       		        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent.']);
				return;
  			end
		end

	else %CPLEX
		%Kaltstart
%		objfunc(1)=1;
%
%		[res,fminval,status,output]= cplexlp(objfunc, [],[],tn, bb, LB, UB);
%  		if status ~= 1
%			success=0;
%       	        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent or unbounded. See the following CPLEX ouput message:']);
%			output
%			return;
%  		end
%  		minFlux(rn(1))=res(1);
%
%		objfunc(1)=-1;
%		[res,fminval,status,output]= cplexlp(objfunc, [],[],tn, bb, LB, UB);
%  		if status ~= 1
%			success=0;
%       	        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent or unbounded. See the following CPLEX ouput message:']);
%			output
%			return;
%  		end
%  		maxFlux(rn(1))=res(1);
%
%		for i=2:numel(rn) 	%% Warmstart?!
%i
%			objfunc=objfuncblank;
%			objfunc(i)=1;
%			[res,fminval,status,output]= cplexlp(objfunc, [],[],tn, bb, LB, UB,res);
%  			if status ~= 1
%				success=0;
%       		        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent or unbounded. See the following CPLEX ouput message:']);
%				output
%				return;
%  			end
%  			minFlux(rn(i))=res(i);
%
%			objfunc(i)=-1;
%			[res,fminval,status,output]= cplexlp(objfunc, [],[],tn, bb, LB, UB,res);
%	  		if status ~= 1
%				success=0;
%       		        	disp(['Warning: linear optimization failed. Solver status: ',num2str(status),'. Scenario is probably overly stringent or unbounded. See the following CPLEX ouput message:']);
%				output
%				return;
%  			end
%  			maxFlux(rn(i))=res(i);
%		end

		cgp= Cplex();
        	cgp.Param.emphasis.numerical.Cur= 1;
        	cgp.Model.A= tn;
        	cgp.Model.ub= UB;
	        cgp.Model.lb= LB;
       	 	cgp.Model.lhs= bb;
        	cgp.Model.rhs= bb;
        	cgp.Model.obj=objfuncblank';
        	cgp.DisplayFunc=[];
        	fva= {cgp.Model.lb, cgp.Model.ub};
        	sense= {'minimize', 'maximize'};

        	for i= 1:numel(rn)
          		cgp.Model.obj(:)= 0;
          		cgp.Model.obj(i)= 1;
          		for j= 1:2
            			cgp.Model.sense= sense{j};
            			x= cgp.solve();
            			if x.status ~= 1 && x.status~=2
              				fprintf('status %d %s for %s, %d\n', x.status,x.statusstring, sense{j}, i);
					success=0;
					disp('Exit!');
					return;
            			elseif x.status == 1
              				fva{j}(i)= x.objval;
				else  %x.status=2=UNBOUNDED
					if j==1
              					fva{j}(i)=-inf;
					else
              					fva{j}(i)=inf;
					end
            			end
          		end
		end

  		minFlux(rn)=fva{1};
  		maxFlux(rn)=fva{2};
	end
end

minFlux(abs(minFlux)<cnap.epsilon)=0;
maxFlux(abs(maxFlux)<cnap.epsilon)=0;




