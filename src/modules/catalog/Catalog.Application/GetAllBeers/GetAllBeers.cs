using Catalog.Domain;

namespace Catalog.Application.GetAllBeers;

public interface IBeerRepository
{
    IReadOnlyList<Beer> GetAll();
}

public class GetAllBeersHandler
{
    private readonly IBeerRepository _repository;

    public GetAllBeersHandler(IBeerRepository repository)
    {
        _repository = repository;
    }

    public IReadOnlyList<Beer> Handle()
    {
        using var activity = CatalogInstrumentation.ActivitySource.StartActivity("GetAllBeers");

        CatalogInstrumentation.BeersRequestCount.Add(1);

        var beers = _repository.GetAll();

        activity?.SetTag("beers.count", beers.Count);
        CatalogInstrumentation.BeersReturnedCount.Record(beers.Count);

        return beers;
    }
}
