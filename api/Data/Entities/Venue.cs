namespace Al3ab.Api.Data.Entities;

public class Venue : SyncedEntity
{
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public string? Address { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }

    // If ClosesAt <= OpensAt, the venue closes the next day (e.g. 14:00 -> 03:00).
    public TimeOnly? OpensAt { get; set; }
    public TimeOnly? ClosesAt { get; set; }

    // Set by the backend on every sync call from the shop PC, even empty ones.
    public DateTime? LastSyncedAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
