function fastSLgenes(model,cutoff,order,flag)                                  
%% fastSLgenes(model,cutoff,order,flag)
% Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
% INPUT
% model (the following fields are required - others can be supplied)
%   S            Stoichiometric matrix
%   b            Right hand side = dx/dt
%   c            Objective coefficients
%   lb           Lower bounds
%   ub           Upper bounds
%   rxns         Reaction Names
%   genes        Gene Names
%   rules        Gene-Reaction Rules
%   rxnGenemat   reactions-gene matrix
%OPTIONAL
% cutoff         cutoff percentage value for lethality. Default is 0.01.
% flag           1 for a more rigourous search, default is 0
%
%
%
% Aditya Pratapa      9/28/14. 
%%
%initCobraToolbox
if exist('cutoff', 'var')
    if isempty(cutoff)
        cutoff = 0.01;
    end
else
    cutoff = 0.01;
end
 
 
if exist('flag', 'var')
    if isempty(flag)
        flag = 0;
    end
else
    flag = 0;
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
 
fname=strcat(model.description,'_Gene_Lethals.mat');
 
 
%%
 
switch order
    case 1
        [sgd]=fastSL_sg(model,cutoff);
              
        fprintf('\n Saving Single Lethal Genes List...\n');
        save(fname,'sgd');
        fprintf('Done. \n');
    case 2
        [sgd,dgd]=fastSL_dg(model,cutoff,flag);
        fprintf('\n Saving Single and Double Lethal Genes List...\n');
        save(fname,'sgd');
        save(fname,'dgd','-append');
        fprintf('Done. \n');
    case 3
        [sgd,dgd,tgd]=fastSL_tg(model,cutoff,flag);
        fprintf('\n Saving Single, Double and Triple Lethal Genes List...\n');
        save(fname,'sgd');
        save(fname,'dgd','-append');
        save(fname,'tgd','-append');
        fprintf('Done. \n');
end
 


