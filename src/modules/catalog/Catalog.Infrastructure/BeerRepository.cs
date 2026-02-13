using Catalog.Application.GetAllBeers;
using Catalog.Domain;

namespace Catalog.Infrastructure;

public class BeerRepository : IBeerRepository
{
    private static readonly List<Beer> Beers =
    [
        new Beer
        {
            Id = Guid.Parse("a1b2c3d4-0001-0000-0000-000000000001"),
            Name = "Hazy Days IPA",
            Style = "New England IPA",
            Abv = 6.5m,
            Description = "A juicy, hazy IPA bursting with tropical fruit flavors and a soft, pillowy mouthfeel.",
            Brewery = "Cloudwater Brew Co",
            Price = 5.50m
        },
        new Beer
        {
            Id = Guid.Parse("a1b2c3d4-0002-0000-0000-000000000002"),
            Name = "Dark Matter Stout",
            Style = "Imperial Stout",
            Abv = 9.2m,
            Description = "Rich and velvety imperial stout with notes of dark chocolate, espresso, and vanilla.",
            Brewery = "Northern Monk",
            Price = 7.00m
        },
        new Beer
        {
            Id = Guid.Parse("a1b2c3d4-0003-0000-0000-000000000003"),
            Name = "Pilsner Perfection",
            Style = "Czech Pilsner",
            Abv = 4.8m,
            Description = "A crisp, clean pilsner with a delicate hop bitterness and a refreshing finish.",
            Brewery = "Beavertown Brewery",
            Price = 4.00m
        },
        new Beer
        {
            Id = Guid.Parse("a1b2c3d4-0004-0000-0000-000000000004"),
            Name = "Sour Power",
            Style = "Berliner Weisse",
            Abv = 3.5m,
            Description = "A tart and refreshing sour ale with hints of passionfruit and guava.",
            Brewery = "Wild Beer Co",
            Price = 5.00m
        },
        new Beer
        {
            Id = Guid.Parse("a1b2c3d4-0005-0000-0000-000000000005"),
            Name = "Amber Waves",
            Style = "American Amber Ale",
            Abv = 5.4m,
            Description = "A balanced amber ale with caramel malt sweetness and a citrusy hop backbone.",
            Brewery = "BrewDog",
            Price = 4.50m
        }
    ];

    public IReadOnlyList<Beer> GetAll() => Beers.AsReadOnly();
}
