#!/bin/bash

set -e 
# automated generate kubernetes images from gcr.io to registry.cn-hangzhou.cn/google-containers


IMAGES="flannel etcd k8s-dns-kube-dns k8s-dns-dnsmasq-nanny k8s-dns-sidecar kubedns exechealthz kubernetes-dashboard pause kube-addon-manager kube-dnsmasq"
arch=amd64

function sync_images_with_arch ()
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
            #docker build -t registry.cn-hangzhou.aliyuncs.com/google_containers/$img-$arch:$tag -f $path/Dockerfile .
            #docker push registry.cn-hangzhou.aliyuncs.com/google_containers/$img-$arch:$tag
        done
        echo .
    done
}


IMAGES2="kube-cross echoserver heapster heapster_influxdb heapster_grafana defaultbackend nginx-ingress-controller addon-resizer etcd-amd64 cluster-autoscaler kube-state-metrics kube-registry-proxy mongodb-install spark zeppelin spartakus-amd64 busybox"

function sync_images ()
{
    for img in $IMAGES2;
    do
        echo "======================================= image:[$img] ============================================"
        tags=$(curl -k -s -X GET https://gcr.io/v2/google_containers/$img/tags/list | jq -r '.tags[]'|sort -r)
        if [ $? -ne 0 ];then
            curl -k -s -X GET https://gcr.io/v2/google_containers/$img/tags/list | jq -r '.tags[]'|sort -r
            echo "error occurred while get tags."
            exit
        fi

        for tag in $tags
        do
            path=$img/$tag
            mkdir -p $path
            if [ -f $path/Dockerfile ] ;then
                echo "[ Image: $img, Tag: $tag ] already exist [$path/Dockerfile], skip!"
                continue
            fi
            echo "generate Dockerfile: $path/Dockerfile,  content:FROM gcr.io/google_containers/$img:$tag"
            echo "FROM gcr.io/google_containers/$img:$tag" > $path/Dockerfile
            #docker build -t registry.cn-hangzhou.aliyuncs.com/google_containers/$img:$tag -f $path/Dockerfile .
            #docker push registry.cn-hangzhou.aliyuncs.com/google_containers/$img:$tag
        done
        echo .
    done
}
sync_images_with_arch
sync_images

