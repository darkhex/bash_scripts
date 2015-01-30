#!/bin/bash

email=email@mail.ru

for url in `awk '{print $1}' url.txt`
do
response=$(curl --write-out %{http_code} --silent --output /dev/null ${url})

if [ $response -eq 200 ]
then
    echo "Site up"
else
    echo "help $url" | /bin/mail -s "$url is down" $email
fi
done