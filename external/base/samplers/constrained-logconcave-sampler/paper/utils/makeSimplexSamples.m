function [ samples ] = makeSimplexSamples( dim, N )
%MAKESIMPLEXSAMPLES Generate N samples of the dim-dimensional simplex

true_samples = [zeros(1,N); rand(dim-1,N); ones(1,N)];

for ii=1:N
    true_samples(:,ii) = sort(true_samples(:,ii));
    for jj=1:dim
        true_samples(jj,ii) = true_samples(jj+1,ii)-true_samples(jj,ii);
    end
end

samples = true_samples(1:end-1,:);

end

