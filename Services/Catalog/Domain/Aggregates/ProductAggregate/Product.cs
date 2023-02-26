using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.DomainEvents;
using CraftedSpecially.Domain.Common;

namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

/// <summary>
///     Product class that is the aggregate root of the catalog service.
///     Responsible for all the business rules regarding the addition of a new product.
/// </summary>
public class Product : AggregateRoot
{
    public string Name { get; private set;} = "";
    public string Description { get; private set;} = "";
    public override string Id => throw new NotImplementedException();

    /// <summary>
    /// Register a new Product.
    /// </summary>
    public async Task RegisterProductAsync(RegisterProductCommand command, IProductService _productService)
    {   
        await EnsureProductIsUniqueAsync(command.Name, _productService);

        if(IsValid)
        {
             // Handle command
            var productRegisteredEvent = ProductRegisteredEvent.FromCommand(command);
            ApplyDomainEvent(productRegisteredEvent);
        }
    }

    //===================================================================================
    // This region contains the methods that handle domain-events. Handling domain-events 
    // only changes the state of the aggregate (properties). Within these methods, it is 
    // never allowed to introduce side-effects or call any external services. This is
    // because this method is also called when replaying events when rehydrating the 
    // state of the aggregate from the event-store.
    //===================================================================================

    protected override void HandleDomainEvent(Event domainEvent)
    {
        switch(domainEvent)
        {
            case ProductRegisteredEvent productRegisteredEvent:
                Handle(productRegisteredEvent);
                break;
        }
    }

    private void Handle(ProductRegisteredEvent productRegisteredEvent)
    {
        Name = productRegisteredEvent.Name;
        Description = productRegisteredEvent.Description;
    }

    //===================================================================================
    // This region contains the methods that check business-rules. This can be rules that 
    // apply to the state (properties) of the aggregate or to specific values passed in 
    // as part of a command.
    //===================================================================================

    private async Task EnsureProductIsUniqueAsync(string name, IProductService productService)
    {
        if(await productService.IsExistingProductAsync(name))
        {
            AddBusinessRuleViolation($"Product with name \"{name}\" already exists");
        }
    }

}