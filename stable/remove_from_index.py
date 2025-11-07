import os
from bs4 import BeautifulSoup

def remove_from_index_html(file_name):
    """
    Remove a tutorial entry from the index.html file.
    
    Args:
        file_name: The base filename (e.g., "tutorial_example.html")
    """
    index_path = 'stable/tutorials/index.html'
    
    if not os.path.exists(index_path):
        print(f"Error: {index_path} not found")
        return False
    
    with open(index_path, 'r', encoding='utf-8') as f:
        index_soup = BeautifulSoup(f, 'html.parser')

    # Find and remove all entries with matching href
    removed = False
    for li in index_soup.find_all('li'):
        a_tag = li.find('a')
        if a_tag:
            href = a_tag.get('href')
            if href == file_name:
                print(f"Removing entry: {href}")
                li.decompose()
                removed = True

    if removed:
        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(index_soup.prettify())
        print(f"Successfully removed {file_name} from index.html")
    else:
        print(f"No entry found for {file_name} in index.html")
    
    return removed

def remove_tutorial_file(file_path):
    """
    Remove the tutorial_*.html file if it exists.
    
    Args:
        file_path: Original file path (e.g., "stable/tutorials/section/example.html")
    """
    base_name = os.path.basename(file_path)
    
    # Check if it starts with tutorial_, if not add prefix
    if base_name.startswith('tutorial_'):
        tutorial_file = os.path.join('stable/tutorials', base_name)
    else:
        tutorial_file = os.path.join('stable/tutorials', "tutorial_" + base_name)
    
    if os.path.exists(tutorial_file):
        os.remove(tutorial_file)
        print(f"Removed tutorial file: {tutorial_file}")
        return True
    else:
        print(f"Tutorial file not found: {tutorial_file}")
        return False

def main():
    # Fetch file path from command line argument
    file_path = os.sys.argv[1]
    
    print(f"Processing removal for: {file_path}")
    
    # Get the base filename
    base_name = os.path.basename(file_path)
    
    # Determine the tutorial filename
    if not base_name.startswith('tutorial_'):
        tutorial_filename = "tutorial_" + base_name
    else:
        tutorial_filename = base_name
    
    # Remove from index.html
    remove_from_index_html(tutorial_filename)
    
    # Remove the tutorial_*.html file
    remove_tutorial_file(file_path)
    
    print('Removal process completed.')

if __name__ == "__main__":
    main()
