#!/bin/bash
set -x
function commit_message_edited()
{
    if [ "$GERRIT_PATCHSET_NUMBER" != "1" ]; then
        OLD_PATCHSET_NUM="$(($GERRIT_PATCHSET_NUMBER-1))"
        commit_msg=$(curl -X GET https://review.gluster.org/changes/${GERRIT_PROJECT}~${GERRIT_BRANCH}~${GERRIT_CHANGE_ID}/revisions/$OLD_PATCHSET_NUM/commit |  grep message | sed 's/\\n/\'$'\n''/g')

        old_bugid=$(echo $commit_msg | grep -ow -E "([fF][iI][xX][eE][sS]|[uU][pP][dD][aA][tT][eE][sS])(:)?[[:space:]]+bz#[[:digit:]]+" | awk -F '#' '{print $2}');
        if [ -z "$old_bugid" ] ; then
            # This is needed for backward compatibility
            old_bugid=$(echo $commit_msg | grep -i '^bug: ' | awk '{print $2}')
        fi

        if [ "$bugid" == "$old_bugid" ]; then
            exit 0
        fi
    fi
}

function update_bugzilla()
{
    fixes=1
    bugid=$(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d | grep -ow -E "([fF][iI][xX][eE][sS]|[uU][pP][dD][aA][tT][eE][sS])(:)?[[:space:]]+bz#[[:digit:]]+" | awk -F '#' '{print $2}');
    update_string=$(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d | grep -ow -E "([fF][iI][xX][eE][sS]|[uU][pP][dD][aA][tT][eE][sS])(:)?[[:space:]]+bz#[[:digit:]]+" | awk -F ' ' '{print $1}');
    if [ ${update_string} == "updates:" ]; then
        fixes=0
    fi

    if [[ -z "$bugid" ]] ; then
        # Needed for backward compatibility
        bugid=$(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d | grep -i '^bug: ' | awk '{print $2}');
    fi

    if [[ -z "$bugid" ]] ; then
        # This is commit only has a github issue
        return;
    fi

    product=$(bugzilla query -b $bugid --outputformat='%{product}');
    if [ "$product" != "GlusterFS" ]; then
        echo "Wrong product: $product" >&2;
        return 1;
    fi

    #checking the type of event
    if [ "$GERRIT_EVENT_TYPE" != "change-merged" ]; then
        if [ "$GERRIT_PATCHSET_NUMBER" == "1" ]; then
            bugzilla modify  $bugid --comment="REVIEW: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME" --status POST;
        else
            commit_message_edited;
            bugzilla modify  $old_bugid --comment="REVISION POSTED: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME";
            bugzilla modify  $bugid --comment="REVIEW: $GERRIT_CHANGE_URL ($GERRIT_CHANGE_SUBJECT) posted (#$GERRIT_PATCHSET_NUMBER) for review on $GERRIT_BRANCH by $GERRIT_PATCHSET_UPLOADER_NAME" --status POST;
        fi
    else
        MERGER=$(echo "$GERRIT_PATCHSET_UPLOADER" | sed 's/\\//g')
        if [ ${fixes} == 1 ]; then
            bugzilla modify $bugid  --comment="COMMIT: $GERRIT_CHANGE_URL committed in $GERRIT_BRANCH by $MERGER with a commit message-$(echo; echo;) $(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d)" --status MODIFIED;
        else
            bugzilla modify $bugid  --comment="COMMIT: $GERRIT_CHANGE_URL committed in $GERRIT_BRANCH by $MERGER with a commit message-$(echo; echo;) $(echo $GERRIT_CHANGE_COMMIT_MESSAGE | base64 -d)";
        fi
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
