function [score] = MTA_TS(Vout,Vref,rxnFBS)
% Returns the TS score of a particular solution of the MTA perturbation
% algorithm.
%
% USAGE:
%
%       score = MTA_TS(v_res,vref,Model,success,unsuccess)
%
% INPUT:
%    Vout:             Solution flux of MIQP formulation for each case
%    Vref:             Reference flux of source state
%    rxnFBS:           Array that contains the desired change: Forward,
%                      Backward and Unchanged (+1;0;-1).
%
% OUTPUTS:
%    score:            TS score for each case
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.

v_rF = find(rxnFBS==+1); % indexation of variables
v_rB = find(rxnFBS==-1);
v_r = [v_rF; v_rB];     % the order is neccesary, as the success array has been defined in that order
v_s = find(rxnFBS==0);

% Compute the successful reactions, without thershold
% We will consider a reaction successful if this reaction moves in the
% right direction
success = false (size(Vout));
success( rxnFBS==+1 & Vout>Vref ) = 1;
success( rxnFBS==-1 & Vout<Vref ) = 1;
% reduce the size of succes and respect the order
% indexation is defined as v_r = [v_rF; v_rB]
success = success(v_r);
unsuccess = ~success;

aux_Rs = sum(abs(Vout(v_r(success)) - Vref(v_r(success))));
aux_Ru = sum(abs(Vout(v_r(unsuccess)) - Vref(v_r(unsuccess))));
aux_S = sum(abs(Vout(v_s) - Vref(v_s)));

%score
score = (aux_Rs-aux_Ru)/(aux_S);

end
