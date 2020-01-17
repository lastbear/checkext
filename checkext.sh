#!/bin/bash
FIX=
SEARCHPATH=$(pwd)

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
	-f|--fix)
	FIX="$2"
	shift # past argument
	shift # past value
	;;
	-s|--searchpath)
	SEARCHPATH="$2"
	shift # past argument
	shift # past value
	;;
	--default)
	DEFAULT=YES
	shift # past argument
	;;
	*)    # unknown option
	POSITIONAL+=("$1") # save it in an array for later
	shift # past argument
	;;
esac
done

##################################
echo "File extension checker v1.0"
echo "FIX(auto,append) : $FIX"
echo "SEARCHPATH       : $SEARCHPATH"

check_dir() {
	echo "$(find "$1" -maxdepth 1 -type f | wc -l) file(s) in directory: '$1'"
	for f in "$1"/*; do
		[ -d "$f" ] && continue
		type=$( file "$f" | grep -oP '\w+(?= image data)' )
		case $type in
			PNG)  newext=png ;;
			JPEG) newext=jpg ;;
			*)    echo 'unknown extension: $f'; continue ;;
		esac
		fn=${f##*/}
		ext=${f##*.}; # remove everything up to and including the last dot
		if [[ $ext != $newext ]]; then
			case $FIX in
				auto)
					echo mv "$fn" "${fn%.*}.$newext"
					mv "$f" "${f%.*}.$newext" ;;
				append)
					echo mv "$fn" "${fn}.$newext"
					mv "$f" "${f}.$newext" ;;
				*)	echo mv "$fn" "${fn%.*}.$newext" ;;
			esac
		fi
	done
}

recurse() {
	for i in "$1"/*; do
		if [ -d "$i" ]; then
			recurse "$i"
		fi
	done
	check_dir "$1"
}

recurse "$SEARCHPATH"
