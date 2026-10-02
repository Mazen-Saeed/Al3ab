namespace Al3ab.Api.Data.Entities;

// A venue's own contact book. Created on the shop PC (even offline), synced up, never merged with Customer.
public class WalkInCustomer : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public string? Name { get; set; }
    public string? Phone { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
