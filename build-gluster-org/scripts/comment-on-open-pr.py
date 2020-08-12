#!/usr/bin/env python
'''
A small script to comment on opened PR for reviews on Gerrit
'''
import json
import os
import sys
import requests

r = requests.get('https://review.gluster.org/changes/'
                     '?q=status:open+'
                     'project:glusterfs')

output = r.text
    cleaned_output = '\n'.join(output.split('\n')[1:])
    parsed_output = json.loads(cleaned_output)[1:]


for change in parsed_output:
        url = ('https://review.gluster.org/a/changes/{}/revisions/current/review'
               .format(change['id']))
        data = {
            "message": "This PR needs to be migrated to Github glusterfs repo"
                       "More information about migration can be forund here:"
                       "https://docs.google.com/document/d/1SOPr56naVXXtkOmRu48xqKsefxM435UuN1Zoja2UhFE/edit#heading=h.z8c6k6xpfllw"
        }
        username = os.environ.get('HTTP_USERNAME')
        password = os.environ.get('HTTP_PASSWORD')
        print("Posting a comment on: ", "https://review.gluster.org/"
              + format(change['_number']),
              "  -- Title: ",
              change['subject'])
        response = requests.post(url, auth=(username, password), json=data)
        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError:
            print(response.text)
            sys.exit(1)    

