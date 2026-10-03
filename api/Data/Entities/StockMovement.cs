using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

// What staff did by hand to a stock item: bought, opened, counted. (Called "edit number" in the app.) Never overwritten.
// A mistake is fixed by soft-deleting the row and adding a correct one.
// Sales are NOT copied here: they already exist as sessions_products / bill_items.
public class StockMovement : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid StockItemId { get; set; }
    public StockItem StockItem { get; set; } = null!;

    public StockMovementKind Kind { get; set; }

    // Purchase/Opened: how many (> 0). Count: what was counted (>= 0).
    public int Quantity { get; set; }

    // Set on a Purchase: the shopping trip (receipt) it belongs to. Null for Opened and Count.
    public Guid? PurchaseId { get; set; }
    public Purchase? Purchase { get; set; }

    // Set on a Count only: what the app expected to be on the shelf when staff counted.
    // A snapshot (like Shift.ExpectedCash): Quantity - ExpectedQuantity is what was found missing or extra.
    public int? ExpectedQuantity { get; set; }

    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
