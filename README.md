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
    - run getter client, and posting client
        - ./quicrq_app -p 4436 client 172.28.255.200 s 30900 get:videotest1:./me_tests/test1.bin
        - ./quicrq_app -p 4434 client 172.28.255.200 s 30900 post:videotest1:./tests/video1_source.bin
    - works, minikube might work with metallb also
- gke
    - creating autoplilot cluster, and applying all server and relay yamls and it works

