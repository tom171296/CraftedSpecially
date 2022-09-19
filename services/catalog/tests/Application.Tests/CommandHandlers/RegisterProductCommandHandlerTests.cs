
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using FluentAssertions;

namespace CraftedSpecially.Catalog.Application.Tests.CommandHandlers;

public class RegisterProductCommandHandlerTests
{
    public RegisterProductCommandHandlerTests()
    {
        _sut = new RegisterProductCommandHandler();
    }

    [Fact]
    public void ExecuteCommand_withValidCommand_shouldCallRepositoryAndPublisher()
    {
        // Arrange
        var command = new RegisterProductCommand("test", "test description");

        // Act
        RegisterProductCommandResponse result = _sut.ExecuteAsync(command);

        // Arrange
        // TODO: check if events are retrieved
        //       check if event is published

        result.Should().NotBeNull();
    }
}