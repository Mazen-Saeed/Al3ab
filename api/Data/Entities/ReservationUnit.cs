namespace Al3ab.Api.Data.Entities;

public class ReservationUnit : SyncedEntity
{
    public Guid ReservationId { get; set; }
    public Reservation Reservation { get; set; } = null!;

    public Guid UnitId { get; set; }
    public Unit Unit { get; set; } = null!;
}
