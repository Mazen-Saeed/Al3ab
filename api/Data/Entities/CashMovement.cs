using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

// Cash in or out of the drawer that isn't a bill.
public class CashMovement : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid ShiftId { get; set; }
    public Shift Shift { get; set; } = null!;

    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    public CashMovementType Type { get; set; }
    public decimal Amount { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
