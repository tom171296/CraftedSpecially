using CraftedSpecially.Application.Common.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.Domain.Common;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics.Metrics;

namespace CraftedSpecially.Catalog.Interface.WebApi.Controllers;

[ApiController]
[Route("productmanagement/command")]
public class CommandController : ControllerBase
{
    private static readonly Meter _meter = new("CraftedSpecially.Catalog");
    private static readonly Counter<int> _productRegistrationCounter = _meter.CreateCounter<int>("product_registration_total", "count", "Total number of product registration attempts");
    private static readonly Counter<int> _productRegistrationErrorCounter = _meter.CreateCounter<int>("product_registration_errors_total", "count", "Total number of product registration errors");
    private static readonly Histogram<double> _productRegistrationDuration = _meter.CreateHistogram<double>("product_registration_duration_seconds", "seconds", "Duration of product registration operations");
    [HttpPost("registerproduct")]
    public async Task<IActionResult> RegisterProduct(
        [FromBody] RegisterProductCommand command,
        [FromServices] ICommandHandler<RegisterProductCommand> commandHandler)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        
        try
        {
            _productRegistrationCounter.Add(1, new KeyValuePair<string, object?>("operation", "registerproduct"));
            
            var result = await HandleCommand(command, commandHandler);
            
            stopwatch.Stop();
            _productRegistrationDuration.Record(stopwatch.Elapsed.TotalSeconds, 
                new KeyValuePair<string, object?>("operation", "registerproduct"),
                new KeyValuePair<string, object?>("status", "success"));
                
            return result;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _productRegistrationErrorCounter.Add(1, 
                new KeyValuePair<string, object?>("operation", "registerproduct"),
                new KeyValuePair<string, object?>("error_type", ex.GetType().Name));
            
            _productRegistrationDuration.Record(stopwatch.Elapsed.TotalSeconds, 
                new KeyValuePair<string, object?>("operation", "registerproduct"),
                new KeyValuePair<string, object?>("status", "error"));
                
            throw;
        }
    }

    private async Task<IActionResult> HandleCommand<T>(
        Command command, ICommandHandler<T> commandHandler) where T : Command
    {
        await commandHandler.Handle((T)command);
        return Ok();
    }
}