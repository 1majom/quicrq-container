# containerialized quicrq

- local, minikube
    - minikube start
    - apply both server and relay yamls
    - run minikube tunnel in a different terminal
        - get ip address e.g. 192.168.49.2
    - run getter client, and posting client
        - ./quicrq_app -p 4436 client 192.168.49.2 s 30900 get:videotest1:./me_tests/test1.bin
        - ./quicrq_app -p 4434 client 192.168.49.2 s 30900 post:videotest1:./tests/video1_source.bin
    - nothing
    - might be related to this issue, but i think i have overlooked something
        - https://github.com/kubernetes/minikube/issues/12362
- local, kind
    - kind create cluster
    - following lb related docu page https://kind.sigs.k8s.io/docs/user/loadbalancer/
        - apply modified metallb-config.yaml
    - apply both server and relay yamls
    - get ip with k get svc
    - run getter client, and posting client e.g.
        - ./quicrq_app -p 4436 client 172.28.255.200 s 30900 get:videotest1:./me_tests/test1.bin
        - ./quicrq_app -p 4434 client 172.28.255.200 s 30900 post:videotest1:./tests/video1_source.bin
    - works, minikube might work with metallb also
- gke
    - creating autoplilot cluster, and applying all server and relay yamls and it works while using stream
- gke using datagram transmission
    - some problems came up, the transmission sometime occurs, sometimes stops at around 50KB of transmitted file
    - the problem is not because of the ports used by the clients, it works in kind
    - the problem is not because of the relay would be available in more than 1 replicas, it works in kind


- gke delay measure description
    - all situations have different yamls separated into directories
        - 1, 7,8, 9 are similar, also 2 and 3
        - IPs should be set from a different file, not hardcoded
    - the measurements happend with these steps
        - select a scenario
        - apply yamls
        - send tests/video_source.bin sending from post to get client three times
        - everytime change the stream identifier (post:videotest1, post:videotest2...)
        - before moving to another scenario delete everything created with the yamls
    - if the sending gets stuck
        - i did not look into the main reason of the problem sometimes it is resolved by retrying, sometimes i waited and restarted the pods.
        - the problem might be related to gke and the handling of udp packets, because from the command histroy it can be seen that the problem dissapeared when using the same command with the same deployments...
    - probable reason why the tests got stuck:
        - at work and at the dorm i was connected to the wifi. once i tried wired connection at the dorm the tests worked without a problem...
    - sciprt.sh
        - this script runs all the test once a gke cluster is configured on the system
        - before running the script you should build and push the container images, and provide the variables in a secret_variables.sh file mainly oldIP1/2, and two directories. one where the quicrq_app executable is located and one with this repos yamls
        - todo: i could not get kubectl's wait functionality to wait for the LB and deploy creations before running the tests. Now this is solved by a simple sleep which can be skipped with pressing x
        - todo: making variables for the yamls because now the ip change is done by 2 sed commands


