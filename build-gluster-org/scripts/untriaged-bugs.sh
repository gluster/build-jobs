#!/bin/bash
set -e
echo "Weekly GlusterFS Untriaged Bugs Report"
echo ""
bugzilla query --outputformat='https://bugzilla.redhat.com/%{id} / %{component}: %{summary}' --from-url='https://bugzilla.redhat.com/buglist.cgi?bug_status=NEW&product=GlusterFS&chfield=[Bug creation]&chfieldfrom=-4w&chfieldto=Now&f1=keywords&o1=notsubstring&v1=Triaged' | sort -k 3
