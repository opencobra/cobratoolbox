from github import Github

g = Github("cobrabot", "0835d7a0adba95c6aa6fa301943ba7335f006059")

cobratoolbox = g.get_user("opencobra").get_repo("cobratoolbox")

contributors = {}

for contributor in cobratoolbox.get_stats_contributors():
    a = 0
    d = 0
    c = 0
    for week in contributor.weeks:
        a += week.a
        d += week.d
        c += week.c
    contributors[contributor.author.login] = {
        'additions': a, 'deletions': d, 'commits': c, 'avatar': contributor.author.avatar_url}

    print "name: %20s, additions: %10d, deletions: %10d, commits: %10d" % (contributor.author.login, a, d, c)

sorted_by_commits = sorted(contributors.items(), key=lambda x: x[1]['commits'])
 
table = '\n.. raw:: html\n\n    <table style="margin:0px auto" width="100%">'
for k in range(0, 5):
    table += """\n
        <tr>
            <td width="46px"><img src="%s" width=46 height=46 alt=""></td><td><a href="https://github.com/%s">%s</a></td>
            <td width="46px"><img src="%s" width=46 height=46 alt=""></td><td><a href="https://github.com/%s">%s</a></td>
        </tr>""" % (sorted_by_commits[-(2 * k + 1)][1]['avatar'], sorted_by_commits[-(2 * k + 1)][0], sorted_by_commits[-(2 * k + 1)][0],
              sorted_by_commits[-(2 * (k + 1))][1]['avatar'], sorted_by_commits[-(2 * (k + 1))][0], sorted_by_commits[-(2 * (k + 1))][0])
table += "\n    </table>"

with open("docs/source/contributors.rst", "w") as readme:
    readme.write(table)
