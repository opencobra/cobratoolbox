import datetime

current_year = datetime.datetime.now().year

with open("../citations.rst", "w") as file:
    file.write("Citations\n")
    file.write("=" * 20 + "\n")
    file.write("\n.. raw:: html\n")
    file.write(f"\n\t<br>\n")	
    file.write("\nPublications that cited COBRA Toolbox\n")
    file.write("------------------------------------\n")
    file.write(f".. tabs::\n")
    for year in range(current_year, 2006, -1):
        
        file.write(f"\t.. tab:: {year}\n")
        file.write(f"\t\t.. bibliography::\n")
        file.write(f"\t\t\t:list: enumerated\n")
        file.write(f"\t\t\t:filter: year == \"{year}\"\n")
        file.write(f"\t\t\t:style: modstyle\n")

    

