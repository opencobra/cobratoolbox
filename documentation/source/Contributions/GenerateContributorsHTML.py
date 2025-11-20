# This code uses the AllContributors.csv file to parse the list of current and previous contributors
# and makes changes to the contributorsTemp.html file and produces contributors.html

from bs4 import BeautifulSoup
import pandas as pd

# 1) Load contributors data
df = pd.read_csv("AllContributors.csv")

curr_contri = []
past_contri = []
for _, row in df.iterrows():
    username = row["Contributors"]
    avatar_url = row["Avatar_URL"]
    github_url = row["Github_page"]

    card_html = f"""
    <div class="col-lg-4 col-sm-6 text-center">
        <a href="{github_url}">
            <img class="img-circle img-responsive img-center"
                 style="margin: 0 auto;border: 1px solid #dddddd;padding: 5px;"
                 src="{avatar_url}" alt="{username}" width="90px">
        </a>
        <p><a href="{github_url}">{username}</a></p>
    </div>
    """

    if bool(row["CurrentContributor"]):
        curr_contri.append(card_html)
    else:
        past_contri.append(card_html)

curr_fragment_html = "\n".join(curr_contri)
past_fragment_html = "\n".join(past_contri)

# 2) Load and parse the template
with open("contributorsTemp.html", "r", encoding="utf-8") as f:
    soup = BeautifulSoup(f.read(), "html.parser")

# 3) Ensure sections exist (insert before the "Authors..." heading if missing)
authors_heading = soup.find("h1", string=lambda t: t and "Authors of the COBRA Toolbox v3.0" in t)

# Current contributors marker
current_marker = soup.find("div", id="current-contributors-list")
previous_marker = soup.find("div", id="previous-contributors-list")

def build_section(title_text, marker_id):
    h1 = soup.new_tag("h1")
    h1.string = title_text
    headerlink = soup.new_tag("a", **{
        "class": "headerlink",
        "href": f"#{marker_id.replace('-list','')}",
        "title": "Permalink to this heading"
    })
    headerlink.string = "¶"
    h1.append(headerlink)

    br1 = soup.new_tag("br")
    br2 = soup.new_tag("br")
    row = soup.new_tag("div", **{"class": "row"})
    marker = soup.new_tag("div", id=marker_id)
    row.append(marker)
    br3 = soup.new_tag("br")
    br4 = soup.new_tag("br")
    return (h1, br1, br2, row, br3, br4, marker)

# If either marker is missing, create the pair in order before Authors
if (current_marker is None or previous_marker is None):
    if authors_heading is None:
        print("ERROR: Could not find 'Authors of the COBRA Toolbox v3.0' heading")
        raise SystemExit(1)

    cur_h1, cbr1, cbr2, cur_row, cbr3, cbr4, current_marker = build_section(
        "Current Contributors", "current-contributors-list"
    )
    prev_h1, pbr1, pbr2, prev_row, pbr3, pbr4, previous_marker = build_section(
        "Previous Contributors", "previous-contributors-list"
    )

    # Insert in correct order before Authors heading
    authors_heading.insert_before(prev_h1)
    prev_h1.insert_before(cbr4)
    cbr4.insert_before(cbr3)
    cbr3.insert_before(cur_row)
    cur_row.insert_before(cbr2)
    cbr2.insert_before(cbr1)
    cbr1.insert_before(cur_h1)

    prev_h1.insert_after(pbr1)
    pbr1.insert_after(pbr2)
    pbr2.insert_after(prev_row)
    prev_row.insert_after(pbr3)
    pbr3.insert_after(pbr4)

# 4) Populate the markers (clear first, then append inside)
def replace_inner_html(marker, fragment_html):
    # Remove existing children
    for child in list(marker.contents):
        child.decompose()
    # Parse the fragment and append nodes into the marker
    frag_soup = BeautifulSoup(fragment_html, "html.parser")
    for node in list(frag_soup.contents):
        marker.append(node)

replace_inner_html(current_marker, curr_fragment_html)
replace_inner_html(previous_marker, past_fragment_html)

# 5) Write the result once
# Using str(soup) avoids unnecessary entity mangling that can corrupt the sidebar
output_path = "./contributors/contributors.html"
with open(output_path, "w", encoding="utf-8") as f:
    f.write(str(soup))

print("✓ Generated contributors.html successfully")
