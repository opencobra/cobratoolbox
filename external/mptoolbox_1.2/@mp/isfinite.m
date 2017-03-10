function out=isfinite(x)

out=~(isinf(x) | isnan(x));