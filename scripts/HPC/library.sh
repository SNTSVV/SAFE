# find string in the text (reverse direction)
# parameters: $1 - string te be searched
#             $2 - string to find
rindex(){
  text=$1
  len=${#text}
  ret=-1
  for((i=$len-1;i>=0;i--)); do
    if [[ "${text:$i:1}" == "$2" ]]; then
      ret=$i;
      break;
    fi
  done
  echo $ret
}