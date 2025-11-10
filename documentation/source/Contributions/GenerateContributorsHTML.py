# --- Locate (or create) the target sections, then populate and write once ---

# Try to find the marker divs
current_div = soup.find("div", id="current-contributors-list")
previous_div = soup.find("div", id="previous-contributors-list")

# If either marker is missing, create the sections just before the "Authors..." heading
if current_div is None or previous_div is None:
    print("Markers not found. Adding Current and Previous Contributors sections...")
    authors_heading = soup.find("h1", string=lambda t: t and "Authors of the COBRA Toolbox v3.0" in t)
    if not authors_heading:
        raise RuntimeError("Could not find 'Authors of the COBRA Toolbox v3.0' heading")

    # Current Contributors section
    current_h1 = soup.new_tag("h1")
    current_h1.string = "Current Contributors"
    headerlink = soup.new_tag(
        "a",
        **{"class": "headerlink", "href": "#current-contributors", "title": "Permalink to this heading"}
    )
    headerlink.string = "¶"
    current_h1.append(headerlink)

    current_br1 = soup.new_tag("br")
    current_br2 = soup.new_tag("br")
    current_row = soup.new_tag("div", **{"class": "row"})
    current_div = soup.new_tag("div", id="current-contributors-list")
    current_row.append(current_div)
    current_br3 = soup.new_tag("br")
    current_br4 = soup.new_tag("br")

    # Previous Contributors section
    previous_h1 = soup.new_tag("h1")
    previous_h1.string = "Previous Contributors"
    prev_headerlink = soup.new_tag(
        "a",
        **{"class": "headerlink", "href": "#previous-contributors", "title": "Permalink to this heading"}
    )
    prev_headerlink.string = "¶"
    previous_h1.append(prev_headerlink)

    previous_br1 = soup.new_tag("br")
    previous_br2 = soup.new_tag("br")
    previous_row = soup.new_tag("div", **{"class": "row"})
    previous_div = soup.new_tag("div", id="previous-contributors-list")
    previous_row.append(previous_div)
    previous_br3 = soup.new_tag("br")
    previous_br4 = soup.new_tag("br")

    # Insert before the Authors heading
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

# Populate the marker divs with the generated HTML (replace any existing content)
current_div.clear()
current_div.append(BeautifulSoup(curr_contri, "html.parser"))

previous_div.clear()
previous_div.append(BeautifulSoup(past_contri, "html.parser"))

# Write the final HTML once
with open("./contributors/contributors.html", "w", encoding="utf-8") as f:
    f.write(html.unescape(soup.prettify()))

print("✓ Generated contributors.html successfully")
