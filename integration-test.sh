#!/bin/bash

#integration-test.sh

sleep 5s

#PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)
PORT=30302

echo $PORT
#echo $applicationURL:$PORT/$applicationURI

if [[ ! -z "$PORT" ]];
then

    response=$(curl -s newdevsecops1.eastus.cloudapp.azure.com:30302/increment/99)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" newdevsecops1.eastus.cloudapp.azure.com:30302/increment/99)

    if [[ "$response" == 100 ]];
        then
            echo "Increment Test Passed"
        else
            echo "Increment Test Failed"
            exit 1;
    fi;

    if [[ "$http_code" == 200 ]];
        then
            echo "HTTP Status Code Test Passed"
        else
            echo "HTTP Status code is not 200"
            exit 1;
    fi;

else
        echo "The Service does not have a NodePort"
        exit 1;
fi;

