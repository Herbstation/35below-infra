#!/bin/bash
set -xe
source ./goonstation/buildByond.conf

cd goonstation
local_hash=$(git rev-parse @)
local_author=$(git log --format="%an" -n 1 $local_hash)
origin_hash=$(git rev-parse HEAD^)
origin_author=$(git log --format="%an" -n 1 $origin_hash)

build_out=$(cat << END_HEREDOC
var/global/vcs_revision = "$local_hash"
var/global/vcs_author = "$local_author"
#define VCS_REVISION "$local_hash"
#define VCS_AUTHOR "$local_author"
#define ORIGIN_REVISION "$origin_hash"
#define ORIGIN_AUTHOR "$origin_author"
#define BUILD_TIME_TIMEZONE_ALPHA "$(date +"%Z")"
#define BUILD_TIME_TIMEZONE_OFFSET $(date +"%z")
#define BUILD_TIME_FULL "$(date +"%F %T")"
#define BUILD_TIME_YEAR $(date +"%Y")
#define BUILD_TIME_MONTH $(date +"%-m")
#define BUILD_TIME_DAY $(date +"%-d")
#define BUILD_TIME_HOUR $(date +"%-H")
#define BUILD_TIME_MINUTE $(date +"%-M")
#define BUILD_TIME_SECOND $(date +"%-S")
#define BUILD_TIME_UNIX $(date +"%s")
END_HEREDOC
)
echo "$build_out" > _std/__build.dm

nonfree_location=../nonfree-patches.tar
if [ -f "$nonfree_location" ]; then
    tar -xf "$nonfree_location"
fi

cd ../

docker compose -f ./docker-compose.yaml -f ./docker-compose.prod.yaml build

cd goonstation
git reset --hard
cd ../
