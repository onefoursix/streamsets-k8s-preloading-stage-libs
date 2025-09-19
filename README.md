# streamsets-k8s-preloading-stage-libs
This project describes two approaches for preloading StreamSets stage libs when deploying StreamSets engines on k8s.  

These techniques can speed up the time it takes for a new StreamSets engine pod to come online if multiple stagelibs would otherwise need to be downloaded across a slow WAN.

The two approaches are: 

- Building your own Docker image that extends the StreamSets engine's image and includes the desired stage libraries (i.e. "baking-in" the  stage libs).

- VolumeMounting the stage libs from a shared volume at deployment time.

### Technique #1: Creating a custom StreamSets Engine image with stage libraries included.

To create your own StreamSets Engine image with stage libraries included, start by cloning  this project to a linux machine and changing to the [custom-streamsets-docker-image](custom-streamsets-docker-image) dir.

- Edit the [Dockerfile](custom-streamsets-docker-image/Dockerfile) and set the version of the StreamSets engin you wish to extend.  For example, I will use this setting:

	<code>FROM streamsets/datacollector:6.3.1</code>
	
- Edit the [build.sh](custom-streamsets-docker-image/build.sh) script and make the following changes:

  - Set the SDC_VERSION 

  - Set IMAGE_NAME to your custom image name

  - Set SDC_STAGE_LIBS to a space-delimited set of stage libraries to include.  
  
    Use only short stage library names, like <code>apache-kafka</code> as the script will
    prepend <code>streamsets-datacollector-</code> and append <code>-lib</code> to each entry.
    You do not need to include the <code>basic</code>, <code>dataformats</code>, or <code>dev</code> stage libraries as these will be included by default.
    
  - For the docker push command to work (the last line of the script), 
    login to your Docker Hub or other image registry before running the script. You can test the script without needing a Docker login by simply commenting out the last line of the script.
    
Tip: To see the full names of StreamSets stage libraries, create a scratch deployment in Control Hub, select the stage libraries you want, and then view the stage libs summary:

<img src="images/stage-libs.png" alt="stage-libs-list" width="800" style="margin-left: 60px;"/>
    
For example, I'll set these properties in my <code>build.sh</code> script:
```
# SDC Version
SDC_VERSION=6.3.1

# Your custom image name
IMAGE_NAME=onefoursix/sdc:6.3.1

# A space delimited list of stage libs to download
SDC_STAGE_LIBS="apache-kafka aws bigtable google-cloud groovy_4.0 jdbc jms jython_2_7 sdc-snowflake"
```

Make the script executable:

<code>$ chmod +x build.sh</code>

I'll run the script to build and push the image to my repo:

<code>$ ./build.sh</code>

Assuming the script completes without errors, I can then start a local Docker container using my new image:

<code>$ docker run -d onefoursix/sdc:6.3.1</code>

Make sure the container is running:

```
$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED          ...
9506747fb609   onefoursix/sdc:6.3.1   "/docker-entrypoint.…"   13 seconds ago   ...
```

Exec into the container and confirm the desired stage libs are present:

```
$ docker exec -it 9506747fb609 bash -c 'ls -l /opt/str*/streamsets-libs'
total 44
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-apache-kafka-lib
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-aws-lib
drwxrwxr-x 3 1000 root 4096 Jul 23 14:39 streamsets-datacollector-basic-lib
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-bigtable-lib
drwxrwxr-x 3 1000 root 4096 Jul 23 14:36 streamsets-datacollector-dataformats-lib
drwxrwxr-x 3 1000 root 4096 Jul 23 14:39 streamsets-datacollector-dev-lib
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-google-cloud-lib
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-jdbc-lib
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-jms-lib
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-jython_2_7-lib
drwxrwxr-x 3 sdc  sdc  4096 Sep 19 23:11 streamsets-datacollector-sdc-snowflake-lib
```







