using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Events;
using FluentAssertions;
using Xunit;

namespace CraftedSpecially.Catalog.Domain.Tests.Aggregates.ProductAggregate;

public class ProductTests
{
    public class WhenRegistering
    {
        private RegisterProductCommand _command;
        private RegisterProductCommandResponse _response;

        public WhenRegistering()
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
}