using CraftedSpecially.catalog.api.forms;
using CraftedSpecially.catalog.api.controllers;
using Microsoft.AspNetCore.Mvc;

namespace CraftedSpecially.catalog.api.tests.controllers;
public class ProductControllerTests
{
    [Fact]
    public async Task Create_WithAValidProductForm_ExpectCommandHandlerToBeCalled()
    {
        // Given
        var productForm = new CreateProductForm();
        var sut = new ProductController();
    
        // When
        var result = await sut.CreateProduct(productForm);
    
        // Then
    }
}