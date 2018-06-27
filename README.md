# carbon-stretch-lea

Create and push image to docker hub:  
````
docker build --squash -t websoftag/carbon-stretch-lea:{VERSION} .
docker push websoftag/carbon-stretch-lea:{VERSION}
