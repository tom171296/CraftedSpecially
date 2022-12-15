using System.Text;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using Microsoft.AspNetCore.Mvc.Testing;
using Newtonsoft.Json;

namespace CraftedSpecially.Catalog.Tests.Features;

[TestClass]
public class ProductRegistrationTests
{
    [ClassInitialize(InheritanceBehavior.None)]
    public void SetupDatabase()
    {
        // Start my sql database container
    }

    [ClassCleanup]
    public void cleanupDatabase()
    {

    }

    [TestMethod]
    public async Task RegisterProduct_withValidProductCommand_shouldSaveProductToTheDatabase()
    {
        // Arrange
        var command = new RegisterProductCommand("", "");

        var webApplicationFactory = new WebApplicationFactory<>().WithWebHostBuilder(builder =>
        {

        });

        var client = webApplicationFactory.CreateClient();

        // Act
        var result = await client.PostAsync("/api/products", new StringContent(JsonConvert.SerializeObject(command), Encoding.UTF8, "application/json"));

        // Assert

    }
}