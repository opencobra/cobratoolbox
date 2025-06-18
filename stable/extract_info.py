import re
import os
from bs4 import BeautifulSoup

def update_index_html(section, file_name, heading):
    from collections import defaultdict

    with open('stable/tutorials/index.html', 'r', encoding='utf-8') as f:
        index_soup = BeautifulSoup(f, 'html.parser')

    if section == "dataIntegration":
        section = "data-integration"
    section_div = index_soup.find('div', {'id': section})

    if section_div:
        ul = section_div.find('ul', {'class': 'simple'})
        if ul:
            # Remove duplicates before adding new one
            seen = set()
            duplicates_found = False
            for li in ul.find_all('li'):
                href = li.a['href'] if li.a and 'href' in li.a.attrs else None
                if href:
                    if href in seen:
                        li.decompose()
                        duplicates_found = True
                    else:
                        seen.add(href)

            if duplicates_found:
                print("Duplicate links found and removed.")

            # Add new list item
            new_li = index_soup.new_tag('li')
            new_a = index_soup.new_tag('a', href=file_name)
            new_span = index_soup.new_tag('span', **{'class': 'doc'})
            new_span.string = heading
            new_a.append(new_span)
            new_li.append(new_a)
            ul.append(new_li)

    with open('stable/tutorials/index.html', 'w', encoding='utf-8') as f:
        f.write(str(index_soup.prettify()))

