using CraftedSpecially.catalog.api.forms;
using CraftedSpecially.catalog.api.controllers;
using CraftedSpecially.catalog.application.CommandHandlers;
using Moq;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;
using FluentAssertions;
using CraftedSpecially.catalog.api.tests.testdatabuilders;

namespace CraftedSpecially.catalog.api.tests.controllers;
public class ProductControllerTests
{
    [Fact]
    public async Task Create_WithAValidProductForm_ExpectCommandHandlerToBeCalled()
    {
        // Given
        var productForm = new ProductFormBuilder()
            .Build();

        var registerProductCommandResponseBuilder = new RegisterProductCommandResponseBuilder()
            .Build();

        var mockProductHandler = new Mock<IRegisterProductCommandHandler>();
        mockProductHandler.Setup(m => m.ExecuteAsync(It.IsAny<RegisterProductCommand>()))
            .ReturnsAsync(registerProductCommandResponseBuilder);


        var sut = new ProductController(mockProductHandler.Object);
    
        // When
        var creationResult = await sut.CreateProduct(productForm);
    
        // Then
        mockProductHandler.Verify(m => m.ExecuteAsync(It.IsAny<RegisterProductCommand>()), Times.Once);
        creationResult.Value.Name.Should().Be(productForm.Name);
        creationResult.Value.Description.Should().Be(productForm.Description);
    }
}