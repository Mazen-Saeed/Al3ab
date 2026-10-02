namespace Al3b.Api.Data.Entities;

// Everyone who works at a shop, owners included. Global: one login across venues.
// Created/edited on the backend only; shop PCs keep a synced copy so login works offline.
public class Staff : SyncedEntity
{
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public required string PasswordHash { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
