#!/bin/bash

function commit_message_edited()
{
    if [ "$GERRIT_PATCHSET_NUMBER" != "1" ]; then
        OLD_PATCHSET_NUM="$(($GERRIT_PATCHSET_NUMBER-1))"
        old_bugid=$(curl -X GET https://review.gluster.org/changes/${GERRIT_PROJECT}~${GERRIT_BRANCH}~${GERRIT_CHANGE_ID}/revisions/$OLD_PATCHSET_NUM/commit |  grep message | awk -F'"' '{print $4}' | sed 's/\\n/\'$'\n''/g' | grep -i '^bug: ' | awk '{print $2}')
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
            run bugzilla modify  $bugid --comment="REVIEW: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME";
        else
            commit_message_edited;
            run bugzilla modify  $bugid --comment="REVISION POSTED: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME";
        fi
    else
        run bugzilla modify $bugid  --comment="COMMIT: $GERRIT_CHANGE_URL committed in $GERRIT_BRANCH by $GERRIT_SUBMITTER $(echo; echo -------------; echo;) $(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d)";
    fi
}

function run()
{
    if [[ "$DRY_RUN" ]]; then
        echo $@
    else
        $@
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

