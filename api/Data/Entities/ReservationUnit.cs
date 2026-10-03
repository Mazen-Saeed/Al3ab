namespace Al3b.Api.Data.Entities;

public class ReservationUnit : SyncedEntity
{
    // Same venue as the parent row. Repeated here so sync can ask every table "this venue, changed since T" without joins.
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid ReservationId { get; set; }
    public Reservation Reservation { get; set; } = null!;

    public Guid UnitId { get; set; }
    public Unit Unit { get; set; } = null!;
}
