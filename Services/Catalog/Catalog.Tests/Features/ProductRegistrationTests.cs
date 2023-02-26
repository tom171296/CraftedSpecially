using System.Text;
using CraftedSpecially.Catalog.Application.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Moq;
using Newtonsoft.Json;

namespace CraftedSpecially.Catalog.Tests.Features;

[TestClass]
public class ProductRegistrationTests
{
    [TestMethod]
    public async Task RegisterProduct_withValidProductCommand_shouldSaveProductToTheDatabase()
    {
        // Arrange
        var mockRepository = new Mock<IProductRepository>();
        var command = new RegisterProductCommand("TestProductName", "TestProductDescription");

        var webApplicationFactory = new WebApplicationFactory<Program>().WithWebHostBuilder(
            builder =>
            {
                builder.ConfigureTestServices(services => {
                    services.AddTransient<IProductRepository>(provider => mockRepository.Object);
                });
            }
        );

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
        mockRepository.Verify(x => x.AddAsync(It.Is<Product>(product => product.Name.Equals(command.Name) && product.Description.Equals(command.Description))), Times.Once);
    }
}