function I = detectIndepRows(A, tol, delta)
%I = detectIndepRows(A, tol, delta)
%compute a maximal set of independent rows of A
%
%Input:
% A - a matrix A.
% tol - the tolerance of how similar two rows are categorized as dependent
% delta - (will be deprecated) how much we perturb A when applying chol.
%
%Output:
% I - A(I, :) is a maximum independent set
if isempty(A), I = zeros(1,0); return; end
if ~exist('tol', 'var'), tol = 1e-6; end
if ~exist('delta', 'var'), delta = eps; end


% I is the number of indices.
% We use -1 to indicate dependent rows.
I = (1:size(A,1))';

% phase 1: use the perturbed chol
H = A * A';
r = sum(abs(H),1)';
r(r == 0) = 1;
I(r == 0) = -1;
H = H + delta * spdiag(r);
[R,~] = chol(H);

% detect tight constraints
r = full(diag(R));
r(isinf(r)) = 0; % any row with diag = Inf
r(end+1:size(A,1)) = +Inf; % we have no info after chol failed
I(full(r < tol*sqrt(sum(abs(R).^2,1))')) = -1;
A(I == -1,:) = [];

% phase 2: use the original chol
step = 0;
while 1
    H = A * A';
    idx = 0;
    while 1
        [R,p] = chol(H);
        if p == 0, break; end
        if size(R,2) ~= size(H,2) % this happens for dense matrix
            R = R'\H(1:(p-1),:);
        end
        
        % Compute the rest of H
        H = H - R' * R;
        H(1:p,:) = [];
        H(:,1:p) = [];
        A(idx+p,:) = [];
        
        % Update the indices I
        I_ = I(I > 0);
        I(I_(idx+p)) = -1; % set the "p" rows as dependent.
        idx = idx + p - 1;
        step = step + 1;
    end
    if idx == 0, break; end
end

if step > 5000
    warning('detectIndepRows:tooManySteps', 'Too many dependent rows.');
end

% Do we need phase 3?
% R(isinf(R)) = 0;
% idx = full(diag(R)<sqrt(sum(abs(R).^2,1))'*tol);
% I_ = I(I>0);
% I(I_(idx)) = -1;

I = find(I > 0); % externally, outputs all independent rows