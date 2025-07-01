using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.DomainEvents;
using CraftedSpecially.Catalog.Domain.Tests.Mocks;
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
        var productServiceMock = ProductServiceMock.ForNonExisting();
        var sut = new Product();

        // Act
        await sut.RegisterProductAsync(_command, productServiceMock.Object);

        // Assert
        sut.IsValid.Should().BeTrue();
        sut.Name.Should().Be(_command.Name);
        sut.Description.Should().Be(_command.Description);

        sut.GetDomainEvents().Should().ContainSingle(e => e is ProductRegisteredEvent)
            .Which.Should().BeEquivalentTo(_command, options => options
                    .ExcludingMissingMembers()
                    .Excluding(e => e.Type));
    }

    [TestMethod]
    public async Task RegisterProduct_alreadyExistingName_shouldYieldViolation()
    {
        // Arrange
        var _command = RegisterProductBuilder.Build("test product name");
        var productServiceMock = ProductServiceMock.ForExistingProduct();
        var sut = new Product();

        // Act
        await sut.RegisterProductAsync(_command, productServiceMock.Object);

        // Assert
        sut.IsValid.Should().BeFalse();
        sut.Name.Should().BeNullOrWhiteSpace();
        sut.Description.Should().BeNullOrWhiteSpace();

        sut.GetBusinessRuleViolations().Should().ContainSingle(v => v == $"Product with name \"test product name\" already exists");
    }
}
