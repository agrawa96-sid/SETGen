#!/bin/bash

# Check if User is ROOT or not
if [ "$EUID" -ne 0 ]
then echo "Please run as root"
exit
fi

echo "Current Disk Stats:"
df
echo

echo "Please enter the prefix of VHDs you would like to delete:"
read name

while [[ -z "$name" ]]; do
  echo "The prefix can't be empty. Please try again!"
  echo
  echo "Please specify the prefix name of the VHDs."
  read name
done

echo "Please enter the path to directory containing the VHDs:"
read path

while ! [[ -d $path ]]; do
  echo "Invalid directory. Please try again!"
  echo
  echo "Please enter the path to directory containing the VHDs:"
  read path
done

count=$(ls $path | grep "$name[0-9]*.img" | wc -l)

if [[ $count -lt 1 ]]; then
  echo "There are no VHD(s) with prefix as $name in $path"
  echo
  sleep 0.5
  echo "Exiting to main menu..."
  exit
fi

echo "Please enter the number of VHDs you would like to delete:"
read num

while ! [[ "$num" =~ ^[0-9]+$ ]]; do
  echo "Invalid input. Please try again!"
  echo
  echo "Please enter the number of VHDs you would like to delete:"
  read num
done

if [[ $num -gt $count ]]; then
  echo 
  echo "The number exceeds the number of VHDs in the directory!"
  sleep 0.5
  echo "Exiting to main menu..."
  exit
fi

echo "Please enter the starting point:"
echo "Forexample, if you specify 2, the script will delete prefix2, prefix3 and so on..."
read st

while ! [[ "$st" =~ ^[0-9]+$ ]]; do
  echo "Invalid input. Please try again!"
  echo
  echo "Please enter the starting point:"
  read st
done

cd $path
let en=num+st

for (( i=$st; i<$en; i++ ))
do
  echo
	echo "Deleting VHD $name$i"
  echo
  str=$(echo $name$i)
  if [[ -d /mnt/$str ]]; then
    umount /mnt/$str
    rm -rf /mnt/$str
  else
    echo "VHD named $str doesn't exist!"
    echo
    continue
  fi
 
  if [[ -f $str.img ]]; then
     rm $str.img
  else
    echo "VHD named $str doesn't exist!"
    echo
    continue
  fi
done

echo
echo "Disk Stats:"
df
echo


