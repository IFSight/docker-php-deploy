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

mkfifo $FIFO &&
mysqldump -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" --add-drop-table --no-data $DST_DB_NAME |
grep -e '^DROP \| FOREIGN_KEY_CHECKS' |
mysql -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" $DST_DB_NAME &&
(
  mysqldump --max-allowed-packet=16M -h $SRC_DB_HOST -u $SRC_DB_USER -p"$SRC_DB_PWD" $SRC_DB_NAME 2> $FIFO |
  pv --numeric --timer --interval 10                                                              2> $FIFO |
  mysql     --max-allowed-packet=16M -h $DST_DB_HOST -u $DST_DB_USER -p"$DST_DB_PWD" $DST_DB_NAME 2> $FIFO &
) &&
cat < $FIFO &&
rm $FIFO
