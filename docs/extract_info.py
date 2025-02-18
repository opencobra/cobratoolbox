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
        with open('docs/tutorials/HOLDER_TEMPLATE.html', 'r') as template_file:
            template_content = template_file.read()
            template_content = template_content.replace('IFRAMETUTORIAL.html', "/".join(file_path.split('/')[2:]))  # Remove the first 2 directories from the file location
            template_content = template_content.replace('((TutorialName))', file_path.split('/')[-1].split('.')[0])  # Name of the tutorial
            template_content = template_content.replace('((TutorialPDFpath))', 'https://github.com/opencobra/COBRA.tutorials/tree/master/'+ "/".join(file_path.split('/')[2:]).replace('.html','.pdf'))  # path to the pdf file
            template_content = template_content.replace('((TutorialMLXpath))',  'https://github.com/opencobra/COBRA.tutorials/tree/master/'+"/".join(file_path.split('/')[2:]).replace('.html','.mlx'))  # path to the mlx file
            template_content = template_content.replace('((TutorialMATpath))', 'https://github.com/opencobra/COBRA.tutorials/tree/master/'+ "/".join(file_path.split('/')[2:]).replace('.html','.m'))  # path to the .m file
            template_content = template_content.replace('((TutorialGITHUBpath))', 'https://github.com/opencobra/COBRA.tutorials/tree/master/'+"/".join(file_path.split('/')[2:-1]))  # path to the github page
            if os.path.basename(file_path).startswith('tutorial_'):
                new_file_path = os.path.join('docs/tutorials', os.path.basename(file_path))
            else:
                new_file_path = os.path.join('docs/tutorials', "tutorial_"+os.path.basename(file_path))
            with open(new_file_path, 'w') as new_file:
                new_file.write(template_content)

        return heading_tag.text if heading_tag else None

def update_index_html(section, file_name, heading):
    with open('docs/tutorials/index.html', 'r') as f:
        index_soup = BeautifulSoup(f, 'html.parser')

    if section == "dataIntegration":
        section = "data-integration"
    section_div = index_soup.find('div', {'id': section})

    if section_div:
        ul = section_div.find('ul', {'class': 'simple'})
        if ul:
            new_li = index_soup.new_tag('li')
            new_a = index_soup.new_tag('a', href=file_name)
            new_span = index_soup.new_tag('span', **{'class': 'doc'})
            new_span.string = heading
            new_a.append(new_span)
            new_li.append(new_a)
            ul.append(new_li)

    with open('docs/tutorials/index.html', 'w') as f:
        f.write(str(index_soup.prettify()))

def main():
    # Fetch file path from command line argument
    file_path = os.sys.argv[1]

    # Section will be the first directory in the file path
    section = file_path.split('/')[2]

    # Get information from the file and update HOLDER_TEMPLATE.html
    heading = get_file_info(file_path)

    # Update index.html
    if os.path.basename(file_path).startswith('tutorial_'):
        update_index_html(section, os.path.basename(file_path), heading)
    else:
        update_index_html(section, "tutorial_"+os.path.basename(file_path), heading)

    print('Process completed.')

if __name__ == "__main__":
    main()
