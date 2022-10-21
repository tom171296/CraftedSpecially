using CraftedSpecially.catalog.api.forms;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using Microsoft.AspNetCore.Mvc;

namespace CraftedSpecially.catalog.api.controllers;

public class ProductController : ControllerBase
{

    
    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(CreateProductForm productForm)
    {
        throw new NotImplementedException();
    }
}