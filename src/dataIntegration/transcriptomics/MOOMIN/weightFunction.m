function weight = weightFunction(PPDE, alpha, beta, pThresh)
% Gives the gene/reaction weight used in the MOOMIN-algorithm.
%
% USAGE:
%
%    weight = weightFunction(PPDE, alpha, beta, pThresh)
%
% INPUTS:
%    PPDE:              posterior probability of differential expression
%    alpha:             parameter to control the relationship between the positive and
%                       negative weights, and the sparseness of the inferred solutions
%    beta:              shape parameter for the weight function
%    pThresh:           threshold for differential expression
%
% OUTPUT:
%    weight:            the value of the weight function given the inputs
%
% .. Author: - Taneli Pusa 09/2019

	if PPDE == 1
		weight = -alpha * beta * log(1 - pThresh);
	else
		weight = min(beta * (-log(1 - PPDE) + log(1 - pThresh)),...
			-alpha * beta * log(1 - pThresh));
	end