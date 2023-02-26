namespace CraftedSpecially.Domain.Common;

public abstract class Entity : IEntity
{
    public abstract string Id { get; }

    public bool Equals(IEntity? other)
    {
        throw new NotImplementedException();
    }
}
