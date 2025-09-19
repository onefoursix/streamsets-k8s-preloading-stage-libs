# streamsets-k8s-preloading-stage-libs
This project describes two approaches for preloading StreamSets stage libs when deploying StreamSets engines on k8s.  

These techniques can speed up the time it takes for a new StreamSets engine pod to come online if multiple stagelibs would otherwise need to be downloaded across a slow WAN.

The two approaches are: 

- Building your own Docker image that extends the StreamSets engine's image and includes the desired stage libraries (i.e. "baking-in" the  stage libs).

- VolumeMounting the stage libs from a shared volume at deployment time.

### Technique #1: Creating a custom StreamSets Engine image with stage libraries included.

To create your own StreamSets Engine image with stage libraries included, start by cloning  this project to a linux machine and changing to the [custom-streamsets-docker-image](custom-streamsets-docker-image) dir.



