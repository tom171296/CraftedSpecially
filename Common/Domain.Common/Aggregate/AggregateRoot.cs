namespace CraftedSpecially.Domain.Common;

public abstract class AggregateRoot : Entity, IAggregateRoot
{
    /// <summary>
    /// The list of domain events that are created when handling a command.
    /// </summary>
    protected readonly List<Event> _domainEvents;

    public AggregateRoot()
    {
        _domainEvents = new();
    }

    public IEnumerable<Event> GetDomainEvents()
    {
        return _domainEvents;
    }
   
    /// <summary>
    /// Let the aggregate handle an event and save it in the list of events
    /// so it can be used outside the aggregate (persisted, published on a bus, ...).
    /// </summary>
    /// <param name="domainEvent">The event to handle.</param>
    /// <remarks>Use GetEvents to retrieve the list of events.</remarks>
    protected void ApplyDomainEvent(Event domainEvent)
    {
        // let the derived aggregate handle the event
        HandleDomainEvent(domainEvent);

        // add the domain event
        AddDomainEvent(domainEvent);
    }

    /// <summary>
    /// Handle a domain event. This method must be implemented by deriving aggregate roots. 
    /// In this method, only internal state changes are allowed. This is because this method 
    /// is also called when replaying events when rehydrating the state of the aggregate from 
    /// the event store.
    /// </summary>
    /// <param name="domainEvent">The domain event to handle.</param>
    protected abstract void HandleDomainEvent(Event domainEvent);

        /// <summary>
    /// Add a domainevent as the result of handling a command for later processing.
    /// </summary>
    /// <param name="domainEvent">The domain event to add.</param>
    protected void AddDomainEvent(Event domainEvent)
    {
        _domainEvents.Add(domainEvent);
    }
}