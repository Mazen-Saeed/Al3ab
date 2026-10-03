using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

// One gaming device/station (e.g. "PS5-3").
public class Unit : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid RoomId { get; set; }
    public Room Room { get; set; } = null!;

    public Guid UnitTypeId { get; set; }
    public UnitType UnitType { get; set; } = null!;

    public Guid PriceCategoryId { get; set; }
    public PriceCategory PriceCategory { get; set; } = null!;

    public required string Name { get; set; }
    public UnitStatus Status { get; set; } = UnitStatus.Active;

    // Why it is in maintenance ("the controller is broken"). Only meaningful while Status = Maintenance.
    public string? MaintenanceNote { get; set; }
}
