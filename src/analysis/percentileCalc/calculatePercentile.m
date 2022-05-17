function value = calculatePercentile(expressionValues, k)
    if ~isnan(k)
        C = unique(expressionValues,'sorted');
        n = length(C);
        Lp =  (n+1) * (k/100); % Position Locator
        if round(Lp) == Lp
            value = C(Lp);
        else
            value = round(C(floor(Lp)) + (Lp-floor(Lp)) * (C(ceil(Lp))-C(floor(Lp))));
        end
    else 
        value = k;
    end
end