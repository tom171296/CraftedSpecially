
using CraftedSpecially.catalog.application.CommandHandlers;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;
using FluentAssertions;

namespace CraftedSpecially.catalog.Application.tests.CommandHandlers;

public class RegisterProductCommandHandlerTests
{
    private readonly RegisterProductCommandHandler _sut;

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