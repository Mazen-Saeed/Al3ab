using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

public class Bill : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    // Set when the bill closes a session; null for a quick sale (drinks/snacks without playing).
    public Guid? SessionId { get; set; }
    public Session? Session { get; set; }

    // Who took the payment.
    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    // The shift that was open when the bill was paid. Only Cash bills count toward the drawer.
    public Guid ShiftId { get; set; }
    public Shift Shift { get; set; } = null!;

    public decimal Subtotal { get; set; }   // before discount
    public decimal Discount { get; set; }
    public decimal Total { get; set; }      // after discount = amount actually paid
    public string? DiscountNote { get; set; }

    public PaymentMethod PaymentMethod { get; set; }
    // A bill is only created when it is paid.
    public DateTime PaidAt { get; set; }
}
