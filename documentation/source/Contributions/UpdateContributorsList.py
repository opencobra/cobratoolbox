import requests
import datetime
import time
from dateutil.relativedelta import relativedelta
import pandas as pd
import numpy as np

# A function to get the contributors list for the past one year
def get_contributors_from_commits(owner, repo, start_date, end_date):
    """Gets a list of contributors from commits within a specified time frame."""

    url = f"https://api.github.com/repos/{owner}/{repo}/commits"
    params = {"since": start_date.isoformat() + "Z", "until": end_date.isoformat() + "Z","per_page":100}

    contributors = set()
    response = requests.get(url, params=params)
    while response:
        for commit in response.json():
          if not commit["author"] is None:
            contributors.add(commit["author"]["login"])
        # Handle pagination
        if "next" in response.links:
          time.sleep(1)
          response = requests.get(response.links["next"]["url"])
        else:
          break
    return contributors
 
# A function to get all the contributors to the cobra toolbox
def GetAllContributors():
  owner = "opencobra"
  repo = "cobratoolbox"
  url = f"https://api.github.com/repos/{owner}/{repo}/contributors"
  params = {"per_page":100}

  # empty lists to store the contributors list and their info
  contributors =[]
  avt_url=[]
  github_page=[]
  n_contributions=[]

  response = requests.get(url, params=params)
  while response:
      for commit in response.json():
          contributors.append(commit["login"])
          avt_url.append(commit['avatar_url'])
          github_page.append(commit['html_url'])
          n_contributions.append(commit["contributions"])
      if "next" in response.links:
          time.sleep(1)
          response = requests.get(response.links["next"]["url"])
      else:
          break

  # dataframe to store the retrieved data in .csv file
  df = pd.DataFrame()
  df['Contributors'] = contributors
  df['Avatar_URL'] = avt_url
  df['Github_page'] = github_page
  df['n_Contributions'] = n_contributions
  df.to_csv('AllContributors.csv',index=0)

# Get the current contributors
owner = "opencobra"
repo = "cobratoolbox"

end_date = datetime.datetime.now()  # End date (today's date)
start_date = end_date-relativedelta(years=1)   # Start date (End date - 1 year)
contributors = get_contributors_from_commits(owner, repo, start_date, end_date)

# Check if current contributors are in AllContributors list
df = pd.read_csv('AllContributors.csv')
AllContri  = set(df['Contributors'])

# Update the All contributors list if there is any new contributor
if len(contributors-AllContri)!=0:
  GetAllContributors()
  df = pd.read_csv('AllContributors.csv')

# Mark the current contributors (past 1 year)
df['CurrentContributor'] = np.in1d(np.array(df['Contributors']),np.array(list(contributors)))
df.to_csv('AllContributors.csv',index=0)