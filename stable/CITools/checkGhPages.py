import requests
import csv

# Base URL of the GitHub repository API and the specific branch
repo_api_url = "https://api.github.com/repos/opencobra/cobratoolbox/contents/"
branch = "gh-pages"

# Subfolders to analyze in the tutorials directory
folders_to_check = ['analysis', 'design', 'reconstruction', 'dataIntegration', 'base', 'visualization']


headers = {
    'Authorization': 'token <Your_GitHub_Token>'
}

# Base URL for GitHub links
github_base_url = "https://github.com/opencobra/cobratoolbox/tree/gh-pages/"

# Function to check files in a GitHub folder via API
def check_files(folder_url):
    response = requests.get(folder_url, headers=headers, params={'ref': branch})
    if response.status_code == 200:
        files = response.json()
        has_mlx = any(file['name'].endswith('.mlx') for file in files)
        has_pdf = any(file['name'].endswith('.pdf') for file in files)
        has_html = any(file['name'].endswith('.html') for file in files)
        return has_mlx, has_pdf, has_html
    else:
        return None, None, None

# Store results
results = []

# Navigate to the stable/tutorials directory on the gh-pages branch
stable_folder_url = f"{repo_api_url}stable"
stable_response = requests.get(stable_folder_url, headers=headers, params={'ref': branch})

if stable_response.status_code == 200:
    stable_contents = stable_response.json()
    tutorials_folder = next((item for item in stable_contents if item['name'] == 'tutorials' and item['type'] == 'dir'), None)
    
    if tutorials_folder:
        tutorials_url = tutorials_folder['url']
        tutorials_response = requests.get(tutorials_url, headers=headers, params={'ref': branch})
        
        if tutorials_response.status_code == 200:
            tutorials_contents = tutorials_response.json()
            for folder_name in folders_to_check:
                folder = next((item for item in tutorials_contents if item['name'] == folder_name and item['type'] == 'dir'), None)
                if folder:
                    folder_url = folder['url']
                    folder_response = requests.get(folder_url, headers=headers, params={'ref': branch})
                    
                    if folder_response.status_code == 200:
                        subfolders = folder_response.json()
                        for subfolder in subfolders:
                            if subfolder['type'] == 'dir':
                                subfolder_url = subfolder['url']
                                has_mlx, has_pdf, has_html = check_files(subfolder_url)
                                folder_path = subfolder['path']
                                folder_link = f"{github_base_url}{folder_path}"
                                
                                if has_mlx and not has_pdf and not has_html:
                                    results.append({'folder': folder_path, 'category': 'Only .mlx', 'link': folder_link})
                                elif has_mlx and has_pdf and not has_html:
                                    results.append({'folder': folder_path, 'category': '.mlx and .pdf', 'link': folder_link})
                                elif has_mlx and not has_pdf and has_html:
                                    results.append({'folder': folder_path, 'category': '.mlx and .html', 'link': folder_link})
                                elif has_mlx and has_pdf and has_html:
                                    results.append({'folder': folder_path, 'category': '.mlx , .html and .pdf', 'link': folder_link})
                                else:
                                    results.append({'folder': folder_path, 'category': 'No .mlx', 'link': folder_link})

# Save results to a CSV file
csv_file = "cobratoolbox_tutorials_analysis.csv"
csv_columns = ['folder', 'category', 'link']

try:
    with open(csv_file, mode='w', newline='') as file:
        writer = csv.DictWriter(file, fieldnames=csv_columns)
        writer.writeheader()
        for data in results:
            writer.writerow(data)
    print(f"Results have been saved to {csv_file}")
except IOError:
    print("I/O error while writing the CSV file")

# Optionally, print the summary
print(f"\nSummary:")
for category in set(result['category'] for result in results):
    count = len([result for result in results if result['category'] == category])
    print(f"{category}: {count} folders")
