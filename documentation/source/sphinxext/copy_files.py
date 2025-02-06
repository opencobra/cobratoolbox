from sphinx.ext import linkcode
import inspect
import shutil
import sphinx_tabs

path = inspect.getfile(linkcode)
shutil.copy('./sphinxext/linkcode.py',path)

path = inspect.getfile(sphinx_tabs).split('/')
path.pop()
path = '/'.join(path)
shutil.copy('./sphinxext/tabs.css',path+'/static/tabs.css')