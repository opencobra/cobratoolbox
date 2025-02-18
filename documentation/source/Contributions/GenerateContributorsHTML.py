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

# Find the target element (replace with curr_contri)
target_element1 = soup.find("div", id="current-contributors-list")

# Insert the content inside the target element
target_element1.insert_after(curr_contri)

# Find the target element (replace with past_contri)
target_element2= soup.find("div", id="previous-contributors-list")

# Insert the content inside the target element
target_element2.insert_after(past_contri)

# Save the modified HTML
with open("./contributors/contributors.html", "w") as f:
    f.write(html.unescape(soup.prettify()))
