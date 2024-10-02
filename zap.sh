#!/bin/bash

PORT=30180

# first run this
chmod 777 $(pwd)
echo $(id -u):$(id -g)
 #docker run -v /home/devsecops/formation-devsecops-tp:/zap/wrk/:rw -t ictu/zap2docker-weekly zap-api-scan.py -t http://mytpm.eastus.cloudapp.azure.com:30802/v3/api-docs -f openapi -r zap_report.html

 docker run --rm --memory=8gb -v /home/devsecops/formation-devsecops-tp:/zap/wrk/:rw -t ictu/zap2docker-weekly zap-full-scan.py -I -j -m 10 -T 60 \
  -t http://devsecopstp1.eastus.cloudapp.azure.com:31964/v3/api-docs \
  -r zap_report.html



# comment above cmd and uncomment below lines to run with CUSTOM RULES
##docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -c zap_rules -r zap_report.html

exit_code=$?


# HTML Report
 sudo mkdir -p owasp-zap-report
 sudo mv zap_report.html owasp-zap-report


echo "Exit Code : $exit_code"

 if [[ ${exit_code} -ne 0 ]];  then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    docker run -d --rm --name zap-report-server -p 8888:80 -v $(pwd)/owasp-zap-report:/usr/share/nginx/html nginx
    exit 1;
   else
    echo "OWASP ZAP did not report any Risk"
 fi;


# Generate ConfigFile
# docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t http://mytpm.eastus.cloudapp.azure.com:31933/v3/api-docs -f openapi -g gen_file