#!/bin/bash
set -x
function commit_message_edited()
{
    if [ "$GERRIT_PATCHSET_NUMBER" != "1" ]; then
        OLD_PATCHSET_NUM="$(($GERRIT_PATCHSET_NUMBER-1))"
        old_bugid=$(curl -X GET https://review.gluster.org/changes/${GERRIT_PROJECT}~${GERRIT_BRANCH}~${GERRIT_CHANGE_ID}/revisions/$OLD_PATCHSET_NUM/commit |  grep message | sed 's/\\n/\'$'\n''/g' | grep -i '^bug: ' | awk '{print $2}')
        if [ "$bugid" == "$old_bugid" ]; then
            exit 0
        fi
    fi
}

function update_bugzilla()
{
    bugid=$(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d | grep -i '^bug: ' | awk '{print $2}');
    [ -z "$bugid" ] && return;

    product=$(bugzilla query -b $bugid --outputformat='%{product}');
    if [ "$product" != "GlusterFS" ]; then
        echo "Wrong product: $product" >&2;
        return 1;
    fi

    #checking the type of event
    if [ "$GERRIT_EVENT_TYPE" != "change-merged" ]; then
        if [ "$GERRIT_PATCHSET_NUMBER" == "1" ]; then
            bugzilla modify  $bugid --comment="REVIEW: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME";
        else
            commit_message_edited;
            bugzilla modify  $old_bugid --comment="REVISION POSTED: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME";
            bugzilla modify  $bugid --comment="REVIEW: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME";
        fi
    else
      MERGER=$(echo "$GERRIT_PATCHSET_UPLOADER" | sed 's/\\//g')
      bugzilla modify $bugid  --comment="COMMIT: $GERRIT_CHANGE_URL committed in $GERRIT_BRANCH by $MERGER with a commit message-$(echo; echo;) $(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d)";
    fi
}

function main()
{
    if [ "$GERRIT_PROJECT" != "glusterfs" ]; then
        return;
    fi
    update_bugzilla;
}

main;
