namespace Al3b.Api.Data.Entities;

// One open shift per venue at a time. No payments without an open shift.
public class Shift : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid OpenedByStaffId { get; set; }
    public Staff OpenedByStaff { get; set; } = null!;

    public DateTime OpenedAt { get; set; }
    public decimal OpeningCash { get; set; }

    public Guid? ClosedByStaffId { get; set; }
    public Staff? ClosedByStaff { get; set; }

    public DateTime? ClosedAt { get; set; }

    // Calculated at close and stored as a snapshot:
    // OpeningCash + cash bills + CashIn - Expense - OwnerWithdrawal
    public decimal? ExpectedCash { get; set; }

    // What staff actually counted in the drawer.
    public decimal? CountedCash { get; set; }

    public string? Note { get; set; }
}
