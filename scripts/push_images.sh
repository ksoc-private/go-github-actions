#!/bin/bash

echo "Retagging and pushing images to $1"


if [ -z "$SERVICE_NAME" ]; then
    echo "SERVICE_NAME must be defined"
    exit 2;
fi


uniqueRepoName=$(docker image list --format "{{.Repository}}:{{.Tag}}" | grep "ksoc-guard" | cut -d'/' -f1 | sort | uniq | head -n 2)
images=$(docker image list --format  "{{.Repository}}:{{.Tag}}" | grep "$SERVICE_NAME" | grep "$uniqueRepoName")

for line in $images; do
    registry_id=$(echo "$line" | cut -d '.' -f 1)
    repository_name_with_tag=$(echo "$line" | cut -d '/' -f 2-)
    repository_name=$(echo "$repository_name_with_tag" | cut -d ':' -f 1)
    repository=$(echo "$repository_name" | cut -d '/' -f 2)
    tag=$(echo "$repository_name_with_tag" | cut -d ':' -f 2)

    echo docker tag $line $1/$repository:$tag
    echo docker push $1/$repository:$tag

    matchingImages+=" $1/$repository:$tag"

done

manifestName=$(echo $matchingImages | cut -d ' ' -f 1 | sed 's/-[^-]*$//')

echo "docker manifest create $manifestName $matchingImages"
echo "docker manifest push $manifestName"
