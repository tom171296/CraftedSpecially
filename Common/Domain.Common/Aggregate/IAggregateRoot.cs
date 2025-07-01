namespace CraftedSpecially.Domain.Common;

public interface IAggregateRoot : IEntity
{
    IEnumerable<Event> GetDomainEvents();
}
