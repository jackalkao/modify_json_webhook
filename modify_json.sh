#!/bin/bash

webhook_url=$1
#full_json_file=$2
diff_json_file=$3

#Check webhook url and diff json file not null
[ -z "$webhook_url" ] && {
  echo -e "\033[41;37mPlease set webhook url\033[0m"
  exit
}

[ -z "$diff_json_file" ] && {
  echo -e "\033[41;37mPlease set json file name\033[0m"
  exit
}

num=0
while true
do
 for n in $num
 do
  ###get all json data in json file###
  output_warning_type=`cat $diff_json_file | jq '.new' | jq ".[$n]"`
  [ -z "$output_warning_type" -o "$output_warning_type" = "null" ] &&
  {
   break
  }
  echo "{" > brakeman-output-"$n".json
  echo '"warning_info": [' >> brakeman-output-"$n".json
  echo $output_warning_type >> brakeman-output-"$n".json
  echo '],' >> brakeman-output-"$n".json

  ###update the commuit info###
  #git_project_path=`cat $full_json_file | grep app_path | awk -F'"' '{print $4}'`
  #repo=`cat $full_json_file | grep app_path | awk -F'"' '{print $4}' | awk -F'/' '{print $4}'`
  #git_branch=`cd /tmp/$repo/$repo && git log -1 --pretty=format:%d | awk -F"," '{print $2}' | awk -F"origin/" '{print $2}' | awk -F")" '{print $1}'`
  #git_commit_info=`cd /tmp/$repo/$repo && git log -1 --pretty=format:'  "git_commit": [%n    {%n      "id": "%H",%n      "message": "%s",%n      "notes": "%N",%n      "name": "%aN",%n      "email": "%aE",%n      "date": "%aD",%n      "branch": "'$git_branch'"%n    }%n  ],%n'`
  repo=`echo $2 | awk -F"," '{print $1}'`
  git_branch=`echo $2 | awk -F"," '{print $2}'`
  git_commit_info=`git log -1 --pretty=format:'  "git_commit": [%n    {%n      "id": "%H",%n      "message": "%s",%n      "notes": "%N",%n      "name": "%aN",%n      "email": "%aE",%n      "date": "%aD",%n      "branch": "'$git_branch'"%n    }%n  ],%n'`
  echo "$git_commit_info" >> brakeman-output-"$n".json

  ###update repo info###
  echo '"repo_name": "'$repo'"' >> brakeman-output-"$n".json
  echo '}' >> brakeman-output-"$n".json
  curl -X POST $webhook_url -H "Content-Type:\ application/json" -d @"brakeman-output-"$n".json"
  rm -rf brakeman-output-"$n".json
  sleep 60
  num=$(( $n + 1 ))
 done
  [ -z "$output_warning_type" -o "$output_warning_type" = "null" ] &&
  {
   break
  }
done

#for t in `echo "scan_info ignored_warnings errors obsolete"`
#do
# check_data=`cat brakeman-output.json | jq '.'$t`
# [ "$check_data" = '[]' ] && {
#  continue
# } || {
#  echo '"'$t'":' >> new_brakeman-output.json
#  echo $check_data >>  new_brakeman-output.json
# }
#done


