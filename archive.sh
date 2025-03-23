set -ex -o pipefail

ARCHIVE_FOLDER=archives/$(date +%Y/%b)
DATE_PREFIX=$(date +%Y-%b-%d-%s)
DATA_ARCHIVE_NAME=$DATE_PREFIX.tar.xz

mkdir -p "$ARCHIVE_FOLDER"
tar -cJf "$ARCHIVE_FOLDER/$DATA_ARCHIVE_NAME" goon_data
