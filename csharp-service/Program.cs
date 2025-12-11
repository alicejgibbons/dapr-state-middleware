using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Dapr.Client;
using Dapr.Client.Autogen.Grpc.v1;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var baseURL = (Environment.GetEnvironmentVariable("BASE_URL") ?? "http://localhost") + ":" 
+ (Environment.GetEnvironmentVariable("DAPR_HTTP_PORT") ?? "3500");
const string DAPR_STATE_STORE = "statestore";

var daprClient = new DaprClientBuilder().Build();

// Route /A
app.MapPost("/A", async (ILogger<Program> logger, MessageEvent item) => {
    Console.WriteLine($"Received message on Route A: {item.Message}");

    // Saving message in state store
    var messageJson = JsonSerializer.Serialize(
        new[] {
            new {
                key = "A",
                value = item.Message
            }
        }
    );
    var state = new StringContent(messageJson, Encoding.UTF8, "application/json");
    await daprClient.SaveStateAsync(DAPR_STATE_STORE, "A", item.Message);
    Console.WriteLine("Saved item in state store: " + item.Message);
    return Results.Ok();
});

// Route /B
app.MapPost("/B", async (ILogger<Program> logger, MessageEvent item) => {
    Console.WriteLine($"Received message on Route B: {item.Message}");

    // Saving message in state store
    var messageJson = JsonSerializer.Serialize(
        new[] {
            new {
                key = "B",
                value = item.Message
            }
        }
    );
    var state = new StringContent(messageJson, Encoding.UTF8, "application/json");
    await daprClient.SaveStateAsync(DAPR_STATE_STORE, "B", item.Message);
    Console.WriteLine("Saved item in state store: " + item.Message);
    return Results.Ok();
});

// Route /C
app.MapPost("/C", async (ILogger<Program> logger, MessageEvent item) => {
    Console.WriteLine($"Received message on Route C: {item.Message}");

    // Saving message in state store
    var messageJson = JsonSerializer.Serialize(
        new[] {
            new {
                key = "C",
                value = item.Message
            }
        }
    );
    var state = new StringContent(messageJson, Encoding.UTF8, "application/json");
    await daprClient.SaveStateAsync(DAPR_STATE_STORE, "C", item.Message);
    Console.WriteLine("Saved item in state store: " + item.Message);
    return Results.Ok();
});


app.Run();

internal class MessageEvent{
    public string? MessageType  {get; set; }
    public string? Message {get; set; }
}