using System.Text;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Newtonsoft.Json;

namespace CraftedSpecially.Catalog.Tests.Features;

[TestClass]
public class ProductRegistrationTests
{
    [TestMethod]
    public async Task RegisterProduct_withValidProductCommand_shouldSaveProductToTheDatabase()
    {
        // Arrange
        var command = new RegisterProductCommand("", "");

        var webApplicationFactory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
        });

        var client = webApplicationFactory.CreateClient();

        // Act
        var result = await client.PostAsync(
            "productmanagement/command/registerproduct",
            new StringContent(
                JsonConvert.SerializeObject(command),
                Encoding.UTF8,
                "application/json"
                )
            );

        // Assert
        // check if result is 200
        result.IsSuccessStatusCode.Should().BeTrue();

        // check if product is saved to the database
    }
}