namespace Al3b.Api.Data.Entities;

// One shopping trip: what was on the receipt. The stock it bought is in stock_movements
// (Kind = Purchase), linked by PurchaseId. The total lives here because it belongs to the
// whole receipt, not to any one line.
public class Purchase : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    // Who recorded it.
    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    // What was paid in total.
    public decimal Total { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
