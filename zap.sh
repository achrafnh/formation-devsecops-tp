#!/bin/bash

PORT=30180

# Step 1: Prepare the environment
chmod 777 $(pwd)
echo $(id -u):$(id -g)

# Step 2: Run the OWASP ZAP scan
docker run --rm --memory=8gb -v /home/devsecops/formation-devsecops-tp:/zap/wrk/:rw -t ictu/zap2docker-weekly zap-full-scan.py -I -j -m 10 -T 60 \
  -t http://mytpm.eastus.cloudapp.azure.com:30802/v3/api-docs \
  -r zap_report.html

exit_code=$?

# Step 3: HTML Report - Create directory and move the report
sudo mkdir -p owasp-zap-report
sudo mv zap_report.html owasp-zap-report

# Step 4: Check if the scan reported any issues
echo "Exit Code : $exit_code"

if [[ ${exit_code} -ne 0 ]];  then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1;
else
    echo "OWASP ZAP did not report any Risk"
fi;

# Step 5: Start the Nginx container to serve the report
docker run -d --rm --name zap-report-server -p 8888:80 -v $(pwd)/owasp-zap-report:/usr/share/nginx/html nginx

# Output the URL for accessing the report
echo "The ZAP report is available at http://<your-server-ip>:8888/zap_report.html"

