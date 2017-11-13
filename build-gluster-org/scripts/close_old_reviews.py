#!/usr/bin/env python

import requests
import json
import os


def get_unique_id(days=90, count=25):
    r = requests.get('https://review.gluster.org/changes/
                     '?q=status:open+age:{}days+project:glusterfs'.
                     format(days))
    output = r.text
    cleaned_output = '\n'.join(output.split('\n')[1:])
    parsed_output = json.loads(cleaned_output)
    unique_id = []
    for item in parsed_output:
        unique_id.append(item['changed_id'])
    n = -(int(count))
    oldest_reviews = unique_id[n:]
    return oldest_reviews


def close_reviews(oldest_id):
    for uid in oldest_id:
        try:
            url = https://review.gluster.org/a/changes/glusterfs~master~{}/abandon.format(uid)
            data = {"message" : "This change has not had activity in 90 days."
                    "We're automatically closing this change.\n"
                    "Please re-open and get in touch with the component owners"
                    " if you are interested in merging this patch."}
            username = os.environ.get('HTTP_USERNAME')
            password = os.environ.get('HTTP_PASSWORD')
            respone = requests.post(url, auth('username', 'password'), json=data)
            response.raise_for_status()
        except Exception:
            print("Authentication error.Username or password is incorrect")


def main():

    # get the list of oldest unique_id
    days = os.environ.get('DAYS')
    count = os.environ.get('REV_COUNT')
    ids = get_unique_id(days, count)

    # abandoning those reviews with a message
    close_reviews(ids)

    # printing the list of abandoned reviews
    print("The list of following reviews are abandoned:\n")
    for x in ids:
        print('https://review.gluster.org/#/q/{}\n'.format(str(x)))

main()
