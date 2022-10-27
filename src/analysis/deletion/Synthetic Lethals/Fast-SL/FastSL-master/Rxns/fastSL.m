function fastSL(model,cutoff,order,eliList,atpm)                                  
%% fastSL(model,cutoff,order,eliList,atpm)
% Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
% 
% INPUT
% model (the following fields are required - others can be supplied)       
%   S            Stoichiometric matrix
%   b            Right hand side = dx/dt
%   c            Objective coefficients
%   lb           Lower bounds
%   ub           Upper bounds
%   rxns         Reaction Names
%OPTIONAL
% cutoff         cutoff percentage value for lethality.Default is 0.01.
% order          Order of SLs required.Default order is 2. Max value 3.
% eliList        List of reactions to be ignored for lethality
% analysis:Exchange Reactions, ATPM etc.
% atpm           ATPM Reaction Id in model.rxns if other than 'ATPM'

%initCobraToolbox
if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end

if exist('order', 'var')
    if isempty(order)
        order = 2;
    else
        if (order>3)
        err = MException('ResultChk:OutOfRange', ...
        'Resulting value is outside expected range. Maximum value is 3.');
         throw(err)
        end
    end
else
    order = 2;
end


%Please change this according to your model
if exist('atpm', 'var')
    if isempty(atpm)
        atpm = 'ATPM'; %Reaction Id of ATP maintenance reaction- by default it takes 'ATPM'
    end
else
    atpm = 'ATPM';
end


if exist('eliList', 'var')
    if isempty(eliList)
        eliList = model.rxns(ismember(model.rxns,atpm)); %To eliminate ATPM.
    end
else
    eliList = model.rxns(ismember(model.rxns,atpm));
end

fname=strcat(model.description,'_Rxn_lethals.mat');


%%
varx = readCbModel('Eco_iAF1260.mat');
%varx = varx.iAF987;
switch order
    case 1
        [Jsl]=singleSL(varx,cutoff,eliList,atpm);
       
        fprintf('\n Saving Single Lethal Reactions List...\n');
        save(fname,'Jsl');
        fprintf('Done. \n');
    case 2
        [Jsl,Jdl]=doubleSL(varx,cutoff,eliList,atpm);
     
        fprintf('\n Saving Single and Double Lethal Reactions List...\n');
        save(fname,'Jsl');
        save(fname,'Jdl','-append');
        fprintf('Done. \n');
    case 3
        [Jsl,Jdl,Jtl]=tripleSL(varx,cutoff,eliList,atpm);
      
        fprintf('\n Saving Single, Double and Triple Lethal Reactions List...\n');
        save(fname,'Jsl');
        save(fname,'Jdl','-append');
        save(fname,'Jtl','-append');
        fprintf('Done. \n');
end