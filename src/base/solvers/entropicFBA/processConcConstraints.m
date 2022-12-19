%% processing for concentrations
if contains(lower(param.method),'conc')
    if ~isfield(param,'maxConc')
        param.maxConc=1e4;
    end
    if ~isfield(param,'externalNetFluxBounds')
        if isfield(model,'dxl') || isfield(model,'dxu')
            param.externalNetFluxBounds='dxReplacement';
        else
            param.externalNetFluxBounds='original';
        end
    end
    
    nMetabolitesPerRxn = sum(model.S~=0,1)';
    bool = nMetabolitesPerRxn~=1 & ~model.SConsistentRxnBool;
    if any(bool)
        warning('Exchange reactions involving more than one metabolite, check bounds on x - x0')
        disp(model.rxns(bool))
    end
    
    if any(~model.SConsistentRxnBool)

        switch param.externalNetFluxBounds
            case 'original'
                if param.printLevel>0
                    fprintf('%s\n','Using existing external net flux bounds without modification.')
                end
                if (isfield(model,'dxl') && any(model.dxl~=0)) || (isfield(model,'dxu') && any(model.dxu~=0))
                    error('Option clash between param.externalNetFluxBounds=''original'' and (isfield(model,''dxl'') && any(model.dxl~=0)) || (isfield(model,''dxu'') && any(model.dxu~=0))')
                end
                %
                vel = lb(~model.SConsistentRxnBool);
                veu = ub(~model.SConsistentRxnBool);
                %force initial and final concentration to be equal
                model.dxl = zeros(m,1);
                model.dxu = zeros(m,1);
            case 'dxReplacement'
                %TODO
                error('revise how net to initial and final conc bounds are dealt with')
                if ~isfield(model,'dxl')
                    %close bounds by default
                    model.dxl = zeros(m,1);
                    if exist('B','var')
                        dxlB =  -B*model.lb(~model.SConsistentRxnBool);
                        model.dxl(dxlB~=0)=dxlB(dxlB~=0);
                    end
                end
                if ~isfield(model,'dxu')
                    %close bounds by default
                    model.dxu = zeros(m,1);
                    if exist('B','var')
                        dxuB =  -B*model.ub(~model.SConsistentRxnBool);
                        model.dxu(dxuB~=0)=dxuB(dxuB~=0);
                    end
                end
                %eliminate all exchange reactions
                B = B*0;
                vel = lb(~model.SConsistentRxnBool)*0;
                veu = ub(~model.SConsistentRxnBool)*0;
            otherwise
                error(['param.externalNetFluxBounds = ' param.externalNetFluxBounds ' is an unrecognised input'])
        end
    else
        model.dxl = -inf*ones(m,1);
        model.dxu =  inf*ones(m,1);
    end
    
    clear lb ub
    
    
    if ~isfield(model,'x0l')
        model.x0l = zeros(m,1);
    end
    if ~isfield(model,'x0u')
        model.x0u = param.maxConc*ones(m,1);
    end
    if ~isfield(model,'xl')
        model.xl = zeros(m,1);
    end
    if ~isfield(model,'xu')
        model.xu = param.maxConc*ones(m,1);
    end
    
    if ~isfield(model,'u0') || isempty(model.u0)
        model.u0='zero';
    end
    if ischar(model.u0)
        switch model.u0
            case 'rand'
                u0=rand(m,1);
            case 'one'
                u0=ones(m,1);
            case 'zero'
                u0=zeros(m,1);
            otherwise
                error('unrecognised option for model.u0')
        end
    else
        if length(model.u0)==size(model.S,1)
            u0 = columnVector(model.u0);
        else
            if length(model.u0)==1
                u0=ones(m,1)*model.u0;
            else
                error('model.u0 is of incorrect dimension')
            end
        end
        if any(~isfinite(u0))
            error('u0 must be finite')
        end
    end
    
    %assume concentrations are in uMol
    if ~isfield(model,'concUnit')
        concUnit = 10-6;
    end
    
    % Define constants
    if isfield(model,'gasConstant') && isfield(model,'T')
        if isfield(model,'gasConstant')
            gasConstant = model.gasConstant;
        else
            %8.31446261815324 J K^-1 mol^-1
            gasConstant = 8.3144621e-3; % Gas constant in kJ K^-1 mol^-1
        end
        if isfield(model,'T')
            temperature = model.T;
        else
            temperature = 310.15;
        end
        %dimensionless
        u0 = u0/(gasConstant*temperature);
    end
    
    if ~isfield(model,'f') || isempty(model.f)
        model.f='one';
    end
    if ischar(model.f)
        switch model.f
            case 'rand'
                f=N'*rand(m,1);
            case 'one'
                f=ones(m,1);
            case 'two'
                f=ones(m,1)*2;
        end
    else
        if length(model.f)==size(model.S,1)
            f = columnVector(model.f);
        else
            if length(model.f)==1
                f=ones(m,1)*model.f;
            end
        end
        if any(~isfinite(f))
            error('f must all be finite')
        end
    end
end