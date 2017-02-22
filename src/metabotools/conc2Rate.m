function [flux] = conc2Rate(metConc, cellConc, t, cellWeight)
%[flux] = conc2Rate(metConc, cellConc, t, cellWeight)
% Converts metabolite concentration and (viable) cell concentration into
% uptake rate.
% CellConc consumed MetConc in T.
%
% INPUTS
%   MetConc       Change in metabolite concentration (mM)
%   CellConc      Cell concentration (cells per 1 ml)
%   T             Time in hours
%   CellWeight    gDW per cell
%
%   Flux          mmol/gDW/hr
%
% Ines Thiele 07/22/09

if nargin < 4
    CellWeight = 500 * 1e-12; % g
end

if nargin < 3
    T = 24; % hr; doubling time
end

flux = metConc/(cellConc*cellWeight*t*1000);
