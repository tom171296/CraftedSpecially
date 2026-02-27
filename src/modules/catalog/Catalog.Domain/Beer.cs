namespace Catalog.Domain;

public class Beer
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Style { get; set; } = string.Empty;
    public decimal Abv { get; set; }
    public string Description { get; set; } = string.Empty;
    public string Brewery { get; set; } = string.Empty;
    public decimal Price { get; set; }
}
