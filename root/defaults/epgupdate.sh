#!/bin/bash

writeSocket()
{
  SOCKET=$1
  if [[ -S $SOCKET ]]; then
    echo "Processing socket ${SOCKET}..."
    FILES=$(find /easyepg/xml -type f -name $XML_FILENAME_PATTERN -printf "%T@ %p\n" | sort -n | cut -d " " -f 2)

    while read -r FILE; do
      echo "Writing to ${SOCKET}..."
      cat ${FILE} | socat - UNIX-CONNECT:$SOCKET
      echo "> ${FILE}"
    done <<< "${FILES}"
  fi
}

writeSockets()
{
  echo "Find sockets..."
  SOCKETS=$(find /sockets -type s)

  while read -r SOCKET; do
    echo "> ${SOCKET}"
    writeSocket $SOCKET
    sleep 300
    writeSocket $SOCKET
  done <<< "${SOCKETS}"
}

chown -R abc:users /easyepg
chown -R abc:users /tmp

cd /easyepg || exit

s6-setuidgid abc /bin/bash /easyepg/epg.sh

chown -R abc:users /easyepg
chown -R abc:users /tmp

writeSockets

exit 0
