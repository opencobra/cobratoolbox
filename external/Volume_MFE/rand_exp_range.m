%where the points are weighted by the distribution exp(-a_i||x||^2)
function [new_pt] = rand_exp_range(l,u,a_i)

if a_i>1e-8 && norm(u-l)>=2/sqrt(2*a_i)
    %select from the 1d Gaussian chord if enough weight will be inside
    %K
    
    a = -l;
    b = (u-l)/norm(u-l);
    z = dot(a,b)*b+l;
    low_bd = (l(1)-z(1))/b(1);
    up_bd = (u(1)-z(1))/b(1);
    
    while 1
        %sample from Gaussian along chord, and accept if inside (u,v)
        r = randn(1)/sqrt(2*a_i);
        if r>=low_bd && r <=up_bd
            break;
        end
    end
    new_pt = r*b+z;
else
    %otherwise do simple rejection sampling by a bounding rectangle
    M = get_max(l,u,a_i);
    done = 0;
    its = 0;
    while ~done
        its = its+1;
        r = rand();
        p = (1-r)*l+r*u;
        r_val = M*rand();
        fn = eval_exp(p, a_i);
        if r_val<fn
            done = 1;
            new_pt = p;
        end
    end
end
end

function [ret1] = get_max(l, u, a_i)
%get the maximum value along the chord, which is the height of the bounding
%box for rejection sampling
a = -l;
b = (u-l)/norm(u-l);

z = dot(a,b)*b+l;
low_bd = (l(1)-z(1))/b(1);
up_bd = (u(1)-z(1))/b(1);
if sign(low_bd)==sign(up_bd)
    ret1 = max(eval_exp(u,a_i), eval_exp(l,a_i));
else
    ret1 = eval_exp(z,a_i);
end

end