#!/bin/bash

writeSocket()
{
  FILES=$(find /easyepg/xml -type f -name $XML_FILENAME_PATTERN -printf "%T@ %p\n" | sort -n | cut -d " " -f 2)

  while read -r FILE; do
    cat ${FILE} | socat - UNIX-CONNECT:/xmltv.sock

    echo "> ${FILE}"
  done <<< "${FILES}"
}

chown -R abc:users /easyepg
chown -R abc:users /tmp

cd /easyepg || exit

s6-setuidgid abc /bin/bash /easyepg/epg.sh

chown -R abc:users /easyepg
chown -R abc:users /tmp

if [[ -S /xmltv.sock ]]; then
  echo "Writing to xmltv.sock..."

  writeSocket
  sleep 300
  writeSocket
fi

exit 0
