function convert_files(mlx_file_list)
    if isempty(mlx_file_list)
        disp('No mlx files found.');
        return;
    end
    
    for k = 1:length(mlx_file_list)
        mlx_path = mlx_file_list{k};
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


