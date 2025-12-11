# Dapr Redis Middleware example

In this quickstart, you will create a service that is invoked via Dapr service invocation and uses the Dapr State API to save that message into a key-value store. This examples uses the uppercase middleware component on the app HTTP pipeline to change the value of the message to uppercase before saving it to the state store. 

This quickstart includes one front end service.

- React front-end message generator

And one service that is invoked:

- C# service

## Prerequisites

### Prerequisites to run locally

- [Dapr CLI with Dapr initialized](https://docs.dapr.io/getting-started/install-dapr-cli/)
- [Node.js version 14 or greater](https://nodejs.org/en/) and [Asp.Net Core 6](https://dotnet.microsoft.com/download/dotnet/6.0)

## Run locally

In order to run this locally, each of the microservices need to run with Dapr. Start by running message subscribers.

### Clone this repository

0. Clone this repository to your local machine.

### Run C# service with Dapr

1. Open a new CLI window and navigate to C# service directory in your CLI:

```bash
cd csharp-service
```

2. Build Asp.Net Core app:

```bash
dotnet build
```

3. Run the C# service with Dapr passing it the Configuration file:
    
```bash
dapr run --app-id csharp-service --app-port 5009 --dapr-http-port 6002 --dapr-grpc-port 6092 --config ../deploy/components/local/config.yaml --log-level debug --resources-path ../deploy/components/local dotnet run
```

### Run the React front end with Dapr

Now, run the React front end with Dapr. The front end will publish different kinds of messages that subscribers will pick up.

1. Open a new CLI window and navigate to the react-form directory:

```bash
cd react-form
```

2. Run the React front end app with Dapr: 

```bash
npm run buildclient
```

```bash
npm install
```

```bash
dapr run --app-id csharp-service --app-port 5009 --dapr-http-port 6002 --dapr-grpc-port 6092 --config ../deploy/components/local/config.yaml --log-level debug --resources-path ../deploy/components/local dotnet run  
```

This may take a minute, as it downloads dependencies and creates an optimized production build. You'll know that it's done when you see `== APP == Listening on port 8080!` and several Dapr logs.

3. Open the browser and navigate to "http://localhost:8080/". You should see a form with a dropdown for message type and message text:

![Form Screenshot](./img/Form_Screenshot.JPG)

4. ***Only service invocation is enabled at this point***. Use Service invocation in the UI to see the csharp-service get invoked and then save that message into the state store. Notice that the [uppercase middleware](deploy/components/local/middleware.yaml) is loaded only into the `csharp-service` and the Configuration file specifies that this will be added into the `appHttpPipeline` meaning that it will only apply to outbound calls on the csharp service.


Configuration file:

```yaml
apiVersion: dapr.io/v1alpha1
kind: Configuration
metadata:
  name: pipeline
  namespace: default
spec:
  appHttpPipeline:
    handlers:
      - name: uppercase
        type: middleware.http.uppercase
```

Middleware component:

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: uppercase
spec:
  type: middleware.http.uppercase
  version: v1
```