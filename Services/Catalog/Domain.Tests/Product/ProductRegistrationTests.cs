using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.DomainEvents;
using CraftedSpecially.Catalog.Domain.Tests.Mocks;

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
        Assert.IsTrue(sut.IsValid);
        Assert.AreEqual(_command.Name, sut.Name);
        Assert.AreEqual(_command.Description, sut.Description);

        var events = sut.GetDomainEvents().ToList();
        Assert.AreEqual(1, events.Count(e => e is ProductRegisteredEvent));
        var registeredEvent = events.OfType<ProductRegisteredEvent>().SingleOrDefault();
        Assert.IsNotNull(registeredEvent);
        // Compare properties except for excluded ones
        Assert.AreEqual(_command.Name, registeredEvent.Name);
        Assert.AreEqual(_command.Description, registeredEvent.Description);
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
        Assert.IsFalse(sut.IsValid);
        Assert.IsTrue(string.IsNullOrWhiteSpace(sut.Name));
        Assert.IsTrue(string.IsNullOrWhiteSpace(sut.Description));

        var violations = sut.GetBusinessRuleViolations().ToList();
        Assert.AreEqual(1, violations.Count(v => v == $"Product with name \"test product name\" already exists"));
    }
}