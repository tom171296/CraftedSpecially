namespace CraftedSpecially.Application.Common.Interfaces;

using CraftedSpecially.Domain.Common;
using System.Threading.Tasks;

public interface ICommandHandler<in T> where T : Command
{
    ValueTask Handle(T command);
}
