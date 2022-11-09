
using CraftedSpecially.catalog.application.CommandHandlers;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Events;
using FluentAssertions;
using Moq;

namespace CraftedSpecially.catalog.Application.tests.CommandHandlers;

public class RegisterProductCommandHandlerTests
{
    private readonly RegisterProductCommandHandler _sut;

    private readonly Mock<IProductRepository> _mockProductRepository;

    public RegisterProductCommandHandlerTests()
    {
        _mockProductRepository = new Mock<IProductRepository>(MockBehavior.Strict); // to force setup and not let a test pass accidentally.
        _mockProductRepository.Setup(mock => mock.CreateProductAsync(It.IsAny<Product>()))
            .Returns(Task.CompletedTask);

        _sut = new RegisterProductCommandHandler(_mockProductRepository.Object);
    }

    [Fact]
    public async Task ExecuteCommand_withValidCommand_shouldCallRepositoryAndPublisher()
    {
        // Arrange
        var command = new RegisterProductCommand("test", "test description");

        // Act
        RegisterProductCommandResponse result = await _sut.ExecuteAsync(command);

        // Assert
        result.Should().NotBeNull();
        result.Events.Should().NotBeEmpty();

        _mockProductRepository.Verify(mock => mock.CreateProductAsync(It.IsAny<Product>()), Times.Once);
    }
}