function [ points ] = genSamples( P,numSteps, numSamples )
%GENSAMPLES Compute samples from a polytope, taking numSteps steps of the
%Markov chain before saving a sample point

if nargin < 3
   numSamples = 1e3; 
end

if nargin < 2
    numSteps = 1e2;
end

K = ConvexBody(P,[],.2,'');
x = zeros(K.dim,1);
resetSlacks(K,x);
points = zeros(size(P.N,1),numSamples);

for i=1:numSamples
    for j=1:numSteps
        x = getNextPoint(K,x,0,1);
    end
    points(:,i) = P.N*x+P.p_shift;
end

end