namespace Al3b.Api.Data.Entities;

public class SessionProduct : SyncedEntity
{
    // Same venue as the parent row. Repeated here so sync can ask every table "this venue, changed since T" without joins.
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid SessionId { get; set; }
    public Session Session { get; set; } = null!;

    public Guid ProductId { get; set; }
    public Product Product { get; set; } = null!;

    public int Quantity { get; set; } = 1;

    // Snapshot of the price at the time of the order.
    public decimal UnitPrice { get; set; }

    public DateTime OrderedAt { get; set; } = DateTime.UtcNow;
}
