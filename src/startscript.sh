#!/bin/sh


contains()
  case "$1" in
    (*"$2"*) true;;
    (*) false;;
  esac

runTest() {

  echo "Running speedtest"

  speedtest_output=$(/usr/local/bin/speedtest --format=json --progress=no --accept-license --accept-gdpr)

  if contains "${speedtest_output}" "error"
  then
    error=$(echo "${speedtest_output}" | /usr/bin/jq --jsonargs .error)
    echo $error
    return 1
  fi

  Download_Rate=$(( $(echo "${speedtest_output}" | /usr/bin/jq --jsonargs .download.bandwidth) * 8 ))
  Upload_Rate=$(( $(echo "${speedtest_output}" | /usr/bin/jq --jsonargs .upload.bandwidth) * 8 ))
  Ping=$(echo "${speedtest_output}" | /usr/bin/jq --jsonargs .ping.latency)

  echo "Download: $Download_Rate bits/sec"
  echo "Upload: $Upload_Rate bits/sec"
  echo "Ping: $Ping ms"

  return 0
}

sent_data()
{
  echo $IFDB_MEASUREMENT,room=Internet,type=Upload value=$Upload_Rate > /tmp/temp.txt
  echo $IFDB_MEASUREMENT,room=Internet,type=Download value=$Download_Rate >> /tmp/temp.txt
  echo $IFDB_MEASUREMENT,room=Internet,type=Ping value=$Ping >> /tmp/temp.txt
  /usr/bin/curl -XPOST "https://$IFDB_SERVER/write?db=$IFDB_DBNAME" --insecure --data-binary @/tmp/temp.txt
}

runTest
if [ $? -eq 0 ];
then
  sent_data
fi
