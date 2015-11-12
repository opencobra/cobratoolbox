% CREATECUBECALLS
%
% An internal Odefy function which should not be called directly

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function [calls paramnames paraperspecies paramdefs]=CreateCubeCalls(model, type, target)

if (target == 1)
    % ODE
    fstr = 'cvals(%s)';
elseif (target == 2)
    % SBToolbox
    fstr = '%s';
elseif (target == 3)
    % R
    fstr = 'cvals[%d]';
end

calls{numel(model.species)} = '';
% iterate over all species
paramindex = 1;
paramnames = {};
paramdefs = {};
paraperspecies = {};
for speciesnum=1:numel(model.species)

    paraperspecies{speciesnum} = {};
    paramdefs{speciesnum} = [];

    n = numel(model.tables(speciesnum).inspecies);
    b = model.tables(speciesnum).truth;
    numstates=2^n;

    if (numstates > 1)
        str = '(';
        tauindex = paramindex;
        paramindex = paramindex+1;
        % generate species names
        specnames{numstates} = '';
        if target < 3
            % ODE, SBTOOL
            for j=1:n
                specnames{j} = sprintf(fstr, model.species{model.tables(speciesnum).inspecies(j)});
            end
        elseif target == 3
            % R
            for j=1:n
                specnames{j} = sprintf(fstr,model.tables(speciesnum).inspecies(j));
            end
        end


        first = 1;
        % generate parameters names
        strn = {};
        strk = {};
        for j=1:n
            if type>1
                paramnames{paramindex} = sprintf('%s_n_%s', model.species{speciesnum}, model.species{model.tables(speciesnum).inspecies(j)});
                paramnames{paramindex+1} = sprintf('%s_k_%s', model.species{speciesnum}, model.species{model.tables(speciesnum).inspecies(j)});
                paramdefs{speciesnum}(end+1) = 3; paramdefs{speciesnum}(end+1) = 0.5;
                paraperspecies{speciesnum}{end+1} = paramnames{paramindex};
                paraperspecies{speciesnum}{end+1} = paramnames{paramindex+1};
            end

            if (target == 1)
                % ODE
                strn{j} = sprintf('params(%i)', paramindex);
                strk{j} = sprintf('params(%i)', paramindex+1);
            elseif (target == 2)
                % SBtool
                strn{j} = sprintf('%s_n_%s', model.species{speciesnum}, specnames{j});
                strk{j} = sprintf('%s_k_%s', model.species{speciesnum}, specnames{j});
            elseif (target == 3)
                % R
                strn{j} = sprintf('params[%i]', paramindex);
                strk{j} = sprintf('params[%i]', paramindex+1);
            end
            if (type > 1)
                paramindex = paramindex+2;
            end
        end
        % generate term
        for linindex=0:numstates-1
            if b(linindex+1)~=0
                if (first)
                    first = 0;
                else
                    str = [str '+'];
                end
                ProdDiv=linindex;
                for j=1:n
                    ij=mod(ProdDiv,2);
                    ProdDiv=floor(ProdDiv/2);

                    % generate actual function
                    fun = GenFun(type, specnames{j}, strn{j}, strk{j});

                    if ij==0
                        str = [str sprintf('(1-%s)', fun)];
                    else
                        str = [str sprintf('%s', fun)];
                    end
                    if (j<n)
                        str = [str '*'];
                    end
                end
            end
        end


        % decay and tauparamnames
        if target<3
            % ODE, SB
            str = [str '-' sprintf(fstr, model.species{speciesnum})];
        elseif target==3
            % R
            str = [str '-' sprintf(fstr, speciesnum)];
        end
        if (target == 1)
            % ODE
            str = [str sprintf(') / params(%i)',tauindex)];
        elseif (target == 2)
            % SBtool
            str = [str sprintf(') / %s_tau',model.species{speciesnum})];
        elseif (target == 3)
            % R
            str = [str sprintf(') / params[%i]',tauindex)];
        end
        paramnames{tauindex} =  sprintf('%s_tau',model.species{speciesnum});
        paramdefs{speciesnum}(end+1) = 1;
        paraperspecies{speciesnum}{end+1} = paramnames{tauindex};

    else
        % input, just a simple function call
        str = '0';

    end


    calls{speciesnum} = str;
end


function str=GenFun(type, var, paramn, paramk)
if (type == 1)
    % leave as it is => BooleCube
    str = var;
elseif (type == 2)
    % hill function => HillCube
    str = sprintf('%s^%s/(%s^%s+%s^%s)', var, paramn, var, paramn, paramk, paramn);
elseif (type == 3)
    % hill function, normalized
    str = sprintf('%s^%s/(%s^%s+%s^%s)*(1+%s^%s)', var, paramn, var, paramn, paramk, paramn, paramk, paramn);
end
