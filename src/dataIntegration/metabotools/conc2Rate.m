function [flux] = conc2Rate(metConc, cellConc, t, cellWeight)
% Converts metabolite concentration and (viable) cell concentration into
% uptake rate.
% CellConc consumed MetConc in t.
%
% USAGE:
%
%    [flux] = conc2Rate(metConc, cellConc, t, cellWeight)
%
% INPUTS:
%    metConc:       Change in metabolite concentration (mM)
%    cellConc:      Cell concentration (cells per 1 ml)
%    t:             Time in hours
%    cellWeight:    gDW per cell
%
% OUTPUT:
%    flux:          mmol/gDW/hr
%
% .. Author: - Ines Thiele 07/22/09

if nargin < 4
    CellWeight = 500 * 1e-12; % g
end

if nargin < 3
    T = 24; % hr; doubling time
end

flux = metConc/(cellConc*cellWeight*t*1000);
