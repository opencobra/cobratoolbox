% D5: a guarded read of a variable that may not exist must not reject the file.
if exist('NOT_DEFINED', 'var')
    x = NOT_DEFINED;
end
fprintf('reached\n');
