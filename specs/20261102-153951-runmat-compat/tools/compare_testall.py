"""Convert testAll JUnit reports to CSV and compare two runs test by test (SC-003).

Usage:
    python3 compare_testall.py csv JUNIT_XML OUT_CSV
    python3 compare_testall.py compare BEFORE_CSV AFTER_CSV

`csv` writes one row per test case: TestName, Status (Passed, Failed or Skipped) and Time, from the
testReport.junit.xml that test/testAll.m writes when COBRA_CI=1.
`compare` prints every test whose status differs or that appears in only one run, and exits 1 if
there is any such test.
"""
import csv
import sys
import xml.etree.ElementTree as ET


def to_csv(xml_path, out_path):
    rows = []
    for case in ET.parse(xml_path).getroot().iter("testcase"):
        if case.find("skipped") is not None:
            status = "Skipped"
        elif case.find("failure") is not None or case.find("error") is not None:
            status = "Failed"
        else:
            status = "Passed"
        rows.append((case.get("name"), status, case.get("time")))
    with open(out_path, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(("TestName", "Status", "Time"))
        writer.writerows(rows)
    counts = {s: sum(r[1] == s for r in rows) for s in ("Passed", "Failed", "Skipped")}
    print(f"{len(rows)} tests: {counts}")


def load(path):
    with open(path, newline="") as f:
        return {row["TestName"]: row["Status"] for row in csv.DictReader(f)}


def compare(before_path, after_path):
    before, after = load(before_path), load(after_path)
    diffs = []
    for name in sorted(set(before) | set(after)):
        b, a = before.get(name, "absent"), after.get(name, "absent")
        if a != b:
            diffs.append((name, b, a))
    print(f"before {len(before)} tests, after {len(after)} tests, {len(diffs)} differences")
    for name, b, a in diffs:
        print(f"{name}\t{b}\t{a}")
    return 1 if diffs else 0


if __name__ == "__main__":
    if len(sys.argv) == 4 and sys.argv[1] == "csv":
        to_csv(sys.argv[2], sys.argv[3])
    elif len(sys.argv) == 4 and sys.argv[1] == "compare":
        sys.exit(compare(sys.argv[2], sys.argv[3]))
    else:
        sys.exit(__doc__)
