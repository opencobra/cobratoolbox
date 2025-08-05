import re
import os
from bs4 import BeautifulSoup

def get_file_info(file_path):
    with open(file_path, 'r', encoding='utf8') as f:
        html_content = f.read()
        soup = BeautifulSoup(html_content, 'html.parser')

        # File location
        print(f'File Location: {file_path}')

        # Heading
        heading_tag = soup.find('h1')
        if heading_tag:
            print(f'Heading: {heading_tag.text}')

        # Modify and create a copy of HOLDER_TEMPLATE.html
        with open('stable/tutorials/HOLDER_TEMPLATE.html', 'r') as template_file:
            template_content = template_file.read()
            relative_path = "/".join(file_path.split('/')[2:])
            base_name = file_path.split('/')[-1].split('.')[0]

            template_content = template_content.replace('IFRAMETUTORIAL.html', relative_path)
            template_content = template_content.replace('((TutorialName))', base_name)
            template_content = template_content.replace(
                '((TutorialPDFpath))',
                f'https://github.com/opencobra/COBRA.tutorials/tree/master/{relative_path.replace(".html", ".pdf")}'
            )
            template_content = template_content.replace(
                '((TutorialMLXpath))',
                f'https://github.com/opencobra/COBRA.tutorials/tree/master/{relative_path.replace(".html", ".mlx")}'
            )
            template_content = template_content.replace(
                '((TutorialMATpath))',
                f'https://github.com/opencobra/COBRA.tutorials/tree/master/{relative_path.replace(".html", ".m")}'
            )
            template_content = template_content.replace(
                '((TutorialGITHUBpath))',
                f'https://github.com/opencobra/COBRA.tutorials/tree/master/{"/".join(file_path.split("/")[2:-1])}'
            )

            if os.path.basename(file_path).startswith('tutorial_'):
                new_file_path = os.path.join('stable/tutorials', os.path.basename(file_path))
            else:
                new_file_path = os.path.join('stable/tutorials', "tutorial_" + os.path.basename(file_path))

            with open(new_file_path, 'w') as new_file:
                new_file.write(template_content)

        return heading_tag.text if heading_tag else None

def update_index_html(section, file_name, heading):
    with open('stable/tutorials/index.html', 'r', encoding='utf-8') as f:
        index_soup = BeautifulSoup(f, 'html.parser')

    if section == "dataIntegration":
        section = "data-integration"

    section_div = index_soup.find('div', {'id': section})
    duplicates_removed = False

    if section_div:
        ul = section_div.find('ul', {'class': 'simple'})
        if ul:
            # Remove existing entries with same href
            for li in ul.find_all('li'):
                a_tag = li.find('a')
                href = a_tag.get('href') if a_tag else None
                if href == file_name:
                    li.decompose()
                    duplicates_removed = True

            # Add new entry
            new_li = index_soup.new_tag('li')
            new_a = index_soup.new_tag('a', href=file_name)
            new_span = index_soup.new_tag('span', **{'class': 'doc'})
            new_span.string = heading
            new_a.append(new_span)
            new_li.append(new_a)
            ul.append(new_li)

            # Sort the list items alphabetically by visible text
            sorted_lis = sorted(
                ul.find_all('li'),
                key=lambda li: li.get_text().strip().lower()
            )
            ul.clear()
            for li in sorted_lis:
                ul.append(li)

    with open('stable/tutorials/index.html', 'w', encoding='utf-8') as f:
        f.write(index_soup.prettify())

    if duplicates_removed:
        print("Duplicate links found and removed")

def main():
    # Fetch file path from command line argument
    file_path = os.sys.argv[1]

    # Section will be the first directory in the file path
    section = file_path.split('/')[2]

    # Get information from the file and update HOLDER_TEMPLATE.html
    heading = get_file_info(file_path)

    # Update index.html
    file_name = os.path.basename(file_path)
    if not file_name.startswith('tutorial_'):
        file_name = "tutorial_" + file_name

    update_index_html(section, file_name, heading)

    print('Process completed.')

if __name__ == "__main__":
    main()
