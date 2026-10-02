using Al3ab.Api.Data.Enums;

namespace Al3ab.Api.Data.Entities;

// Every device that has logged in: shop devices and staff/owner phones.
// Id is created on the device at install time and kept locally.
public class Device : SyncedEntity
{
    // Who last logged in on this device.
    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    // The venue this device works for (null for an owner's phone that sees several venues).
    public Guid? VenueId { get; set; }
    public Venue? Venue { get; set; }

    public required string Name { get; set; }       // e.g. "Counter tablet"
    public DevicePlatform Platform { get; set; }
    public string? AppVersion { get; set; }         // tells us who still runs old versions

    public DateTime? LastSeenAt { get; set; }

    // Set when a device is lost/stolen: the backend refuses its login and sync.
    public DateTime? RevokedAt { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
