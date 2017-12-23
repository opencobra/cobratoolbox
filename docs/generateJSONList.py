import os
import json
import errno

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

def path_to_list(path):
    d = []
    path_length = len(path)
    for root, directories, filenames in os.walk(path):
        for filename in filenames:
            print os.path.join('source', 'modules', root[path_length+1:], 'index.rst')
            if filename[-2:] == '.m' and os.path.isfile(os.path.join('source', 'modules', root[path_length+1:], 'index.rst')):
                website_url = os.path.join("modules", root[path_length+1:], "index.html")
                website_url += "?highlight=" + filename[:-2]
                website_url += "#" + '.'.join(['src'] + root[path_length+1:].split(os.path.sep) + [filename[:-2]])
                d.append({'name': filename[:-2], 
                          'website_url': website_url})
                print root, filename
    return d

destination_dir = os.path.join('source', '_static', 'json')
mkdir_p(destination_dir)
with open(os.path.join(destination_dir, 'functions.json'), 'w') as f:
    d = path_to_list('../src/.')
    json.dump(d, f)
