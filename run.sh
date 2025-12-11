# Dapr running locally:
cd react-form/
npm install
dapr run --app-id react-form --app-port 8080 --dapr-http-port 6000 --dapr-grpc-port 6090 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/local npm run start

# Service invocation
cd csharp-service/
dotnet build
dapr run --app-id csharp-service --app-port 5009 --dapr-http-port 6002 --dapr-grpc-port 6092 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/local dotnet run

# show a message sending in the UI to SI

# K8s docker images
cd react-form/
npm run build
docker buildx build -t alicejgibbons/react-form:1.0 .
docker push alicejgibbons/react-form:1.0

cd csharp-service/
dotnet publish -c Release -o out
docker buildx build -t alicejgibbons/csharp-service:1.0 .
docker push alicejgibbons/csharp-service:1.0

cd python-subscriber
docker buildx build -t alicejgibbons/python-subscriber:1.0 .
docker push alicejgibbons/python-subscriber:1.0

# K8s deployment
# Create namespace
k create ns dapr-pubsub-state

# Helm Redis install
helm install redis bitnami/redis -n redis --create-namespace
export REDIS_PASSWORD=$(kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}" | base64 -d)
echo $REDIS_PASSWORD
kubectl create secret generic redis-password --from-literal=redis-password=$REDIS_PASSWORD -n dapr-pubsub-state

# Deploy Dapr
helm repo update
helm upgrade --install dapr dapr/dapr \
--version=1.15 \
--namespace dapr-system \
--create-namespace \
--wait
# Show control plane, CRDs, etc

# Deploy components
# Walk through components
k apply -f deploy/components/k8s

# Deploy apps
# Walk through annotations and pod specs
k apply -f deploy/
k port-forward svc/react-form 8080:80
k port-forward svc/redis-master 6379:6379


# Delete it all
helm uninstall
helm delete deploy --all
k delete ns dapr-pubsub-state dapr-system redis


# ## DDOSify for metrics in Conductor
# ddosify -t http://34.77.97.38:80/publish -m POST -b '{"messageType": "C", "message":"Ddos - Pub/sub to topic C"}' -T 10 -d 600 -n 10000 -h 'Content-Type: application/json'
# ddosify -t http://34.77.97.38:80/invoke -m POST -b '{"messageType": "B", "message":"Ddos - Invoke to topic B"}' -T 10 -d 600 -n 10000  -h 'Content-Type: application/json'