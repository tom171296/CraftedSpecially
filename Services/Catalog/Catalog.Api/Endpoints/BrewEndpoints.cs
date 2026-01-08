using System.Diagnostics;
using System.Diagnostics.Metrics;

namespace Catalog.Api.Endpoints;

/// <summary>
/// Minimal API endpoint mappings for brews.
/// Provides a shell GET endpoint that returns an empty list until implemented.
/// </summary>
public static class BrewsEndpoints
{
    static readonly ActivitySource ActivitySource = new("CheckoutService");
    static readonly Meter Meter = new("CheckoutMetrics");

    static readonly Counter<int> CheckoutSuccessCounter = Meter.CreateCounter<int>("checkout.success.count");
    static readonly Counter<int> CheckoutFailureCounter = Meter.CreateCounter<int>("checkout.failure.count");

    public static async Task<IResult> HandleBrewOrderAsync()
    {
        // Capture the current request Activity (created by ASP.NET Core instrumentation) without disposing it.
        // If none exists (e.g., invoked outside normal pipeline), start a new root span.
        var activity = Activity.Current ?? ActivitySource.StartActivity("Checkout", ActivityKind.Server);
        try
        {
            // Add semantic attributes
            activity?.SetTag("checkout.cart.value", 120.50);
            activity?.SetTag("order.channel", "web");

            // Simulate call to payment system
            await SimulatePaymentCall();

            // Simulate call to inventory system
            await SimulateInventoryReservation();
            
            CheckoutSuccessCounter.Add(1,
                new KeyValuePair<string, object?>("result", "success"));

            activity?.SetStatus(ActivityStatusCode.Ok);

            return Results.Ok(new { status = "Order placed" });
        }
        catch (Exception ex)
        {
            CheckoutFailureCounter.Add(1,
                new KeyValuePair<string, object?>("result", "failure"));

            activity?.AddException(ex);
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            return Results.Problem("Checkout failed");
        }
    }


    private static async Task SimulatePaymentCall()
    {
        // Parent is implicitly Activity.Current; no need to pass context manually.
        using var span = ActivitySource.StartActivity("PaymentService.ChargeCard", ActivityKind.Server);
        span?.SetTag("payment.provider", "stripe");
        await Task.Delay(Random.Shared.Next(20, 150)); // simulate latency

        if (Random.Shared.Next(0, 10) == 1) // 10% failure
            throw new Exception("Payment failed");
    }

    private static async Task SimulateInventoryReservation()
    {
        using var span = ActivitySource.StartActivity("InventoryService.ReserveStock", ActivityKind.Server);
        await Task.Delay(Random.Shared.Next(10, 80));

        if (Random.Shared.Next(0, 15) == 1) // 6.7% failure
            throw new Exception("Inventory reservation failed");
    }
}
