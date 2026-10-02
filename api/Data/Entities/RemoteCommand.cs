using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

// An action requested from a remote device (e.g. owner's phone), applied by the venue's shop device.
// First version: the exact command types and payloads get defined when we build remote actions.
public class RemoteCommand : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    // Who asked for it.
    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    // Which device (phone) it was sent from.
    public Guid DeviceId { get; set; }
    public Device Device { get; set; } = null!;

    // e.g. "start_session". A string, not an enum: an older shop device must be able to
    // receive a type it doesn't know and reject it, instead of failing to read the row.
    public required string Type { get; set; }

    // Command details as JSON, e.g. { "unitId": "...", "mode": "Single" }.
    public required string Payload { get; set; }

    public RemoteCommandStatus Status { get; set; } = RemoteCommandStatus.Pending;
    public string? RejectReason { get; set; }   // e.g. "PS5-2 is already in use"

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? AppliedAt { get; set; }    // when the shop device applied or rejected it
}
