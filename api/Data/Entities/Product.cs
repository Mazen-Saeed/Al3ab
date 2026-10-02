namespace Al3ab.Api.Data.Entities;

// Drinks/snacks.
public class Product : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public required string Name { get; set; }
    public decimal Price { get; set; }

    // Changed on the shop PC only (sales, restock). Owner app shows it read-only.
    public int StockQuantity { get; set; }
}
