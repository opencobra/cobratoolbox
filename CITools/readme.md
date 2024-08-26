# CI Tools overview
The CI tools folder contains different files used within the cobratoolbox repository and website, to help make sure that the code is set up correctly and allows the CI to work. 7A brief overview of each function is covered below:

### checkTutorials.py
Function to check the tutorials repository for missing .html and .pdf files. However currently by design, the .html and .pdf files are not being stored in this repository, but this file will be useful should they need to be added to the tutorials repo. A personal access token needs to be set up and inserted as a replacement for '<your_github_token>'. The function reports the missing files.

### checkGhPages.py
Function to check the tutorials folder of the gh-pages branch for missing .html and .pdf files. A personal access token needs to be set up and inserted as a replacement for '<your_github_token>'. The function reports the missing files.

### getMlxFiles.py 
Function to get the .mlx files of the folder where either the .html and .pdf files are missing. The .mlx are downloaded to the local environment running the script

### convert_files.m
Function to convert the downloaded .mlx files into .pdf files. The .pdf files are saved in a 'pdf_results' folder.
