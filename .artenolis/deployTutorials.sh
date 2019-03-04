# DESCRIPTION:
#   deploy tutorials of the COBRA Toolbox

# set the local branch
GIT_LOCAL_BRANCH='"'$GIT_LOCAL_BRANCH'"'
echo $GIT_LOCAL_BRANCH

# update the cobra tutorials repository
cd $ARTENOLIS_ROOT_PATH_MAC/COBRA.tutorials
git stash
git checkout $GIT_LOCAL_BRANCH
git pull origin $GIT_LOCAL_BRANCH

# update the cobratoolbox repository
cd ~/artenolis/cobratoolbox
git stash
git checkout $GIT_LOCAL_BRANCH
git pull origin $GIT_LOCAL_BRANCH
git submodule update --init

# generate and deploy the tutorials
cd ~/artenolis/cobratoolbox
~/artenolis/cobratoolbox/docs/prepareTutorials.sh -c=~/artenolis/cobratoolbox -t=~/artenolis/COBRA.tutorials -p=~/artenolis -m=html,pdf,png