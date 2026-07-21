classdef CobraSolverState
% Backward-compatible façade over the COBRA solver-state globals.
%
% USAGE:
%
%    state = CobraSolverState.get()
%    name  = CobraSolverState.getSolver(problemType)
%            CobraSolverState.setSolver(problemType, name)
%    p     = CobraSolverState.getParams(solverType)
%            CobraSolverState.setParam(solverType, paramName, paramValue)
%            CobraSolverState.restore(state)
%
% DESCRIPTION:
%    `CobraSolverState` is a typed accessor OVER the 14 solver-state globals
%    (feature 015-solver-spine-hardening, research.md R3):
%
%      * solver selection (7): `CBT_{LP,QP,MILP,MIQP,EP,NLP,CLP}_SOLVER`
%      * solver parameters (7): `CBT_{LP,QP,MILP,MIQP,EP,NLP,CLP}_PARAMS`
%
%    The globals stay authoritative and are never deleted (Principle II): reading
%    or writing through this accessor is EQUIVALENT to reading or writing the
%    corresponding global, so existing code that does `global CBT_LP_SOLVER; ...`
%    keeps working unchanged. The purpose of the accessor is to replace the
%    `eval`-built global-name access in the selection/parameter path with a fixed
%    `switch` on a validated type: there is deliberately NO `eval` here
%    (constitution VII-A/VII-D) - reintroducing one would defeat the feature.
%
% INPUTS (accessor methods):
%    problemType / solverType:  one of `'LP'`, `'QP'`, `'MILP'`, `'MIQP'`,
%                               `'EP'`, `'NLP'`, `'CLP'` (case-insensitive);
%                               an unknown type raises
%                               `COBRA:CobraSolverState:unknownType`
%    name:                      solver name (char) to select for `problemType`
%    paramName / paramValue:    parameter field name / value to set on the
%                               `solverType` parameter struct
%    state:                     a snapshot struct as returned by `get()`, used by
%                               `restore()` to reinstate a full state losslessly
%
% OUTPUTS:
%    state:    snapshot struct with fields `.solver` and `.params`, each a struct
%              with one field per problem type carrying the raw global value
%    name:     the selected solver for `problemType` (`''` if unset)
%    p:        the parameter struct for `solverType` (`[]` if unset)
%
% NOTE:
%    `get()`/`restore()` capture and reinstate the RAW global values so a
%    save/restore round-trip is lossless; `getSolver` normalises an unset
%    selection to `''` per the accessor contract. Each read/write selects the
%    matching global through a fixed `switch` (mirroring the established pattern
%    in `getCobraSolverParams.m`), never through a dynamically built name.
%
% Author:
%    - Created for feature 015-solver-spine-hardening, 2026-07-20.

    methods (Static)

        function state = get()
        % Return a lossless snapshot struct of all 14 solver-state globals.
            types = CobraSolverState.problemTypes();
            state = struct('solver', struct(), 'params', struct());
            for i = 1:numel(types)
                t = types{i};
                state.solver.(t) = CobraSolverState.rawSolver(t);
                state.params.(t) = CobraSolverState.rawParams(t);
            end
        end

        function name = getSolver(problemType)
        % Return the selected solver for problemType (`''` if unset).
            problemType = CobraSolverState.validateType(problemType);
            name = CobraSolverState.rawSolver(problemType);
            if isempty(name)
                name = '';
            end
        end

        function setSolver(problemType, name)
        % Select solver `name` for `problemType` (writes the matching global).
            problemType = CobraSolverState.validateType(problemType);
            CobraSolverState.writeSolver(problemType, name);
        end

        function p = getParams(solverType)
        % Return the parameter struct for `solverType` (`[]` if unset).
            solverType = CobraSolverState.validateType(solverType);
            p = CobraSolverState.rawParams(solverType);
        end

        function setParam(solverType, paramName, paramValue)
        % Set a single parameter field on the `solverType` parameter struct.
            solverType = CobraSolverState.validateType(solverType);
            p = CobraSolverState.rawParams(solverType);
            p.(paramName) = paramValue;
            CobraSolverState.writeParams(solverType, p);
        end

        function restore(state)
        % Reinstate a full snapshot (the inverse of `get()`), losslessly.
            types = CobraSolverState.problemTypes();
            for i = 1:numel(types)
                t = types{i};
                CobraSolverState.writeSolver(t, state.solver.(t));
                CobraSolverState.writeParams(t, state.params.(t));
            end
        end

    end

    methods (Static, Access = private)

        function types = problemTypes()
        % Fixed, ordered list of supported solver/problem types.
            types = {'LP', 'QP', 'MILP', 'MIQP', 'EP', 'NLP', 'CLP'};
        end

        function type = validateType(type)
        % Uppercase and validate a problem/solver type; error if unknown.
            if ~(ischar(type) || (isstring(type) && isscalar(type)))
                error('COBRA:CobraSolverState:unknownType', ...
                    'CobraSolverState: solver/problem type must be a character vector or string scalar.');
            end
            type = upper(char(type));
            if ~any(strcmp(type, CobraSolverState.problemTypes()))
                error('COBRA:CobraSolverState:unknownType', ...
                    'CobraSolverState: unknown solver/problem type ''%s''. Valid types are LP, QP, MILP, MIQP, EP, NLP, CLP.', type);
            end
        end

        function name = rawSolver(type)
        % Read the CBT_<type>_SOLVER global verbatim (no normalisation).
            switch type
                case 'LP'
                    global CBT_LP_SOLVER
                    name = CBT_LP_SOLVER;
                case 'QP'
                    global CBT_QP_SOLVER
                    name = CBT_QP_SOLVER;
                case 'MILP'
                    global CBT_MILP_SOLVER
                    name = CBT_MILP_SOLVER;
                case 'MIQP'
                    global CBT_MIQP_SOLVER
                    name = CBT_MIQP_SOLVER;
                case 'EP'
                    global CBT_EP_SOLVER
                    name = CBT_EP_SOLVER;
                case 'NLP'
                    global CBT_NLP_SOLVER
                    name = CBT_NLP_SOLVER;
                case 'CLP'
                    global CBT_CLP_SOLVER
                    name = CBT_CLP_SOLVER;
            end
        end

        function writeSolver(type, name)
        % Write the CBT_<type>_SOLVER global.
            switch type
                case 'LP'
                    global CBT_LP_SOLVER
                    CBT_LP_SOLVER = name;
                case 'QP'
                    global CBT_QP_SOLVER
                    CBT_QP_SOLVER = name;
                case 'MILP'
                    global CBT_MILP_SOLVER
                    CBT_MILP_SOLVER = name;
                case 'MIQP'
                    global CBT_MIQP_SOLVER
                    CBT_MIQP_SOLVER = name;
                case 'EP'
                    global CBT_EP_SOLVER
                    CBT_EP_SOLVER = name;
                case 'NLP'
                    global CBT_NLP_SOLVER
                    CBT_NLP_SOLVER = name;
                case 'CLP'
                    global CBT_CLP_SOLVER
                    CBT_CLP_SOLVER = name;
            end
        end

        function p = rawParams(type)
        % Read the CBT_<type>_PARAMS global verbatim (no normalisation).
            switch type
                case 'LP'
                    global CBT_LP_PARAMS
                    p = CBT_LP_PARAMS;
                case 'QP'
                    global CBT_QP_PARAMS
                    p = CBT_QP_PARAMS;
                case 'MILP'
                    global CBT_MILP_PARAMS
                    p = CBT_MILP_PARAMS;
                case 'MIQP'
                    global CBT_MIQP_PARAMS
                    p = CBT_MIQP_PARAMS;
                case 'EP'
                    global CBT_EP_PARAMS
                    p = CBT_EP_PARAMS;
                case 'NLP'
                    global CBT_NLP_PARAMS
                    p = CBT_NLP_PARAMS;
                case 'CLP'
                    global CBT_CLP_PARAMS
                    p = CBT_CLP_PARAMS;
            end
        end

        function writeParams(type, p)
        % Write the whole CBT_<type>_PARAMS global.
            switch type
                case 'LP'
                    global CBT_LP_PARAMS
                    CBT_LP_PARAMS = p;
                case 'QP'
                    global CBT_QP_PARAMS
                    CBT_QP_PARAMS = p;
                case 'MILP'
                    global CBT_MILP_PARAMS
                    CBT_MILP_PARAMS = p;
                case 'MIQP'
                    global CBT_MIQP_PARAMS
                    CBT_MIQP_PARAMS = p;
                case 'EP'
                    global CBT_EP_PARAMS
                    CBT_EP_PARAMS = p;
                case 'NLP'
                    global CBT_NLP_PARAMS
                    CBT_NLP_PARAMS = p;
                case 'CLP'
                    global CBT_CLP_PARAMS
                    CBT_CLP_PARAMS = p;
            end
        end

    end

end
