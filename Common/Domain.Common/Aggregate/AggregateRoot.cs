namespace CraftedSpecially.Domain.Common;

public abstract class AggregateRoot : Entity, IAggregateRoot
{
    private readonly List<string> _businessRuleViolations;

    /// <summary>
    /// Indication whether the aggregate is in a valid state (true) or not (false).
    /// </summary>
    public bool IsValid => !_businessRuleViolations.Any();

    /// <summary>
    /// The list of domain events that are created when handling a command.
    /// </summary>
    protected readonly List<Event> _domainEvents;

    public AggregateRoot()
    {
        _domainEvents = new();
        _businessRuleViolations = new();
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

    /// <summary>
    /// Add a business-rule violation. This violation must be a clear description of the 
    /// business-rule that was violated.
    /// </summary>
    /// <param name="violation">The business-rule violation message to add.</param>
    public void AddBusinessRuleViolation(string violation)
    {
        _businessRuleViolations.Add(violation);
    }

    /// <summary>
    /// Get the list of business-rule violations.
    /// </summary>
    public IEnumerable<string> GetBusinessRuleViolations()
    {
        return _businessRuleViolations;
    }
}