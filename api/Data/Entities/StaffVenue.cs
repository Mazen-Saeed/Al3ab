using Al3b.Api.Data.Enums;

namespace Al3b.Api.Data.Entities;

// Which venues a staff member belongs to, and their role in each.
public class StaffVenue : SyncedEntity
{
    public Guid StaffId { get; set; }
    public Staff Staff { get; set; } = null!;

    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public Role Role { get; set; }
}
