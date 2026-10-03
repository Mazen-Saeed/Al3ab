namespace Al3b.Api.Data.Entities;

// One line on the receipt, copied at payment time and never changed afterwards.
// Play time and drinks from a session are copied here; a quick sale writes its lines directly.
public class BillItem : SyncedEntity
{
    // Same venue as the parent row. Repeated here so sync can ask every table "this venue, changed since T" without joins.
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid BillId { get; set; }
    public Bill Bill { get; set; } = null!;

    // Set for a product (to count sales and stock); null for play time.
    public Guid? ProductId { get; set; }
    public Product? Product { get; set; }

    // The text on the receipt, e.g. "Play time PS5-2" or "Pepsi".
    public required string Description { get; set; }

    public int Quantity { get; set; } = 1;
    public decimal UnitPrice { get; set; }
    public decimal Total { get; set; }   // Quantity x UnitPrice
}
