namespace Al3b.Api.Data.Entities;

// Drinks/snacks: what is sold. What is counted lives in StockItem.
public class Product : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public required string Name { get; set; }
    public decimal Price { get; set; }

    // The stock item this product draws from. Null = not tracked (e.g. a service or a free item).
    public Guid? StockItemId { get; set; }
    public StockItem? StockItem { get; set; }
}
