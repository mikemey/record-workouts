#!/usr/bin/env bash

if [[ ! ${WR_SERVER_STATIC_DIR} ]]; then
    echo "Environment variable '\$WR_SERVER_STATIC_DIR' not set!"
    exit
  fi

echo "cleaning static-asset directory $WR_SERVER_STATIC_DIR"
rm -rf $WR_SERVER_STATIC_DIR/*

declare OUTPUT=()
echo "copying static assets..."
OUTPUT+="$(cp -v -r static/img $WR_SERVER_STATIC_DIR)"
OUTPUT+="$(cp -v -r static/template $WR_SERVER_STATIC_DIR)"
OUTPUT+="$(cp -v -r static/vendor $WR_SERVER_STATIC_DIR)"

echo -e "\nadd line to apache2 configuration:"
printf "CacheFile"
while read -r COPY_OUTPUT; do
  COPY_TARGET="${COPY_OUTPUT##*-> }"
  [[ -f "$COPY_TARGET" ]] && printf " $COPY_TARGET"
done <<< "$OUTPUT"
