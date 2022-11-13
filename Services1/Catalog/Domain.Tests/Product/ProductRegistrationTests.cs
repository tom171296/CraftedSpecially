using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.DomainEvents;
using FluentAssertions;

namespace CraftedSpecially.Catalog.Domain.Tests.Aggregates.ProductAggregate;

[TestClass]
public class ProductTests
{
    [TestMethod]
    public async Task RegisterProduct_withCorrectValues_ShouldYieldValidContract()
    {
        // Arrage
        var _command = RegisterProductBuilder.Build("test product name");

        var sut = new Product();

        // Act
        await sut.RegisterProductAsync(_command);
        
        // Assert
        sut.Name.Should().Be(_command.Name);
        sut.Description.Should().Be(_command.Description);

        sut.GetDomainEvents().Should().ContainSingle(e => e is ProductRegisteredEvent)
            .Which.Should().BeEquivalentTo(_command, options => options
                    .ExcludingMissingMembers()
                    .Excluding(e => e.Type));
    }

    // [TestMethod]
    // public void Then_ProductShouldReflectCommand()
    // {
    //     _response.Product!.Name.Should().Be(_command.Name);
    //     _response.Product!.Description.Should().Be(_command.Description);
    // }

    // [TestMethod]
    // public void Then_AProductRegisteredEventIsRaised()
    // {
    //     _response.Events.Should().ContainSingle(e => e is ProductRegisteredEvent);
    // }
}