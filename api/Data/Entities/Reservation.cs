using Al3ab.Api.Data.Enums;

namespace Al3ab.Api.Data.Entities;

// App booking: CustomerId set, StaffId null.
// Phone/walk-in booking: WalkInCustomerId and StaffId set.
public class Reservation : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Guid? CustomerId { get; set; }
    public Customer? Customer { get; set; }

    public Guid? WalkInCustomerId { get; set; }
    public WalkInCustomer? WalkInCustomer { get; set; }

    public Guid? StaffId { get; set; }
    public Staff? Staff { get; set; }

    // Backend confirms instantly if the shop is online; otherwise the shop PC decides on sync.
    public ReservationStatus Status { get; set; } = ReservationStatus.Pending;

    // Shown by the customer at the shop (also as a QR code).
    public string? ConfirmationCode { get; set; }

    public DateTime StartsAt { get; set; }
    public DateTime EndsAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
