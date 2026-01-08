using System.Diagnostics;

namespace Catalog.Api.Services.Brews;

public sealed class BrewOrderService(BrewOrderInstrumentation instrumentation) : IBrewOrderService
{
    private readonly BrewOrderInstrumentation _instr = instrumentation;

    public async Task<BrewOrderResult> PlaceOrderAsync()
    {
        var activity = Activity.Current ?? _instr.ActivitySource.StartActivity("Checkout", ActivityKind.Server);
        try
        {
            activity?.SetTag("checkout.cart.value", 120.50);
            activity?.SetTag("order.channel", "web");

            await SimulatePaymentCall();
            await SimulateInventoryReservation();

            _instr.CheckoutSuccessCounter.Add(1, new KeyValuePair<string, object?>("result", "success"));
            activity?.SetStatus(ActivityStatusCode.Ok);

            return new BrewOrderResult("Order placed");
        }
        catch (Exception ex)
        {
            _instr.CheckoutFailureCounter.Add(1, new KeyValuePair<string, object?>("result", "failure"));
            activity?.AddException(ex);
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            return new BrewOrderResult("Checkout failed");
        }
    }

    private async Task SimulatePaymentCall()
    {
        using var span = _instr.ActivitySource.StartActivity("PaymentService.ChargeCard", ActivityKind.Client);
        span?.SetTag("payment.provider", "stripe");
        await Task.Delay(Random.Shared.Next(20, 150));
        if (Random.Shared.Next(0, 10) == 1)
            throw new Exception("Payment failed");
    }

    private async Task SimulateInventoryReservation()
    {
        using var span = _instr.ActivitySource.StartActivity("InventoryService.ReserveStock", ActivityKind.Client);
        span?.SetTag("inventory.warehouse", "central");
        await Task.Delay(Random.Shared.Next(10, 80));
        if (Random.Shared.Next(0, 15) == 1)
            throw new Exception("Inventory reservation failed");
    }
}
