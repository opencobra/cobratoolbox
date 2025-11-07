# This code uses the AllContributors.csv file to parse the list of current and previous contributors
# and makes changes to the contributorsTemp.html file and produces contributors.html

from bs4 import BeautifulSoup
import pandas as pd
import html

df = pd.read_csv('AllContributors.csv')
# Dynamically generating the HTML code
curr_contri = ""
past_contri = ""
for i in range(len(df)):
  if df.iloc[i]['CurrentContributor']:
    username, avatar_url, github_url = df.iloc[i]['Contributors'],df.iloc[i]['Avatar_URL'],df.iloc[i]['Github_page']
    curr_contri += f"""
    <div class="col-lg-4 col-sm-6 text-center">
        <a href="{github_url}"><img class="img-circle img-responsive img-center" style="margin: 0 auto;border: 1px solid #dddddd;padding: 5px;" src="{avatar_url}" alt="{username}" width="90px"></a>
        <p><a href="{github_url}">{username}</a></p>
    </div>
    """
  else:
    username, avatar_url, github_url = df.iloc[i]['Contributors'],df.iloc[i]['Avatar_URL'],df.iloc[i]['Github_page']
    past_contri += f"""
    <div class="col-lg-4 col-sm-6 text-center">
        <a href="{github_url}"><img class="img-circle img-responsive img-center" style="margin: 0 auto;border: 1px solid #dddddd;padding: 5px;" src="{avatar_url}" alt="{username}" width="90px"></a>
        <p><a href="{github_url}">{username}</a></p>
    </div>
    """

# Read the template HTML file
with open("contributorsTemp.html", "r") as f:
    html_content = f.read()

# Parse the HTML using BeautifulSoup
soup = BeautifulSoup(html_content, "html.parser")

# Remove the initial "Contributors" h1 heading if it exists (the one at the very top of the content)
# This is typically the first h1 inside the section with id="contributors"
contributors_section = soup.find("section", id="contributors")
if contributors_section:
    first_h1 = contributors_section.find("h1", string=lambda text: text and "Contributors" in text and "Current" not in text and "Previous" not in text)
    if first_h1:
        # Also remove the headerlink inside it
        first_h1.decompose()
        print("✓ Removed initial 'Contributors' heading")

# Find the target elements
target_element1 = soup.find("div", id="current-contributors-list")
target_element2 = soup.find("div", id="previous-contributors-list")

# If markers don't exist (Sphinx-generated template), add them
if target_element1 is None or target_element2 is None:
    print("Markers not found. Adding Current and Previous Contributors sections...")
    
    # Find the "Authors of the COBRA Toolbox v3.0" heading
    authors_heading = soup.find("h1", string=lambda text: text and "Authors of the COBRA Toolbox v3.0" in text)
    
    if authors_heading:
        # Create Current Contributors section
        current_h1 = soup.new_tag("h1")
        current_h1.string = "Current Contributors"
        headerlink = soup.new_tag("a", **{"class": "headerlink", "href": "#Current-Contributors", "title": "Permalink to this heading"})
        headerlink.string = "¶"
        current_h1.append(headerlink)
        
        current_br1 = soup.new_tag("br")
        current_br2 = soup.new_tag("br")
        current_row = soup.new_tag("div", **{"class": "row"})
        current_marker = soup.new_tag("div", **{"id": "current-contributors-list"})
        current_row.append(current_marker)
        current_br3 = soup.new_tag("br")
        current_br4 = soup.new_tag("br")
        
        # Create Previous Contributors section  
        previous_h1 = soup.new_tag("h1")
        previous_h1.string = "Previous Contributors"
        prev_headerlink = soup.new_tag("a", **{"class": "headerlink", "href": "#Previous-Contributors", "title": "Permalink to this heading"})
        prev_headerlink.string = "¶"
        previous_h1.append(prev_headerlink)
        
        previous_br1 = soup.new_tag("br")
        previous_br2 = soup.new_tag("br")
        previous_row = soup.new_tag("div", **{"class": "row"})
        previous_marker = soup.new_tag("div", **{"id": "previous-contributors-list"})
        previous_row.append(previous_marker)
        previous_br3 = soup.new_tag("br")
        previous_br4 = soup.new_tag("br")
        
        # Insert all elements BEFORE the "Authors" heading
        # Order will be: Principal investigators -> Current Contributors -> Previous Contributors -> Authors
        authors_heading.insert_before(current_h1)
        current_h1.insert_after(current_br1)
        current_br1.insert_after(current_br2)
        current_br2.insert_after(current_row)
        current_row.insert_after(current_br3)
        current_br3.insert_after(current_br4)
        
        current_br4.insert_after(previous_h1)
        previous_h1.insert_after(previous_br1)
        previous_br1.insert_after(previous_br2)
        previous_br2.insert_after(previous_row)
        previous_row.insert_after(previous_br3)
        previous_br3.insert_after(previous_br4)
        
        # Update references
        target_element1 = current_marker
        target_element2 = previous_marker
        
        print("✓ Successfully added contributor sections in correct order")
    else:
        print("ERROR: Could not find 'Authors of the COBRA Toolbox v3.0' heading")
        exit(1)

# Insert the content inside the target elements
target_element1.insert_after(curr_contri)
target_element2.insert_after(past_contri)

# Save the modified HTML
with open("./contributors/contributors.html", "w", encoding="utf-8") as f:
    f.write(html.unescape(soup.prettify()))

print("✓ Generated contributors.html successfully")
