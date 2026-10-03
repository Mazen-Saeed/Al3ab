namespace Al3b.Api.Data.Entities;

// Something bought and counted: a coffee tin, a tea packet, a can of Pepsi.
// A Product is what is sold; several products may share one stock item.
public class StockItem : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public required string Name { get; set; }

    // true: every sale of a linked product subtracts its quantity from OnHand (Pepsi, chips).
    // false: sales subtract nothing; staff record "bought / opened / counted" by hand (tea, coffee).
    public bool DeductsOnSale { get; set; }

    // What is on the shelf now. Changed on the shop device only, in the same local transaction as the
    // action that changes it (order line added/removed, quick sale, purchase, opened, count).
    // No check constraint: an offline sale must never be rejected, so it can go below 0.
    public int OnHand { get; set; }

    // Show a "running low" warning at or below this number. Null = no warning.
    public int? LowStockAt { get; set; }
}
