function [R] = autoCorrelation(x)
%R = autoCorrelation(x)
%Output the autocorrelation of a vector
%
%Input:
% x - an dim x N vector, where n is the length of the chain.
%
%Output:
% R - an dim x N vector, where
%     the i-th row of R is the Autocorrelation of the i-th row of x.

% Wiener–Khinchin theorem
n = size(x, 2);
S = abs(fft(x-mean(x,2),2*n,2)).^2; % power spectral density
R = ifft(S, [], 2);

% added 1e-14 to handle constant sequence
R = real(R(:, 1:n)./(R(:, 1) + 1e-14 * sqrt(mean(x.^2,2)))); % remove the padding
end
