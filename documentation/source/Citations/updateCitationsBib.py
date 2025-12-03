import requests
import time
import os
import re

# -------------------------------------------------------------------------
# Output file: cobratoolbox/documentation/COBRA.bib
# -------------------------------------------------------------------------
OUTPUT_BIB = os.path.join(
    os.path.dirname(__file__),
    "..",
    "..",
    "COBRA.bib"
)

# OpenAlex IDs for the three COBRA Toolbox papers
COBRA_OPENALEX_IDS = [
    "W4238101851",   # v1
    "W2147472054",   # v2
    "W2762019694",   # v3
]

# -------------------------------------------------------------------------
# Utility functions
# -------------------------------------------------------------------------

def safe(x):
    """Convert any value into a safe BibTeX string."""
    if not x:
        return ""
    if not isinstance(x, str):
        x = str(x)
    return x.replace("{", "\\{").replace("}", "\\}")


def normalise_author(name):
    """Convert 'First Last' → 'Last, First'. Skip institutional names."""
    if not name or not isinstance(name, str):
        return None

    name = name.strip()

    # Institutional authors must not enter the Author field
    if "," in name:
        return None
    if re.search(r"University|Institute|Dept|Department|Center|Hospital|Laboratory|College|School|Consortium|Team|Group", 
                 name, re.I):
        return None

    parts = name.split()
    if len(parts) < 2:
        return None

    first = " ".join(parts[:-1])
    last = parts[-1]
    return f"{last}, {first}"


# -------------------------------------------------------------------------
# Fetch citing works from OpenAlex with cursor pagination
# -------------------------------------------------------------------------

def fetch_citations(openalex_id):
    url = "https://api.openalex.org/works"
    params = {
        "filter": f"cites:{openalex_id}",
        "per_page": 200,
        "cursor": "*"
    }

    results = []

    while True:
        r = requests.get(url, params=params)
        r.raise_for_status()
        data = r.json()

        results.extend(data["results"])

        next_cursor = data["meta"].get("next_cursor")
        if not next_cursor:
            break

        params["cursor"] = next_cursor
        time.sleep(0.2)

    return results


# -------------------------------------------------------------------------
# Convert OpenAlex entry -> safe Web-of-Science-style BibTeX entry
# -------------------------------------------------------------------------

def entry_to_bibtex(entry):
    doi = entry.get("doi")
    key = doi.replace("/", "_") if doi else entry["id"].replace("https://openalex.org/", "")

    # ----------------- AUTHORS -----------------
    authors = []
    for a in entry.get("authorships", []):
        name = a.get("author", {}).get("display_name")
        norm = normalise_author(name)
        if norm:
            authors.append(norm)

    # fallback if all names are invalid
    if not authors:
        authors = ["Anonymous"]

    author_field = " and ".join(authors)

    # ----------------- BIB FIELDS -----------------
    title = safe(entry.get("title"))
    journal = safe(entry.get("host_venue", {}).get("display_name"))
    year = safe(entry.get("publication_year"))

    biblio = entry.get("biblio", {})
    volume = safe(biblio.get("volume"))
    issue = safe(biblio.get("issue"))
    first_page = safe(biblio.get("first_page"))
    last_page = safe(biblio.get("last_page"))

    if first_page and last_page:
        pages = f"{first_page}--{last_page}"
    else:
        pages = first_page

    # ----------------- BIBTEX ENTRY -----------------
    return f"""@article{{ {key},
Author = {{{author_field}}},
Title = {{{title}}},
Journal = {{{journal}}},
Year = {{{year}}},
Volume = {{{volume}}},
Number = {{{issue}}},
Pages = {{{pages}}},
DOI = {{{safe(doi)}}},
}}
"""


# -------------------------------------------------------------------------
# Main script
# -------------------------------------------------------------------------

if __name__ == "__main__":
    all_entries = {}

    # Fetch citations from each COBRA toolbox paper
    for oaid in COBRA_OPENALEX_IDS:
        print(f"Fetching citations for {oaid}...")
        papers = fetch_citations(oaid)
        print(f"  Found {len(papers)}")

        for entry in papers:
            unique_key = entry.get("doi") or entry["id"]
            all_entries[unique_key] = entry

    print(f"Total unique citing papers: {len(all_entries)}")

    # Write BibTeX file
    with open(OUTPUT_BIB, "w", encoding="utf8") as f:
        for entry in all_entries.values():
            f.write(entry_to_bibtex(entry))
            f.write("\n\n")

    print(f"COBRA.bib written to: {OUTPUT_BIB}")
