function P = birkhoff(dim)
    d = ceil(sqrt(dim));
    P = Problem;
    P.lb = zeros(d^2,1);
    P.Aeq = sparse(2*d,d^2);
    P.beq = ones(2*d,1);
    for i=1:d
        P.Aeq(i,(i-1)*d+1:i*d) = 1;
        P.Aeq(d+i,i:d:d^2)=1;
    end
end

% function P = birkhoff(dim)
%     d = ceil(sqrt(dim));
%     P.lb = zeros(d^2,1);
%     P.Aeq = sparse(2*d-1,d^2);
%     P.beq = ones(2*d-1,1);
%     for i=1:d
%         P.Aeq(i,(i-1)*d+1:i*d) = 1;
%         if i==d, break; end
%         P.Aeq(d+i,i:d:d^2)=1;
%     end
% end