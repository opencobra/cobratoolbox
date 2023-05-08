function convert_files
    mlx_files = dir('**/*.mlx');
    if isempty(mlx_files)
        disp('No mlx files found.');
        return;
    end
    
    for k = 1:length(mlx_files)
        mlx_path = fullfile(mlx_files(k).folder, mlx_files(k).name);
        html_path = strrep(mlx_path, '.mlx', '.html');
        pdf_path = strrep(mlx_path, '.mlx', '.pdf');
        fprintf('Converting: %s\n', mlx_path);
        
        try
            matlab.internal.liveeditor.openAndConvert(mlx_path, html_path);
            fprintf('HTML conversion successful: %s\n', html_path);
        catch ME
            fprintf('Error during HTML conversion: %s\n', ME.message);
        end
        
       
    end
end

