import os

def generate_section_rst_code(section):
    """Generates the RST code for a section.

    Args:
        section(str): The name of the section to generate code for.

    Returns:
        str: The generated RST code.
    """

    rst_code = ""
    t="   "
    # Create header section
    rst_code += f".. _{section}:\n\n"
    rst_code += ".. raw:: html\n\n"
    rst_code += "\n".join([
        t+"<script src=\"../../_static/js/json-menu.js\"></script>",
        t+"<style>",
        t*2+"h1 {font-size:0px;}",
        t+"</style>",
    ])
    rst_code += "\n\n"

    # Create section title and logo
    rst_code += ".. raw:: html\n\n"
    rst_code += "\n".join([
        t+f"<div class=\"tutorialSectionBox {section}\">",
        t*2+f"<div class=\"sectionLogo\"><img class=\"avatar\" src=\"https://king.nuigalway.ie/cobratoolbox/img/icon_{section}_wb.png\" alt=\"{section}\"></div>",
        t*2+f"<div class=\"sectionTitle\"><h3>{section.capitalize()}</h3></div>",
        t*2+"<div class=\"row\">",
        t*3+"<div class=\"col-xs-6\">",
        t*4+"<div>",
    ])
    rst_code += "\n\n\n"

    # Create analysis heading and toctree
    rst_code += f"{section.capitalize()}\n"
    rst_code += len(section)*"-"+"\n\n"
    rst_code += ".. toctree::\n"
    rst_code += "   :maxdepth: 2\n\n"

    # Add subfolders to toctree
    subfolders = [f"{f}" for f in os.listdir(os.path.join('../../../src/',section, ""))]
    subfolders = ["   "+f+"/index" for f in subfolders if os.path.isdir(os.path.join('../../../src/',section, f))]
    rst_code += "\n".join(subfolders)
    rst_code += "\n\n"

    # Close HTML section
    rst_code += ".. raw:: html\n\n"
    rst_code += t*4+"</div>\n"
    rst_code += t*3+"</div>\n"
    rst_code += t*3+"</div>\n"
    rst_code += t*3+"<div class=\"col-xs-6\">\n"
    rst_code += t*4+"<div class=\"dropdown dropdown-cobra\">\n"
    rst_code += t*5+"<a href=\"\" class=\"btn btn-default dropdown-toggle\" data-toggle=\"dropdown\" style=\"width: 100%;\">\n"
    rst_code += t*6+" Function list\n"
    rst_code += t*6+" <b class=\"caret\"></b>\n"
    rst_code += t*5+"</a>\n"
    rst_code += t*5+f"<ul class=\"dropdown-menu {section}-menu dropdown-scrollable\">\n"
    rst_code += t*5+"</ul>\n"
    rst_code += t*4+"</div>\n"
    rst_code += t*4+f"<script> buildList(\"https://opencobra.github.io/cobratoolbox/unstable/modules/{section}functions.json\", \"{section}\") </script>\n"
    rst_code += t*3+"</div>\n"
    rst_code += t*2+"</div>\n"
    rst_code += t+"</div>\n\n"
    rst_code += t+"<br>\n\n"

    # Create automodule directive
    rst_code += ".. automodule:: src." + section + "\n"
    rst_code += t+":members:\n\n"

    return rst_code

def generate_no_sub_dir_rst_code(folder_path):
    """Generates the RST code for folders that have no any further subdirectory.

    Args:
        folder_path(str): Path to the folder

    Returns:
        str: The generated RST code.
    """
    temp = folder_path.split('/')
    folder_name = temp[-1]
    rst_code = ""
    rst_code += f".. _{folder_name}:\n\n\n"
    rst_code += f"{folder_name.capitalize()}\n"
    rst_code += len(folder_name)*"-"+"\n\n"
    rst_code += ".. automodule:: src." + folder_path.replace('/','.') + "\n"
    rst_code += "    :members:\n\n"
    return rst_code

def generate_sub_dir_rst_code(folder_path,d):
    temp = folder_path.split('/')
    folder_name = temp[-1]
    rst_code = ""
    rst_code += f".. _{folder_name}:\n\n\n"
    rst_code += f"{folder_name.capitalize()}\n"
    rst_code += len(folder_name)*"-"+"\n\n"
    rst_code += ".. toctree::\n\n"

    # Add subfolders to toctree
    rst_code += "\n".join([f"\t{f}/index" for f in d])
    rst_code += "\n\n"

    rst_code += ".. automodule:: src." + folder_path.replace('/','.') + "\n"
    rst_code += "    :members:\n\n"
    return rst_code

sections = ["analysis", "base", "dataIntegration", "design", "reconstruction", "visualization"]

for section in sections:
  os.makedirs(section,exist_ok=True)
  with open(section+'/index.rst','w') as file:
    file.write(generate_section_rst_code(section))
  for (r,d,f) in os.walk(os.path.join('../../../src/',section),topdown=True):
    if r!='../../../src/'+section:
      new_dir=r.replace('../../../src/','')
      os.makedirs(new_dir,exist_ok=True)
      if len(d)==0:
        with open(new_dir+'/index.rst','w') as file:
          file.write(generate_no_sub_dir_rst_code(new_dir))
      else:
        with open(new_dir+'/index.rst','w') as file:
          file.write(generate_sub_dir_rst_code(new_dir,d))
