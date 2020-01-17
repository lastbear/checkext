#!/bin/bash
FIX=
SEARCHPATH=$(pwd)
NOTITLE=false

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
	--notitle)
	NOTITLE=true
	shift # past argument
	;;
esac
done

##################################
echo "File extension checker v1.0"
echo "FIX(auto,append) : $FIX"
echo "SEARCHPATH       : $SEARCHPATH"
echo "NOTITLE          : $NOTITLE"

check_dir() {
	if [ $NOTITLE = false ]; then
		echo "$(find "$1" -maxdepth 1 -type f | wc -l) file(s) in directory: '$1'"
	fi
	for f in "$1"/*; do
		if [ -f "$f" ]; then
			type=$( file "$f" | grep -oP '\w+(?= image data)' )
			case $type in
				GIF)  newext=gif ;;
				PNG)  newext=png ;;
				JPEG) newext=jpg; newext2=jpeg ;;
				*)    echo "unknown extension: f=$f, t=$type"; continue ;;
			esac
			fn=${f##*/}
			ext=${f##*.}; # remove everything up to and including the last dot
			if [[ ${ext,,} != ${newext,,} && ${ext,,} != ${newext2,,} ]]; then # compare ignore case
				case $FIX in
					auto)
						echo mv "$fn" "${fn%.*}.$newext"
						mv "$f" "${f%.*}.$newext"
						;;
					append)
						echo mv "$fn" "${fn}.$newext"
						mv "$f" "${f}.$newext"
						;;
					*)	echo mv "$fn" "${fn%.*}.$newext"
						;;
				esac
			fi
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
