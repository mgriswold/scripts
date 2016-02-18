#!/bin/bash

blockcount=0
titlecount=0

srtfile="$1"
offset="$2"

newfile="new-$srtfile"

[ -f "$newfile" ] && rm "$newfile"

function do_offset() {
  hrs=`echo $base_time | cut -f 1 -d ':' | sed 's/^0*//'`
  [ -z $mins ] && hrs=0

  mins=`echo $base_time | cut -f 2 -d ':' | sed 's/^0*//'`
  [ -z $mins ] && mins=0

  secs1=`echo $base_time | cut -f 3 -d ':' | cut -f 1 -d ,`
  secs2=`echo $base_time | cut -f 3 -d ':' | cut -f 2 -d ,`
  secs=${secs1}${secs2}
  secs=$(echo $secs | sed 's/^0*//')
  secs=$((secs + $offset))

  if [ $secs -gt 60000 ]; then
    secs=$(($secs - 60000))
    mins=$((mins + 1))
    if [ $mins -gt 59 ]; then
      mins=0
      hrs=$(($hrs + 1))
    fi
  fi

  if [ $mins -lt 10 ]; then
    mins="0${mins}"
  fi

  if [ $secs -lt 10000 ]; then
    secs="0${secs}"
  fi

  secs=`echo "$secs" | sed 's/^\(.\{2\}\)/\1,/'`
  echo "0${hrs}:${mins}:${secs}"
}

while read srtline; do

  blockcount=$((blockcount + 1))

  if [ $blockcount = 1 ]; then
    echo "$srtline"
    titlecount=$((titlecount + 1))
    echo "$titlecount" >> "$newfile"
  fi

  if [ $blockcount = 2 ]; then
    begin_time=`echo $srtline | cut -f 1 -d ' '`
    end_time=`echo $srtline | cut -f 3 -d ' ' | cut -f 1 -d `

    base_time=$begin_time
    begin_time=$(do_offset)

    base_time=$end_time
    end_time=$(do_offset)

    echo "$begin_time --> $end_time" >> $newfile
  fi

  if [ $blockcount -ge 3 ]; then
    if [[ "$srtline" != "" ]]; then
      echo "$srtline" >> "$newfile"
    else
      echo '' >> "$newfile"
      blockcount=0
    fi
  fi

done < "$srtfile"

