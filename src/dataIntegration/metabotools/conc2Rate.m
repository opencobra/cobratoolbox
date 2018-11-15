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
%            - Modified by  Loic Marx, November 2018

if nargin < 4
    cellWeight = 500 * 1e-12; % g
end

if nargin < 3
    t = 24; % hr; doubling time
end

flux = metConc/(cellConc*cellWeight*t*1000);
