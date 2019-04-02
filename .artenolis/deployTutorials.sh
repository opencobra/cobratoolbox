# DESCRIPTION:
#   deploy tutorials of the COBRA Toolbox

# set the local branch
echo $GIT_LOCAL_BRANCH

# update the cobra tutorials repository
cd $ARTENOLIS_ROOT_PATH_MAC/repos/COBRA.tutorials
git stash
git checkout $GIT_LOCAL_BRANCH
git pull origin $GIT_LOCAL_BRANCH

# update the cobratoolbox repository
cd $ARTENOLIS_ROOT_PATH_MAC/repos/cobratoolbox
git stash
git checkout $GIT_LOCAL_BRANCH
git pull origin $GIT_LOCAL_BRANCH
git submodule update --init

# generate and deploy the tutorials
cd $ARTENOLIS_ROOT_PATH_MAC/repos/cobratoolbox
$ARTENOLIS_ROOT_PATH_MAC/repos/cobratoolbox/docs/prepareTutorials.sh -c=$ARTENOLIS_ROOT_PATH_MAC/repos/cobratoolbox -t=$ARTENOLIS_ROOT_PATH_MAC/repos/COBRA.tutorials -p=$ARTENOLIS_ROOT_PATH_MAC/scratch -m=html,pdf,png