#!/bin/bash
Time=`date +%F`
read -p "请输入项目本地绝对地址" loc
read -p "请输入项目分支，默认master" branch
read -p "请输入开始日期（eg:2020-05-01），默认为全量" std
read -p "请输入结束日期（eg:2020-05-01），默认为今天" edd
echo "正在分析git提交记录"

mkdir -p ~/gitlog/`date +%F`/

# branch=${barnch:-"master"}
# std=${std:-"2000"}
# edd=${edd:-$Time}

echo $branch

cd $loc
git pull
git checkout $branch

res=`git log --format='%aN' --since="$std" --until="$edd" | sort -u | while read name; do echo "$name\t"; git log --author="$name" --pretty=tformat: --numstat --since="$std" --until="$edd" | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "addedlines:%s,removedlines:%s,totallines:%s", add, subs, loc }' -; done`

echo $res > ~/gitlog/`date +%F`/$Time.txt

jres=`git log --no-merges --since="$std" --until="$edd"\
        --date=iso --pretty=format:'{"commit": "${prefix}/commit/%H","author": "%aN", "email": "%aE","date": "%ad","message": "%s"},' \
        $@ | \
        perl -pe 'BEGIN{print "["}; END{print "]\n"}' | \
        perl -pe 's/},]/}]/'`

echo $jres > ~/gitlog/`date +%F`/$Time-author.json

open  ~/gitlog/`date +%F`/
