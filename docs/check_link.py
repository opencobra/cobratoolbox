import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

# Base URL of the website to crawl
base_url = 'https://opencobra.github.io/cobratoolbox/stable'
# Part of the URL path we're searching for
target_path = '/cobratoolbox/stable/'

# Initialize sets for visited and pending URLs
visited_urls = set()
urls_to_visit = {base_url}

def is_valid_url(url):
    """Check if the URL is valid and within the same domain."""
    parsed = urlparse(url)
    return parsed.scheme in {'http', 'https'} and parsed.netloc == urlparse(base_url).netloc

def find_target_path(url):
    """Check if any link on the page contains the target path."""
    try:
        response = requests.get(url)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        # Search for the target path in all anchor tags
        for a_tag in soup.find_all('a', href=True):
            href = a_tag['href']
            full_url = urljoin(url, href)
            if target_path in full_url:
                print(f'Target path found on: {url} -> Link: {full_url}')
        return False
    except requests.RequestException as e:
        print(f'Error accessing {url}: {e}')
        return False

while urls_to_visit:
    current_url = urls_to_visit.pop()
    if current_url in visited_urls:
        continue
    print(f'Visiting: {current_url}')
    visited_urls.add(current_url)
    find_target_path(current_url)
    try:
        response = requests.get(current_url)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        # Extract all anchor tags with href attributes
        for a_tag in soup.find_all('a', href=True):
            href = a_tag['href']
            full_url = urljoin(current_url, href)
            if is_valid_url(full_url) and full_url not in visited_urls:
                urls_to_visit.add(full_url)
    except requests.RequestException as e:
        print(f'Error accessing {current_url}: {e}')
