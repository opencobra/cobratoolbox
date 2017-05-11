function AB = unioncell(A, colA, B, colB)
% Return a cell which is the union of cell B to cell A given by a comparing
%
% INPUTS:
%     A:      cell array A
%     colA:   column of A for comparison
%     B:      cell array B
%     colB:   column of B for comparison
%
% OUTPUT:
%     AB:     cell which is the union of cell B to cell A

[rlt, clt] = size(A);
[rlt2, clt2] = size(B);

% preallocate cell
AB = cell(rlt, clt + clt2);

for r = 1:rlt
    match = 0;
    for r2 = 1:rlt2
        if strncmp(A{r, colA}, B{r2, colB}, length(B{r2, colB}))
            for c = 1:clt
                AB{r, c} = A{r, c};
            end
            for c2 = 1:clt2
                AB{r, c + c2} = B{r2, c2};
            end
            match = 1;
        else
            for c = 1:clt
                AB{r, c} = A{r, c};
            end
        end
    end
    if match == 0
        fprintf('%s\n', ['No match:  ' int2str(r) ' ' A{r, colA}]);
    end
end
