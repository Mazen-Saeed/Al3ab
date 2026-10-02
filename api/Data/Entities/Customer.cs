namespace Al3ab.Api.Data.Entities;

// Customer-app account. Global: signs up once, books at any venue.
public class Customer : SyncedEntity
{
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public required string PasswordHash { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
