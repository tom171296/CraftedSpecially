using System.Diagnostics;
using System.Diagnostics.Metrics;

namespace Catalog.Api.Services.Brews;

/// <summary>
/// Provides instrumentation primitives (ActivitySource, Meter, Counters) for brew checkout operations.
/// Registered as a singleton so only one Meter and ActivitySource instance exist per process.
/// </summary>
public sealed class BrewOrderInstrumentation
{
    public ActivitySource ActivitySource { get; }
    public Meter Meter { get; }
    public Counter<int> CheckoutSuccessCounter { get; }
    public Counter<int> CheckoutFailureCounter { get; }

    public BrewOrderInstrumentation()
    {
        ActivitySource = new ActivitySource("Catalog.Api.Checkout");
        Meter = new Meter("Catalog.Api.CheckoutMetrics");
        CheckoutSuccessCounter = Meter.CreateCounter<int>("checkout.success.count");
        CheckoutFailureCounter = Meter.CreateCounter<int>("checkout.failure.count");
    }
}
