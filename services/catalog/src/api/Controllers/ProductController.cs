using CraftedSpecially.catalog.api.forms;
using CraftedSpecially.catalog.application.CommandHandlers;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;
using Microsoft.AspNetCore.Mvc;

namespace CraftedSpecially.catalog.api.controllers;

public class ProductController : ControllerBase
{
    private IRegisterProductCommandHandler _registerProductCommandHandler;

    public ProductController(IRegisterProductCommandHandler registerProductCommandHandler)
    {
        _registerProductCommandHandler = registerProductCommandHandler;
    }

    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(CreateProductForm productForm)
    {
        var command = new RegisterProductCommand(productForm.Name, productForm.Description);
        var response = await _registerProductCommandHandler.ExecuteAsync(command);

        return null;
    }
}