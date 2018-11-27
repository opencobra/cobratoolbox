% This function take the input of a data vector x, which is to be binned;
% it also takes in the amount bins one would like the data binned into. The
% output is two vectors, one containing the normalised frequency of each bin
% (Freq), the other, the midpoint of each bin (midpts).
% Added and error to the binned frequency: eFreq (As of June 30 2010). If this
% option is not required, just call the function without including the third out
% put; i.e.: [midpts Freq]=lnbin(x,BinNum).

function [midpts Freq eFreq] = lnbin(x, BinNum, printLevel)

    if ~exist('printLevel', 'var')
        printLevel = 1;
    end
x = sort(x);
i = 1;
while x(i) <= 0;
    i = i + 1;
end
str = num2str((length(x) - i) / length(x) * 100);
if printLevel > 0
    stuff = 'Percentage of input vec binned ';
    disp([stuff str])
end

FPT = x(i:length(x));
LFPT = log10(FPT);
max1 = log10(ceil(max(FPT)));
min1 = log10(floor(min(FPT)));
% min1=1;

LFreq = zeros(BinNum, 1);
LTime = zeros(BinNum, 1);
Lends = zeros(BinNum, 2);

step = (max1 - min1) / BinNum;


% ------------ LOG Binning Data ------------------------
for i = 1:length(FPT)
    for k = 1:BinNum
        if((k - 1) * step + min1 <= LFPT(i) && LFPT(i) < k * step + min1)
            LFreq(k) = LFreq(k) + 1;
        end
            LTime(k) = k * step - (0.5 * step) + min1;
            Lends(k, 1) = (k - 1) * step + min1;
            Lends(k, 2) = (k) * step + min1;
    end
end
ends = exp(Lends);

widths = ends(1:length(ends), 2) - ends(1:length(ends), 1);
Freq = LFreq./widths./length(x);
eFreq = 1. / sqrt(LFreq).*Freq;
midpts = exp(LTime);
