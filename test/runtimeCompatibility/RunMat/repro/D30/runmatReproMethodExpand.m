function r = runmatReproMethodExpand(c)
% Helper for the D30 reproducer: obj.method(c{:}).
p = inputParser();
p.addOptional('x', 0);
p.parse(c{:});
r = p.Results.x;
end
