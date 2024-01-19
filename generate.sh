#!/bin/bash

SOURCE=/home/sam/Downloads/meemee/meemee
TARGET=_posts
IMAGES=assets/images
TMP=/tmp

generatePost() {
	category="${1}"
	file="$2"
	echo "Processing ${file} in ${category}"

	if [ -f "${TARGET}/${category}/2024-01-01-${file}.md" ]; then
		echo "Skipping, already exists"
	else
		cat > "${TARGET}/${category}/2024-01-01-${file}.md" <<-EOF
		---
		layout: post
		title: "${file}"
		categories: "${category}"
		---
		EOF

		mkdir -p "${IMAGES}/${category}/"

		# process the image(s)
		find "${SOURCE}/${category}/" -name "${file}*" -type f -printf "%f\n" | sort | while read img
		do
			img_no_jpg="${img%.jpg}"
			cp "${SOURCE}/${category}/${img}" "${TMP}/"
			convert "${TMP}/${img}" -resize "1200x1200>" -strip "${TMP}/${img}"
			cwebp "${TMP}/${img}" -o "${IMAGES}/${category}/${img_no_jpg}.webp"
			rm "${TMP}/${img}"

			lqip=$(lqip-gen "${IMAGES}/${category}/${img_no_jpg}.webp")

			cat >> "${TARGET}/${category}/2024-01-01-${file}.md" <<-EOF
			![${img}](/assets/images/${category}/${img_no_jpg}.webp){: width="400" height="400" lqip="${lqip}"}

			EOF
		done
	fi
}


find $SOURCE/ -mindepth 1 -type d -printf "%f\n" | while read category
do
	echo "Creating directory ${category}"
	mkdir ${TARGET}/${category}

	find $SOURCE/${category} -mindepth 1 -type f -printf "%f\n" | while read file
	do
		file_no_jpg="${file%.jpg}"
		file_no_number="${file_no_jpg%.*}"
		generatePost "${category}" "${file_no_number}"
	done
done


