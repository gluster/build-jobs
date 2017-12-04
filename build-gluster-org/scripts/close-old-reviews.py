#!/usr/bin/env python
'''
A small script to close old reviews in Gerrit
'''
from __future__ import absolute_import
from __future__ import print_function
import json
import os
import sys
import requests


def get_change_ids(days=90, count=25):
    '''
    Get all the change IDs to close
    '''
    r = requests.get('https://review.gluster.org/changes/'
                     '?q=status:open+age:{}days+'
                     'project:glusterfs'.format(days))
    output = r.text
    cleaned_output = '\n'.join(output.split('\n')[1:])
    parsed_output = json.loads(cleaned_output)[-int(count):]
    return parsed_output


def close_reviews(change_ids):
    '''
    Close the list of given change_ids
    '''
    for change in change_ids:
        url = ('https://review.gluster.org/a/changes/{}'
               '/abandon'.format(change['id']))
        data = {
            "message": "This change has not had activity in 90 days. "
                       "We're automatically closing this change.\n"
                       "Please re-open and get in touch with the component "
                       "owners if you are interested in merging this patch."
        }
        username = os.environ.get('HTTP_USERNAME')
        password = os.environ.get('HTTP_PASSWORD')
        print("Attempting to close review: ", "https://review.gluster.org/",
              change['_number'],
              "  -- Title: ",
              change['subject'])
        response = requests.post(url, auth=(username, password), json=data)
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError:
            print(response.text)
            sys.exit(1)


def main():
    '''
    Put all the pieces together
    '''
    # get the list of oldest unique_id
    days = os.environ.get('DAYS', 90)
    count = os.environ.get('REV_COUNT', 25)
    change_ids = get_change_ids(days, count)

    # abandoning those reviews with a message
    close_reviews(change_ids)


main()
