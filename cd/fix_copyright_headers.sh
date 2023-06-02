#!/bin/bash

# Copyright 2022 Crown Copyright
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

emptyIfInvalidDir=`stat cd`
if [ -z "$emptyIfInvalidDir" ]
then
  echo "This script needs to be run from the root directory of the repository"
  exit 1
fi

currentYear=$(date +%Y)
diff=`git diff origin/develop --name-only --cached`

if [ -n "$diff" ]
then
  for modifiedFile in $diff
  do
    if [ -f "$modifiedFile" ]
    then
      header=`sed -nE "/Copyright (....-)?.... Crown/p" $modifiedFile`
      currentHeader=`echo "$header" | sed -nE "/Copyright (....-)?$currentYear Crown/p"`
      fileNeedsHeader=`echo "$modifiedFile" | sed -nE "/.*(Dockerfile|\.yml|\.yaml|\.tpl|\.sh|\.py|\.xml)$/p"`
      if [ -n "$header" ] && [ -z "$currentHeader" ] # If header exists but is not up to date
      then
        dateRange=`sed -nE "/Copyright (....-....) Crown/p" $modifiedFile`
        if [ -n "$dateRange" ]
        then
          sed -E -i '' -e "s/^(.*Copyright )(....)-(....)(.*)$/\1\2-$currentYear\4/g" $modifiedFile
        else
          sed -E -i '' -e "s/^(.*Copyright )(....)(.*)$/\1\2-$currentYear\3/g" $modifiedFile
        fi
        echo "Updated Copyright Header in '$modifiedFile'"
      elif [ -n "$fileNeedsHeader" ] && [ -z "$currentHeader" ] # If header is required but doesn't exist
      then
        echo "Missing any Copyright Header in '$modifiedFile', must be added manually"
        error=true
      fi
    fi
  done
else
  echo "Empty Diff"
  exit 1
fi

# Return error code if manual changes are needed
if [ -n "$error" ]
then
  echo "Found files(s) where Copyright Header(s) must be added manually"
  exit 1
else
  echo "No Copyright Headers require updating."
fi
