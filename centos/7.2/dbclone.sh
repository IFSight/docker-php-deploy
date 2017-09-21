#!/bin/sh

if [ "$#" -ne 8 ]; then
  echo "Usage: $0 <DST_DB_HOST> <DST_DB_USER> <DST_DB_NAME> <DST_DB_PWD> <SRC_DB_HOST> <SRC_DB_USER> <SRC_DB_NAME> <SRC_DB_PWD>" >&2
  exit 1
fi

RND=$(dd if=/dev/urandom bs=100 count=1 2> /dev/null | (md5sum 2> /dev/null) | cut -f1 -d" ")
FIFO="/tmp/dbprogress-$RND"

DST_DB_HOST=$1
DST_DB_NAME=$2
DST_DB_USER=$3
DST_DB_PWD=$4
SRC_DB_HOST=$5
SRC_DB_NAME=$6
SRC_DB_USER=$7
SRC_DB_PWD=$8

TABLEEXP="sessions|watchdog|search|cache|migrate|purge_queuer_url"

mkfifo $FIFO &&

stdbuf -o0 echo "Truncating tables" &&
stdbuf -o0 mysqldump -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" --add-drop-table --no-data $DST_DB_NAME |
egrep "$TABLEEXP" |
grep --line-buffered -e '^DROP ' |
sed 's/DROP TABLE IF EXISTS/TRUNCATE TABLE/g' |
stdbuf -o0 mysql -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" $DST_DB_NAME &&

stdbuf -o0 echo "Dropping existing tables" &&
stdbuf -o0 mysqldump -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" --add-drop-table --no-data $DST_DB_NAME |
egrep -v "$TABLEEXP" |
grep --line-buffered -e '^DROP \| FOREIGN_KEY_CHECKS' |
stdbuf -o0 mysql -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" $DST_DB_NAME &&

stdbuf -o0 echo "Cloning back database" &&
(
  stdbuf -o0 mysqldump --max-allowed-packet=16M -h $SRC_DB_HOST -u $SRC_DB_USER -p"$SRC_DB_PWD" $SRC_DB_NAME 2> $FIFO |
  pv --numeric --timer --interval 5                                                                          2> $FIFO |
  stdbuf -o0 mysql     --max-allowed-packet=16M -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" $DST_DB_NAME 2> $FIFO &
) &&
cat < $FIFO &&

rm $FIFO
