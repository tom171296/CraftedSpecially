using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Events;
using FluentAssertions;
using Xunit;

namespace CraftedSpecially.catalog.domain.tests.Aggregates.ProductAggregate;

public class ProductTests
{
    private readonly RegisterProductCommand _command;
    private readonly RegisterProductCommandResponse _response;

    public ProductTests()
    {
        _command = new RegisterProductCommand(
            "White dog, galaxy",
            "A colourful can with a colourful beer"
        );

        _response = Product.RegisterProduct(_command);
    }

    [Fact]
    public void Then_TheProductIsReturned()
    {
        _response.Product.Should().NotBeNull();
    }

    [Fact]
    public void Then_ProductShouldReflectCommand()
    {
        _response.Product!.Name.Should().Be(_command.Name);
        _response.Product!.Description.Should().Be(_command.Description);
    }

    [Fact]
    public void Then_AProductRegisteredEventIsRaised()
    {
        _response.Events.Should().ContainSingle(e => e is ProductRegisteredEvent);
    }
}