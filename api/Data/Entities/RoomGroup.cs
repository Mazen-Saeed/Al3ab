namespace Al3b.Api.Data.Entities;

// Optional grouping of rooms, made by the owner: e.g. "الصالات" holding Hall 1-4.
// The Floor screen shows one section per group. Private rooms (one unit) aren't grouped.
public class RoomGroup : SyncedEntity
{
    public Guid VenueId { get; set; }
    public Venue Venue { get; set; } = null!;

    public required string Name { get; set; }

    // Order of the sections on the Floor screen (lower first).
    public int SortOrder { get; set; }
}
