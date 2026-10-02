using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

public class Session : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    // Set when the session came from a reservation (one session per reservation).
    public Guid? ReservationId { get; set; }
    public Reservation? Reservation { get; set; }

    // At most one of these is set. Both null = anonymous walk-in.
    public Guid? CustomerId { get; set; }
    public Customer? Customer { get; set; }

    public Guid? WalkInCustomerId { get; set; }
    public WalkInCustomer? WalkInCustomer { get; set; }

    // Who started the session.
    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    public SessionStatus Status { get; set; } = SessionStatus.Active;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
