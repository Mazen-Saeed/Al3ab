namespace Al3b.Api.Data.Entities;

public class SessionProduct : SyncedEntity
{
    public Guid SessionId { get; set; }
    public Session Session { get; set; } = null!;

    public Guid ProductId { get; set; }
    public Product Product { get; set; } = null!;

    public int Quantity { get; set; } = 1;

    // Snapshot of the price at the time of the order.
    public decimal UnitPrice { get; set; }

    public DateTime OrderedAt { get; set; } = DateTime.UtcNow;
}
