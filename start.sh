docker  build -t 1majom/quicrq:server -f Dockerfile-server .
docker  build -t 1majom/quicrq:relay -f Dockerfile-relay .
docker  build -t 1majom/quicrq:relay-kube -f Dockerfile-relay-kube .
# docker  build -t 1majom/quicrq:trans -f Dockerfile-c-trans .
docker  build -t 1majom/quicrq:rec -f Dockerfile-c-rec .
docker  push 1majom/quicrq:server 
docker  push 1majom/quicrq:relay
docker  push 1majom/quicrq:relay-kube
# docker  push 1majom/quicrq:trans
docker  push 1majom/quicrq:rec
