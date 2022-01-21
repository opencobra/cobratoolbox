classdef Problem < handle
    properties
        % the domain is a polytope defined by
        % {Aineq x <= bineq, Aeq x = beq, lb <= x <= ub}
        % If Aineq is not used, it can be left unset.
        Aineq
        bineq
        Aeq
        beq
        lb
        ub
        
        % the density is given by exp(-sum f_i(x_i))
        % where f is given by a vector function of its 1-st, 2-nd, 3-rd
        % derivative.
        % Only 1-st derivative is required.
        % If 2-nd derivative is provided, 3-rd derivative must be provided
        % unless 3-rd derivative is 0.
        df
        ddf
        dddf
    end
    
	properties (Dependent)
        n
	end
    
    methods
        function n = get.n(o)
            if ~isempty(o.Aeq)
                n = size(o.Aeq,2);
            elseif ~isempty(o.Aineq)
                n = size(o.Aineq,2);
            elseif ~isempty(o.lb)
                n = length(o.lb);
            elseif ~isempty(o.ub)
                n = length(o.ub);
            else
                error('Problem:emptyP', 'Polytope seems to be empty');
            end
        end
    end
end