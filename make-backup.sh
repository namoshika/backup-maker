#!/bin/bash -eu

# setting
SCRIPT_DIR=$(cd $(dirname $0); pwd)
. $SCRIPT_DIR/setting.sh

echo INFO: prepare
BACKUP_PATTERN=$(basename $BACKUP_TARGET)
BACKUP_DST_CURRENT=`find "$BACKUP_TO" -maxdepth 1 -mindepth 1 -type d -name "${BACKUP_PATTERN}_*" | tail -1`
BACKUP_DST_NEW=${BACKUP_TO}${BACKUP_PATTERN}_$(date '+%Y%m%d_%H%M%S')

echo 'TRACE: backup_to:' $BACKUP_TO
echo 'TRACE: backup_target:' $BACKUP_TARGET

# 各種機能
function backup() {
    echo 'TRACE: backup_dst_current:' $BACKUP_DST_CURRENT
    echo 'TRACE: backup_dst_new:' $BACKUP_DST_NEW

    echo INFO: backup
    mkdir -p $BACKUP_TO
    if [ -d "$BACKUP_DST_CURRENT" ]; then
        echo "TRACE: rsync ($BACKUP_DST_NEW) with hard link..."
        rsync -a --delete --link-dest $BACKUP_DST_CURRENT $BACKUP_TARGET $BACKUP_DST_NEW
    else
        echo "TRACE: rsync ($BACKUP_DST_NEW)..."
        rsync -a --delete $BACKUP_TARGET $BACKUP_DST_NEW
    fi

    echo INFO: remove old backup
    BACKUP_OLD=`find "$BACKUP_TO" -maxdepth 1 -mindepth 1 -type d -name "${BACKUP_PATTERN}_*" | sort | head -n -$BACKUP_GEN`
    for OLD_BK in $BACKUP_OLD; do
        echo "INFO: rm $OLD_BK"
        rm -rf $OLD_BK
    done
}
function restore() {
    echo INFO: restore
    echo TRACE: from $OPTARG
    echo TRACE: to $BACKUP_TARGET
    rsync -a --delete $OPTARG $BACKUP_TARGET
}

# Entry point
while getopts br: OPT; do
    case $OPT in
        'b') backup;;
        'r') restore;;
    esac
done
