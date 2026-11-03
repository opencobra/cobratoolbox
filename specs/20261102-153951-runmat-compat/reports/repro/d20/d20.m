f(1)
function f(x)
arguments
    x {mustBePositiveCustom}
end
disp(x)
end
function mustBePositiveCustom(x)
assert(all(x > 0))
end
