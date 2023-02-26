using System.Text.Json.Serialization;

namespace CraftedSpecially.Domain.Common;

/// <summary>
/// Represents a command as defined in the CQRS pattern.
/// </summary>
public record Command
{
    /// <summary>
    /// The unique Id of the command. This Id is unique per command instance. This 
    /// is primarily used for logging.
    /// </summary>
    public Guid Id { get; } = Guid.NewGuid();
    
    /// <summary>
    /// The type of the command. This value is primarily used for logging and 
    /// knowing which .NET type to use for deserialization from JSON.
    /// </summary>
    [JsonIgnore]
    public string Type => GetType().Name;
}