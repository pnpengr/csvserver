# solution

### Pulled the docker images below
docker pull infracloudio/csvserver:latest
docker pull prom/prometheus:v2.22.0

### PART 1:
#### 1: Run the container image infracloudio/csvserver:latest in background and check if it's running.
    docker run -d infracloudio/csvserver:latest
    
#### 2: If it's failing then try to find the reason, once you find the reason, move to the next step.   
    Container Exited with error
    docker ps -a
    docker logs f3ba905681f5
    ###2022/02/26 14:20:38 error while reading the file "/csvserver/inputdata": open /csvserver/inputdata: no such file or directory
    
#### 3: Write a bash script gencsv.sh to generate a file named inputFile whose content looks like:
    0, 234
    1, 98
    2, 34
    
#### Created Sample Shell called gencsv.sh and the out is stored in file inputFile
#### By default aug value is 10. if you want overwrite the default value, just pass the arg value while executing the gencsv.sh script.
#### Generated output will store in inputFile
    #!/usr/bin/env bash
    #rm /tmp/solution/inputFile
    
    for (( i = 0; i < ${1:-10}; i++ ));
    do 
      echo "$i, $RANDOM" >> inputFile
    done
    
    chmod +r inputFile
##### Mounted inputFile in container by using `-v /tmp/solution/inputFile:/csvserver/inputdata`

 #### 4: Run the container again in the background with file generated in (3) available inside the container (remember the reason you found in (2)).
         docker run -d -v /tmp/solution/inputFile:/csvserver/inputdata infracloudio/csvserver:latest
    
 #### 5: Get shell access to the container and find the port on which the application is listening. Once done, stop / delete the running container.
         docker run -d -v /tmp/csvserver/solution/inputFile:/csvserver/inputdata infracloudio/csvserver:latest
         docker ps / docker inspect <container id>-- To check the ports --and found 9300/tcp
         stopped running container and cleaned.
         docker rm -vf $(docker ps -aq)
         
         - exposed docker port on host machine port `9393`
         - exported environment variable `-e CSVSERVER_BORDER=Orange`
         
#### 6: Same as (4), run the container and make sure,
##### The application is accessible on the host at http://localhost:9393
##### Set the environment variable CSVSERVER_BORDER to have value Orange.
        docker run -d -p 9393:9300 -e CSVSERVER_BORDER=Orange -v /tmp/solution/inputFile:/csvserver/inputdata infracloudio/csvserver:latest
###  Executed above command successfully and able to access page on http://10.0.0.12:9393/. It is showing csv data and welcome note as exepected.
 
### PART II:
#### 1: Delete any containers running from the last part.
        docker rmi infracloudio/csvserver:latest
#### 2: Create a docker-compose.yaml file for the setup from part I.

        version: "3.9"
        services:
          #Part - 2
          csvserver:
            hostname: csvserver
            image: infracloudio/csvserver:latest
            ports:
              - "9393:9300"
            volumes:
              - ./inputFile:/csvserver/inputdata
            environment:
              - CSVSERVER_BORDER=Orange
       
#### 3:One should be able to run the application with docker-compose up.
        docker-compose up -d
        docker ps
### Executed above command successfully and able to access page on http://10.0.0.12:9393/. It is showing csv data and welcome note as exepected.

### PART III
#### 1: Delete any containers running from the last part.
        docker rmi infracloudio/csvserver:latest
        
#### 2: Add Prometheus container (prom/prometheus:v2.22.0) to the docker-compose.yaml form part II.

         version: "3.9"
         services:
           #Part - II
           csvserver:
             hostname: csvserver
             image: infracloudio/csvserver:latest
             ports:
               - "9393:9300"
             volumes:
               - ./inputFile:/csvserver/inputdata
             environment:
               - CSVSERVER_BORDER=Orange
         
           # Part - II
           prometheus:
             hostname: prometheus
             image: prom/prometheus:v2.22.0
             ports:
               - "9090:9090"
             volumes:
               - ./prometheus:/etc/prometheus/
             command:
                - '--web.enable-lifecycle'
                - '--config.file=/etc/prometheus/prometheus.yaml'  
                
#### 3: Configure Prometheus to collect data from our application at <application>:<port>/metrics endpoint. (Where the <port> is the port from I.5)
       ## Created prometheus/prometheus.yml
          global:
            scrape_interval: 30s
            scrape_timeout: 10s

          scrape_configs:
            - job_name: csvserver
            metrics_path: /metrics
            static_configs:
            - targets:
                - 'prometheus:9090'
                - 'csvserver:9300'
    
#### 4: Make sure that Prometheus is accessible at http://localhost:9090 on the host.      
        Type csvserver_records in the query box of Prometheus. Click on Execute and then switch to the Graph tab.
 
         http://10.0.0.12:9090/graph?g0.range_input=1h&g0.expr=csvserver_records&g0.tab=0 -- My local system able to view the Graph.
    
    
