docker  build -t 1majom/quicrq:server -f Dockerfile-server .
docker  build -t 1majom/quicrq:relay -f Dockerfile-relay .
docker  build -t 1majom/quicrq:relay-kube -f Dockerfile-relay-kube .
docker  build -t 1majom/quicrq:relay-kube-in -f Dockerfile-relay-kube-in .
docker  build -t 1majom/quicrq:relay-kube-out -f Dockerfile-relay-kube-out .
docker  build -t 1majom/quicrq:client -f Dockerfile-client .
docker  push 1majom/quicrq:server 
docker  push 1majom/quicrq:relay 
docker  push 1majom/quicrq:relay-kube 
docker  push 1majom/quicrq:relay-kube-in
docker  push 1majom/quicrq:relay-kube-out
docker  push 1majom/quicrq:client
