import os
import json

def path_to_list(path):
    d = []
    for root, directories, filenames in os.walk(path):
        for filename in filenames:
            if filename[-2:] == '.m':
                website_url = os.path.join("modules", root[9:], "index.html")
                website_url += "?highlight=" + filename[:-2]
                website_url += "#" + '.'.join(['src'] + root[9:].split(os.path.sep) + [filename[:-2]])
                d.append({'name': filename[:-2], 
                          'website_url': website_url})
                print root, filename
    return d

with open('source/_static/json/functions.json', 'w') as f:
    d = path_to_list('../src/.')
    json.dump(d, f)
