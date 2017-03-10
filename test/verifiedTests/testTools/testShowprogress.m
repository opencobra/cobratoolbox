global WAITBAR_TYPE
global WAITBAR_HANDLE

for m = 0:2
    WAITBAR_TYPE = m;
    fprintf('Testing show progress, mode = %i:\n', m)
    for k = 1:3
        showprogress(0,'Testing showprogress ...');
        for i = 1:k * 10
            showprogress(i/(k * 10));
            pause(0.02)
        end
        fprintf('\n')
    end
    fprintf('\n')
end
