#!/bin/bash

set -e 
# automated generate kubernetes images from gcr.io to registry.cn-hangzhou.cn/google-containers


IMAGES="flannel etcd kubedns exechealthz kubernetes-dashboard pause kube-addon-manager kube-dnsmasq"
arch=amd64

function main()
{
    for img in $IMAGES;
    do
        echo "======================================= image:[$img] ============================================"
        tags=$(curl -k -s -X GET https://gcr.io/v2/google_containers/$img-$arch/tags/list | jq -r '.tags[]'|sort -r)
        if [ $? -ne 0 ];then
            curl -k -s -X GET https://gcr.io/v2/google_containers/$img-$arch/tags/list | jq -r '.tags[]'|sort -r
            echo "error occurred while get tags."
            exit
        fi

        for tag in $tags
        do
            path=$img/$arch/$tag
            mkdir -p $path
            if [ -f $path/Dockerfile ] ;then
                echo "[ Image: $img, Tag: $tag ] already exist [$path/Dockerfile], skip!"
                continue
            fi
            echo "generate Dockerfile: $path/Dockerfile,  content:FROM gcr.io/google_containers/$img-$arch:$tag"
            echo "FROM gcr.io/google_containers/$img-$arch:$tag" > $path/Dockerfile
            #docker build -t registry.cn-hangzhou.aliyuncs.com/google-containers/$img-$arch:$tag -f $path/Dockerfile .
            #docker push registry.cn-hangzhou.aliyuncs.com/google-containers/$img-$arch:$tag
        done
        echo .
    done
}
main